import '../../../../core/failures.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';

/// Fake repository untuk pengujian dependensi tanpa database sqlite/jaringan sungguhan.
class FakeNoteRepository implements NoteRepository {
  FakeNoteRepository({
    List<Note>? initialNotes,
    this.failure,
  }) : _notes = initialNotes != null ? List<Note>.from(initialNotes) : [];

  final List<Note> _notes;
  final Failure? failure;

  List<Note> get currentNotes => List.unmodifiable(_notes);

  @override
  Future<({List<Note> notes, Failure? failure})> fetchNotes() async {
    if (failure != null) {
      return (notes: <Note>[], failure: failure);
    }
    return (notes: List<Note>.from(_notes), failure: null);
  }

  @override
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  }) async {
    if (failure != null) {
      return (note: null, failure: failure);
    }
    final newNote = Note(
      id: _notes.length + 1,
      title: title,
      body: body,
      updatedAt: DateTime.now(),
      dirty: false,
    );
    _notes.insert(0, newNote);
    return (note: newNote, failure: null);
  }
}
