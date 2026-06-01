import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/models.dart';

/// CRUD for TODO items stored in the student's personal Firebase Firestore.
class TodoService {
  FirebaseFirestore get _db => FirebaseFirestore.instanceFor(app: Firebase.app());

  String? get _userId => FirebaseAuth.instanceFor(app: Firebase.app()).currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _collection => _db.collection('todos');

  // ── Read ───────────────────────────────────────────────────────────────────

  /// Stream of ALL todos for the user. Filtering is done client-side
  /// so we only need the single existing index (user_id + created_at).
  Stream<List<Todo>> getAllTodos() {
    if (_userId == null) return const Stream.empty();
    return _collection
        .where('user_id', isEqualTo: _userId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Todo.fromDoc).toList());
  }

  // ── Create ─────────────────────────────────────────────────────────────────

  Future<void> addTodo({
    required String title,
    String description = '',
    String priority = 'low',
    DateTime? dueDate,
    String category = 'personal',
  }) async {
    if (_userId == null) return;
    await _collection.add({
      'user_id': _userId,
      'title': title.trim(),
      'description': description.trim(),
      'is_done': false,
      'is_deleted': false,
      'created_at': FieldValue.serverTimestamp(),
      'priority': priority,
      'due_date': dueDate != null ? Timestamp.fromDate(dueDate) : null,
      'category': category,
    });
  }

  // ── Update ─────────────────────────────────────────────────────────────────

  /// Mark task as completed.
  Future<void> markDone(String todoId) async {
    await _collection.doc(todoId).update({'is_done': true, 'is_deleted': false});
  }

  /// Undo completion — move back to Active.
  Future<void> markUndone(String todoId) async {
    await _collection.doc(todoId).update({'is_done': false, 'is_deleted': false});
  }

  /// Soft-delete a task — moves to Deleted Tasks section.
  Future<void> softDelete(String todoId) async {
    await _collection.doc(todoId).update({'is_deleted': true});
  }

  /// Restore a soft-deleted task back to Active.
  Future<void> restore(String todoId) async {
    await _collection.doc(todoId).update({'is_deleted': false, 'is_done': false});
  }

  /// Update all editable fields of a todo.
  Future<void> updateTodo(
    String todoId, {
    required String title,
    required String description,
    required String priority,
    DateTime? dueDate,
    required String category,
  }) async {
    await _collection.doc(todoId).update({
      'title': title.trim(),
      'description': description.trim(),
      'priority': priority,
      'due_date': dueDate != null ? Timestamp.fromDate(dueDate) : null,
      'category': category,
    });
  }

  // ── Delete ─────────────────────────────────────────────────────────────────

  /// Permanently remove a task from Firestore (used in Deleted Tasks tab).
  Future<void> permanentDelete(String todoId) async {
    await _collection.doc(todoId).delete();
  }

  /// Permanently delete ALL soft-deleted tasks (empty trash).
  Future<void> clearTrash() async {
    if (_userId == null) return;
    final snap = await _collection
        .where('user_id', isEqualTo: _userId)
        .where('is_deleted', isEqualTo: true)
        .get();
    for (final doc in snap.docs) {
      await doc.reference.delete();
    }
  }
}
