import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/note.dart';
import '../models/note_folder.dart';
import '../models/sticky_board.dart';
import '../models/sticky.dart';
import 'auth_service.dart';

final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final notesCloudSyncServiceProvider = Provider<NotesCloudSyncService>((ref) {
  return NotesCloudSyncService(
    ref.read(firebaseFirestoreProvider),
    ref.read(firebaseAuthProvider),
  );
});

final noteFoldersCloudSyncServiceProvider = Provider<NoteFoldersCloudSyncService>((ref) {
  return NoteFoldersCloudSyncService(
    ref.read(firebaseFirestoreProvider),
    ref.read(firebaseAuthProvider),
  );
});

final stickiesCloudSyncServiceProvider = Provider<StickiesCloudSyncService>((
  ref,
) {
  return StickiesCloudSyncService(
    ref.read(firebaseFirestoreProvider),
    ref.read(firebaseAuthProvider),
  );
});

final stickyBoardsCloudSyncServiceProvider =
    Provider<StickyBoardsCloudSyncService>((ref) {
  return StickyBoardsCloudSyncService(
    ref.read(firebaseFirestoreProvider),
    ref.read(firebaseAuthProvider),
  );
});

class NotesCloudSyncService {
  NotesCloudSyncService(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> _notesCollection(String uid) {
    return _firestore.collection('users').doc(uid).collection('notes');
  }

  Future<void> pushLocalSnapshot(Iterable<Note> notes) async {
    final user = _auth.currentUser;
    if (user == null) {
      return;
    }

    final remoteSnapshot = await _notesCollection(user.uid).get();
    final remoteById = <String, Note>{
      for (final doc in remoteSnapshot.docs) doc.id: _noteFromFirestore(doc),
    };

    for (final note in notes) {
      final remote = remoteById[note.id];
      if (remote == null ||
          note.deviceUpdatedAt.isAfter(remote.deviceUpdatedAt)) {
        await save(note);
      }
    }
  }

  Stream<List<Note>> watch() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    return _notesCollection(user.uid).snapshots().map(
      (snapshot) =>
          snapshot.docs.map(_noteFromFirestore).toList()
            ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt)),
    );
  }

  Future<void> save(Note note) async {
    final user = _auth.currentUser;
    if (user == null) {
      return;
    }

    await _notesCollection(user.uid).doc(note.id).set({
      'title': note.title,
      'body': note.body,
      'folderId': note.folderId,
      'isFavorite': note.isFavorite,
      'tags': note.tags,
      'comments': note.comments.map((comment) => comment.toMap()).toList(),
      'attachments':
          note.attachments.map((attachment) => attachment.toMap()).toList(),
      'createdAt': Timestamp.fromDate(note.createdAt),
      'updatedAt': Timestamp.fromDate(note.updatedAt),
      'deviceUpdatedAt': Timestamp.fromDate(note.deviceUpdatedAt),
      'isDeleted': note.isDeleted,
    });
  }

  Note _noteFromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final map = doc.data() ?? const <String, dynamic>{};
    final createdAt = _readDate(map['createdAt']);
    final updatedAt = _readDate(map['updatedAt']);
    return Note(
      id: doc.id,
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      folderId: map['folderId'],
      isFavorite: map['isFavorite'] ?? false,
      tags: map['tags'] != null ? List<String>.from(map['tags']) : const [],
      comments: map['comments'] != null
          ? List<Map<String, dynamic>>.from(map['comments'])
              .map(NoteComment.fromMap)
              .toList()
          : const [],
      attachments: map['attachments'] != null
          ? List<Map<String, dynamic>>.from(map['attachments'])
              .map(NoteAttachment.fromMap)
              .toList()
          : const [],
      createdAt: createdAt,
      updatedAt: updatedAt,
      deviceUpdatedAt: _readDate(map['deviceUpdatedAt'], fallback: updatedAt),
      isDeleted: map['isDeleted'] ?? false,
    );
  }
}

class NoteFoldersCloudSyncService {
  NoteFoldersCloudSyncService(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> _foldersCollection(String uid) {
    return _firestore.collection('users').doc(uid).collection('folders');
  }

  Future<void> pushLocalSnapshot(Iterable<NoteFolder> folders) async {
    final user = _auth.currentUser;
    if (user == null) {
      return;
    }

    final remoteSnapshot = await _foldersCollection(user.uid).get();
    final remoteById = <String, NoteFolder>{
      for (final doc in remoteSnapshot.docs) doc.id: _folderFromFirestore(doc),
    };

    for (final folder in folders) {
      final remote = remoteById[folder.id];
      if (remote == null ||
          folder.deviceUpdatedAt.isAfter(remote.deviceUpdatedAt)) {
        await save(folder);
      }
    }
  }

  Stream<List<NoteFolder>> watch() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    return _foldersCollection(user.uid).snapshots().map(
      (snapshot) =>
          snapshot.docs.map(_folderFromFirestore).toList()
            ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase())),
    );
  }

  Future<void> save(NoteFolder folder) async {
    final user = _auth.currentUser;
    if (user == null) {
      return;
    }

    await _foldersCollection(user.uid).doc(folder.id).set({
      'name': folder.name,
      'parentId': folder.parentId,
      'createdAt': Timestamp.fromDate(folder.createdAt),
      'updatedAt': Timestamp.fromDate(folder.updatedAt),
      'deviceUpdatedAt': Timestamp.fromDate(folder.deviceUpdatedAt),
      'isDeleted': folder.isDeleted,
    });
  }

  NoteFolder _folderFromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final map = doc.data() ?? const <String, dynamic>{};
    final createdAt = _readDate(map['createdAt']);
    final updatedAt = _readDate(map['updatedAt']);
    return NoteFolder(
      id: doc.id,
      name: map['name'] ?? 'Untitled folder',
      parentId: map['parentId'],
      createdAt: createdAt,
      updatedAt: updatedAt,
      deviceUpdatedAt: _readDate(map['deviceUpdatedAt'], fallback: updatedAt),
      isDeleted: map['isDeleted'] ?? false,
    );
  }
}

class StickiesCloudSyncService {
  StickiesCloudSyncService(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> _stickiesCollection(String uid) {
    return _firestore.collection('users').doc(uid).collection('stickies');
  }

  Future<void> pushLocalSnapshot(Iterable<Sticky> stickies) async {
    final user = _auth.currentUser;
    if (user == null) {
      return;
    }

    final remoteSnapshot = await _stickiesCollection(user.uid).get();
    final remoteById = <String, Sticky>{
      for (final doc in remoteSnapshot.docs) doc.id: _stickyFromFirestore(doc),
    };

    for (final sticky in stickies) {
      final remote = remoteById[sticky.id];
      if (remote == null ||
          sticky.deviceUpdatedAt.isAfter(remote.deviceUpdatedAt)) {
        await save(sticky);
      }
    }
  }

  Stream<List<Sticky>> watch() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    return _stickiesCollection(user.uid).snapshots().map(
      (snapshot) =>
          snapshot.docs.map(_stickyFromFirestore).toList()
            ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt)),
    );
  }

  Future<void> save(Sticky sticky) async {
    final user = _auth.currentUser;
    if (user == null) {
      return;
    }

    await _stickiesCollection(user.uid).doc(sticky.id).set({
      'title': sticky.title,
      'body': sticky.body,
      'color': sticky.color.toARGB32(),
      'boardId': sticky.boardId,
      'linkedNoteId': sticky.linkedNoteId,
      'linkedNoteTitle': sticky.linkedNoteTitle,
      'size': sticky.size,
      'isPinned': sticky.isPinned,
      'sortOrder': sticky.sortOrder,
      'updatedAt': Timestamp.fromDate(sticky.updatedAt),
      'deviceUpdatedAt': Timestamp.fromDate(sticky.deviceUpdatedAt),
      'isDeleted': sticky.isDeleted,
    });
  }

  Sticky _stickyFromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final map = doc.data() ?? const <String, dynamic>{};
    final updatedAt = _readDate(map['updatedAt']);
    return Sticky(
      id: doc.id,
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      color: Color((map['color'] ?? 0xFFFFFF00) as int),
      boardId: map['boardId'],
      linkedNoteId: map['linkedNoteId'],
      linkedNoteTitle: map['linkedNoteTitle'],
      size: map['size'] ?? 'medium',
      isPinned: map['isPinned'] ?? false,
      sortOrder: map['sortOrder'] ?? 0,
      updatedAt: updatedAt,
      deviceUpdatedAt: _readDate(map['deviceUpdatedAt'], fallback: updatedAt),
      isDeleted: map['isDeleted'] ?? false,
    );
  }
}

class StickyBoardsCloudSyncService {
  StickyBoardsCloudSyncService(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> _boardsCollection(String uid) {
    return _firestore.collection('users').doc(uid).collection('sticky_boards');
  }

  Future<void> pushLocalSnapshot(Iterable<StickyBoard> boards) async {
    final user = _auth.currentUser;
    if (user == null) {
      return;
    }

    final remoteSnapshot = await _boardsCollection(user.uid).get();
    final remoteById = <String, StickyBoard>{
      for (final doc in remoteSnapshot.docs) doc.id: _boardFromFirestore(doc),
    };

    for (final board in boards) {
      final remote = remoteById[board.id];
      if (remote == null ||
          board.deviceUpdatedAt.isAfter(remote.deviceUpdatedAt)) {
        await save(board);
      }
    }
  }

  Stream<List<StickyBoard>> watch() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    return _boardsCollection(user.uid).snapshots().map(
      (snapshot) =>
          snapshot.docs.map(_boardFromFirestore).toList()
            ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase())),
    );
  }

  Future<void> save(StickyBoard board) async {
    final user = _auth.currentUser;
    if (user == null) {
      return;
    }

    await _boardsCollection(user.uid).doc(board.id).set({
      'name': board.name,
      'createdAt': Timestamp.fromDate(board.createdAt),
      'updatedAt': Timestamp.fromDate(board.updatedAt),
      'deviceUpdatedAt': Timestamp.fromDate(board.deviceUpdatedAt),
      'isDeleted': board.isDeleted,
    });
  }

  StickyBoard _boardFromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final map = doc.data() ?? const <String, dynamic>{};
    final createdAt = _readDate(map['createdAt']);
    final updatedAt = _readDate(map['updatedAt']);
    return StickyBoard(
      id: doc.id,
      name: map['name'] ?? 'Board',
      createdAt: createdAt,
      updatedAt: updatedAt,
      deviceUpdatedAt: _readDate(map['deviceUpdatedAt'], fallback: updatedAt),
      isDeleted: map['isDeleted'] ?? false,
    );
  }
}

DateTime _readDate(dynamic value, {DateTime? fallback}) {
  if (value is Timestamp) {
    return value.toDate();
  }
  if (value is String && value.isNotEmpty) {
    return DateTime.parse(value);
  }
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value);
  }
  return fallback ?? DateTime.now();
}
