import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../ai/ai_service.dart';

/// Model representasi pesan percakapan dalam Chat Interface
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final Stream<String>? stream;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.stream,
  });
}

/// Layar antarmuka percakapan AI dengan respons streaming dan indikator loading
class ChatScreen extends StatefulWidget {
  final AiService? aiService;

  const ChatScreen({super.key, this.aiService});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final AiService _aiService;
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _aiService = widget.aiService ?? AiService();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  bool _containsSensitiveData(String text) {
    // Cek NIK (16 digit angka berurutan)
    final nikRegex = RegExp(r'\b\d{16}\b');
    // Cek Nomor Telepon Indonesia (awalan 08 atau +62)
    final phoneRegex = RegExp(r'(\+62|62|0)8[1-9][0-9]{6,10}\b');

    return nikRegex.hasMatch(text) || phoneRegex.hasMatch(text);
  }

  Future<void> _sendMessage() async {
    final query = _textController.text.trim();
    if (query.isEmpty || _isLoading) return;

    // Catatan keamanan: Jangan pernah mengirim NIK, no telepon, atau data sensitif
    if (_containsSensitiveData(query)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Peringatan Keamanan: Terdeteksi data sensitif (NIK/Nomor Telepon). Harap gunakan data anonim.',
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return;
    }

    _textController.clear();
    final userMessage = ChatMessage(
      text: query,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });
    _scrollToBottom();

    final streamController = StreamController<String>.broadcast();
    final streamingAiMessage = ChatMessage(
      text: '',
      isUser: false,
      timestamp: DateTime.now(),
      stream: streamController.stream,
    );

    setState(() {
      _messages.add(streamingAiMessage);
    });
    _scrollToBottom();

    try {
      final response = await _aiService.ask(query);

      if (!mounted) {
        await streamController.close();
        return;
      }

      // Streaming respons secara dinamis ke StreamBuilder
      final words = response.split(' ');
      String accumulated = '';
      for (int i = 0; i < words.length; i++) {
        accumulated += (i == 0 ? '' : ' ') + words[i];
        if (!streamController.isClosed) {
          streamController.add(accumulated);
        }
        await Future.delayed(const Duration(milliseconds: 25));
      }

      await streamController.close();

      if (mounted) {
        setState(() {
          final idx = _messages.indexOf(streamingAiMessage);
          if (idx != -1) {
            _messages[idx] = ChatMessage(
              text: response,
              isUser: false,
              timestamp: DateTime.now(),
            );
          }
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (!streamController.isClosed) {
        await streamController.close();
      }

      if (mounted) {
        setState(() {
          _messages.remove(streamingAiMessage);
          _isLoading = false;
        });

        final errorMsg = e.toString();
        final isApiKeyMissing = errorMsg.contains('API key tidak tersedia');

        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(isApiKeyMissing ? 'API Key Belum Diatur' : 'Layanan AI Sibuk'),
            content: Text(
              isApiKeyMissing
                  ? 'API key tidak tersedia. Silakan atur API key pada menu pengaturan.'
                  : 'Coba lagi nanti atau gunakan mode offline.',
            ),
            actions: [
              if (isApiKeyMissing)
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _showApiKeyDialog();
                  },
                  child: const Text('Atur API Key'),
                ),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Tutup'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _showApiKeyDialog() {
    final keyController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pengaturan AI API Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Masukkan Google Gemini API Key Anda. Kunci akan disimpan secara aman di flutter_secure_storage.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: keyController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'API Key',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.key),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final key = keyController.text.trim();
              if (key.isNotEmpty) {
                await _aiService.saveApiKey(key);
                if (!mounted) return;
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('API Key berhasil disimpan')),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Campus Assistant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.vpn_key_outlined),
            tooltip: 'Pengaturan API Key',
            onPressed: _showApiKeyDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 64,
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Tanya Asisten AI Kampus',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Ajukan pertanyaan seputar perkuliahan atau informasi kampus.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      return _buildMessageBubble(msg);
                    },
                  ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              child: Row(
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'AI sedang mengetik...',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          const Divider(height: 1),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    final theme = Theme.of(context);
    final isUser = msg.isUser;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: theme.colorScheme.secondaryContainer,
              child: const Icon(Icons.smart_toy_outlined, size: 16),
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: isUser
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(14),
                  topRight: const Radius.circular(14),
                  bottomLeft: Radius.circular(isUser ? 14 : 2),
                  bottomRight: Radius.circular(isUser ? 2 : 14),
                ),
              ),
              child: msg.stream != null
                  ? StreamBuilder<String>(
                      stream: msg.stream,
                      builder: (context, snapshot) {
                        final streamText = snapshot.data ?? '';
                        if (streamText.isEmpty) {
                          return const SizedBox(
                            width: 24,
                            height: 16,
                            child: Center(
                              child: SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(strokeWidth: 1.5),
                              ),
                            ),
                          );
                        }
                        return Text(
                          streamText,
                          style: TextStyle(
                            color: isUser
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        );
                      },
                    )
                  : Text(
                      msg.text,
                      style: TextStyle(
                        color: isUser
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
            ),
          ),
          if (!isUser && msg.stream == null && msg.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.copy, size: 16, color: Colors.grey),
              tooltip: 'Salin Jawaban',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: msg.text));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Teks berhasil disalin ke clipboard'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: 'Ketik pertanyaan...',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            IconButton(
              icon: const Icon(Icons.send),
              color: Theme.of(context).colorScheme.primary,
              onPressed: _isLoading ? null : _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}
