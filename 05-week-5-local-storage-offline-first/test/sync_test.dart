import 'package:flutter_test/flutter_test.dart';
import 'package:week5_offline_notes/data/repositories/note_repository.dart';
import 'package:week5_offline_notes/data/sync.dart';

class FakeNoteRepositoryForSync extends NoteRepository {
  FakeNoteRepositoryForSync({this.dirtyCount = 3})
      : super(openDb: () => throw UnimplementedError());

  int dirtyCount;
  bool isSynced = false;

  @override
  Future<int> countDirty() async => dirtyCount;

  @override
  Future<void> markAllSynced() async {
    isSynced = true;
    dirtyCount = 0;
  }
}

void main() {
  test('syncNotes menyinkronkan catatan kotor dan mengembalikan jumlahnya', () async {
    final fakeRepo = FakeNoteRepositoryForSync(dirtyCount: 3);
    final count = await syncNotes(fakeRepo);

    expect(count, 3);
    expect(fakeRepo.isSynced, isTrue);
    expect(fakeRepo.dirtyCount, 0);
  });

  test('syncNotes mengembalikan 0 jika tidak ada catatan kotor', () async {
    final fakeRepo = FakeNoteRepositoryForSync(dirtyCount: 0);
    final count = await syncNotes(fakeRepo);

    expect(count, 0);
    expect(fakeRepo.isSynced, isFalse);
  });
}
