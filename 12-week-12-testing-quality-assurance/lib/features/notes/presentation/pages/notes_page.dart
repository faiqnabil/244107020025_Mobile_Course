import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/note.dart';
import '../../domain/usecases/filter_notes.dart';
import '../providers/notes_providers.dart';
import '../providers/search_query_provider.dart';

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  void _showAddTaskDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Tambah Tugas Baru'),
          content: Form(
            key: formKey,
            child: TextFormField(
              key: const Key('task-title-field'),
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Judul tugas',
                border: OutlineInputBorder(),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Judul tugas tidak boleh kosong';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              key: const Key('save-task-button'),
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  final title = titleController.text.trim();
                  final addNote = ref.read(addNoteProvider);
                  final result = await addNote(title: title);
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                  }
                  if (result.failure != null) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(result.failure!.message)),
                      );
                    }
                  } else {
                    ref.invalidate(notesProvider);
                  }
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notesProvider);
    final hasQuery = ref.watch(searchQueryProvider.select((q) => q.isNotEmpty));

    return Scaffold(
      appBar: AppBar(title: const Text('Catatan')),
      floatingActionButton: FloatingActionButton(
        key: const Key('add-task-fab'),
        onPressed: () => _showAddTaskDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Cari judul catatan',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: hasQuery
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () =>
                            ref.read(searchQueryProvider.notifier).clear(),
                      )
                    : null,
              ),
              onChanged: (v) =>
                  ref.read(searchQueryProvider.notifier).setQuery(v),
            ),
          ),
          Expanded(
            child: state.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => ErrorView(
                message: err.toString(),
                onRetry: () => ref.refresh(notesProvider),
              ),
              data: (notes) {
                final query = ref.watch(searchQueryProvider);
                final filteredNotes = filterNotes(notes, query);
                if (filteredNotes.isEmpty) {
                  return const Center(child: Text('Tidak ada catatan.'));
                }
                return NotesList(filteredNotes);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorView({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: onRetry, child: const Text('Coba Lagi')),
        ],
      ),
    );
  }
}

class NotesList extends StatelessWidget {
  final List<Note> notes;

  const NotesList(this.notes, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return NoteItemTile(note: note);
      },
    );
  }
}

class NoteItemTile extends StatelessWidget {
  final Note note;

  const NoteItemTile({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ListTile(
        title: Text(note.title),
        subtitle: note.body.isNotEmpty ? Text(note.body) : null,
      ),
    );
  }
}
