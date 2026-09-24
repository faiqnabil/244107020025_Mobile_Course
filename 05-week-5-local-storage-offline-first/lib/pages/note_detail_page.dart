import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/note_repository.dart';

class NoteDetailPage extends ConsumerWidget {
  const NoteDetailPage({super.key, required this.noteId});

  final int noteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noteAsync = ref.watch(noteDetailProvider(noteId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Catatan #$noteId'),
      ),
      body: noteAsync.when(
        data: (note) {
          if (note == null) {
            return const Center(
              child: Text('Catatan tidak ditemukan.'),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        note.title,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    if (note.dirty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.shade700),
                        ),
                        child: Text(
                          'Belum Sync',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade900,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Terakhir diperbarui: ${note.updatedAt.toLocal().toString().split('.')[0]}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                const Divider(height: 24),
                Text(
                  note.body.isEmpty ? '(Tidak ada isi catatan)' : note.body,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
