import '../entities/note.dart';

/// Pure domain use case untuk memfilter catatan berdasarkan judul (case-insensitive & trim query).
List<Note> filterNotes(List<Note> notes, String query) {
  final trimmed = query.trim();
  if (trimmed.isEmpty) return notes;
  final lower = trimmed.toLowerCase();
  return notes
      .where((note) => note.title.toLowerCase().contains(lower))
      .toList();
}
