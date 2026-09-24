import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/repositories/note_repository.dart';
import '../data/sync.dart';
import '../widgets/note_tile.dart';

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  void _showAddNoteDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Catatan Baru'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Judul',
                hintText: 'Masukkan judul catatan',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: bodyController,
              decoration: const InputDecoration(
                labelText: 'Isi Catatan',
                hintText: 'Masukkan isi catatan (opsional)',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text.trim();
              if (title.isNotEmpty) {
                final repo = ref.read(noteRepositoryProvider);
                await repo.addNote(
                  title: title,
                  body: bodyController.text.trim(),
                );
                ref.invalidate(notesProvider);
                ref.invalidate(dirtyCountProvider);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesProvider);
    final dirtyCountAsync = ref.watch(dirtyCountProvider);
    final postsAsync = ref.watch(postsProvider);
    final isForceOffline = ref.watch(forceOfflineProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Offline Notes & Cache'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.note), text: 'Catatan'),
              Tab(icon: Icon(Icons.cloud_download), text: 'Posts Cache'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                context.push('/settings');
              },
            ),
          ],
        ),
        body: TabBarView(
          children: [
            // Tab 1: Catatan Offline CRUD
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Row(
                    children: [
                      Icon(
                        Icons.sync,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: dirtyCountAsync.when(
                          data: (count) => Text(
                            count > 0
                                ? '$count catatan belum tersinkron (dirty)'
                                : 'Semua catatan telah tersinkron',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          loading: () => const Text('Memeriksa status sync...'),
                          error: (err, _) => Text('Error: $err'),
                        ),
                      ),
                      if ((dirtyCountAsync.value ?? 0) > 0)
                        ElevatedButton.icon(
                          icon: const Icon(Icons.cloud_upload, size: 18),
                          label: const Text('Sync'),
                          onPressed: () async {
                            final repo = ref.read(noteRepositoryProvider);
                            final count = await syncNotes(repo);
                            ref.invalidate(notesProvider);
                            ref.invalidate(dirtyCountProvider);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('$count catatan berhasil disinkronkan!'),
                                ),
                              );
                            }
                          },
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: notesAsync.when(
                    data: (notes) {
                      if (notes.isEmpty) {
                        return const Center(
                          child: Text('Belum ada catatan. Tekan + untuk menambah.'),
                        );
                      }
                      return ListView.builder(
                        itemCount: notes.length,
                        itemBuilder: (context, index) {
                          final note = notes[index];
                          return NoteTile(
                            note: note,
                            onTap: () {
                              if (note.id != null) {
                                context.push('/note/${note.id}');
                              }
                            },
                            onDelete: () async {
                              if (note.id != null) {
                                final repo = ref.read(noteRepositoryProvider);
                                await repo.deleteNote(note.id!);
                                ref.invalidate(notesProvider);
                                ref.invalidate(dirtyCountProvider);
                              }
                            },
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(child: Text('Error: $err')),
                  ),
                ),
              ],
            ),

            // Tab 2: Cache-first Posts
            Column(
              children: [
                SwitchListTile(
                  title: const Text('Force Offline Mode'),
                  subtitle: const Text('Simulasi mode offline untuk cache API'),
                  value: isForceOffline,
                  onChanged: (val) {
                    ref.read(forceOfflineProvider.notifier).setOffline(val);
                    ref.invalidate(postsProvider);
                  },
                ),
                const Divider(),
                Expanded(
                  child: postsAsync.when(
                    data: (posts) {
                      if (posts.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Cache posts masih kosong.'),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () => ref.invalidate(postsProvider),
                                child: const Text('Refresh Cache'),
                              ),
                            ],
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final post = posts[index];
                          return ListTile(
                            leading: CircleAvatar(child: Text('${post.id}')),
                            title: Text(post.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                            subtitle: Text(post.body, maxLines: 2, overflow: TextOverflow.ellipsis),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(child: Text('Error: $err')),
                  ),
                ),
              ],
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddNoteDialog(context, ref),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
