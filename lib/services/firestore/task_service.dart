import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lefni/models/task_model.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'tasks';

  // Create a new task
  Future<String> createTask(TaskModel task) async {
    try {
      final docRef = await _firestore.collection(_collection).add(
            task.copyWith(
              id: '',
              createdAt: DateTime.now(),
            ).toFirestore(),
          );
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create task: $e');
    }
  }

  // Get task by ID
  Future<TaskModel?> getTask(String taskId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(taskId).get();
      if (doc.exists) {
        return TaskModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get task: $e');
    }
  }

  // Update task
  Future<void> updateTask(TaskModel task) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(task.id)
          .update(task.toFirestore());
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  // Delete task
  Future<void> deleteTask(String taskId) async {
    try {
      await _firestore.collection(_collection).doc(taskId).delete();
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }

  // Get tasks by assigned user
  Stream<List<TaskModel>> getTasksByAssigned(String userId) {
    return _firestore
        .collection(_collection)
        .where('assignedTo', isEqualTo: userId)
        .where('status', isEqualTo: TaskStatus.pending.value)
        .orderBy('deadlines.end', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList());
  }

  // Get tasks by related entity
  Stream<List<TaskModel>> getTasksByRelated(
    String relatedId,
    RelatedType relatedType,
  ) {
    return _firestore
        .collection(_collection)
        .where('relatedId', isEqualTo: relatedId)
        .where('relatedType', isEqualTo: relatedType.value)
        .where('status', isEqualTo: TaskStatus.pending.value)
        .orderBy('deadlines.end', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList());
  }

  // Get tasks nearing deadline (for deadline watcher)
  Future<List<TaskModel>> getTasksNearingDeadline({
    int hoursAhead = 48,
  }) async {
    try {
      final now = DateTime.now();
      final deadline = now.add(Duration(hours: hoursAhead));

      final snapshot = await _firestore
          .collection(_collection)
          .where('status', isEqualTo: TaskStatus.pending.value)
          .where('deadlines.end',
              isGreaterThanOrEqualTo: Timestamp.fromDate(now))
          .where('deadlines.end', isLessThanOrEqualTo: Timestamp.fromDate(deadline))
          .orderBy('deadlines.end', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => TaskModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get tasks nearing deadline: $e');
    }
  }

  // Get overdue tasks
  Future<List<TaskModel>> getOverdueTasks() async {
    try {
      final now = DateTime.now();
      final snapshot = await _firestore
          .collection(_collection)
          .where('status', isEqualTo: TaskStatus.pending.value)
          .where('deadlines.end', isLessThan: Timestamp.fromDate(now))
          .orderBy('deadlines.end', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => TaskModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get overdue tasks: $e');
    }
  }

  // Update task status
  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    try {
      final updateData = <String, dynamic>{
        'status': status.value,
      };
      if (status == TaskStatus.completed) {
        updateData['completedAt'] = Timestamp.fromDate(DateTime.now());
      }
      await _firestore.collection(_collection).doc(taskId).update(updateData);
    } catch (e) {
      throw Exception('Failed to update task status: $e');
    }
  }

  // Complete task with report
  Future<void> completeTask(
    String taskId,
    String completionReport,
  ) async {
    try {
      await _firestore.collection(_collection).doc(taskId).update({
        'status': TaskStatus.completed.value,
        'completionReport': completionReport,
        'completedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to complete task: $e');
    }
  }
}

