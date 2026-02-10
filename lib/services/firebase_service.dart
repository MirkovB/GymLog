import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/body_metric.dart';
import '../models/exercise.dart';
import '../models/plan.dart';
import '../models/workout.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> addExercise(String userId, String name) async {
    try {
      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('exercises')
          .add({
            'name': name,
            'lastDone': null,
            'personalRecord': null,
            'workoutCount': 0,
          });
      return docRef.id;
    } catch (e) {
      throw Exception('Greška pri dodavanju vežbe: $e');
    }
  }

  Future<List<Exercise>> getExercises(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('exercises')
          .get();

      return snapshot.docs
          .map((doc) => Exercise.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Greška pri preuzimanju vežbi: $e');
    }
  }

  Future<void> deleteExercise(String userId, String exerciseId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('exercises')
          .doc(exerciseId)
          .delete();
    } catch (e) {
      throw Exception('Greška pri brisanju vežbe: $e');
    }
  }

  Future<void> updateExercise(
    String userId,
    String exerciseId, {
    double? personalRecord,
    DateTime? lastDone,
    bool incrementWorkoutCount = false,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (personalRecord != null) {
        data['personalRecord'] = personalRecord;
      }
      if (lastDone != null) {
        data['lastDone'] = lastDone.toIso8601String();
      }
      if (incrementWorkoutCount) {
        data['workoutCount'] = FieldValue.increment(1);
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('exercises')
          .doc(exerciseId)
          .update(data);
    } catch (e) {
      throw Exception('Greška pri ažuriranju vežbe: $e');
    }
  }

  Future<String> addPlan(String userId, String title) async {
    try {
      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('plans')
          .add({
            'title': title,
            'days': {},
            'isActive': false,
            'createdAt': DateTime.now().toIso8601String(),
          });
      return docRef.id;
    } catch (e) {
      throw Exception('Greška pri dodavanju plana: $e');
    }
  }

  Future<List<Plan>> getPlans(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('plans')
          .get();

      return snapshot.docs
          .map((doc) => Plan.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Greška pri preuzimanju planova: $e');
    }
  }

  Future<void> deletePlan(String userId, String planId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('plans')
          .doc(planId)
          .delete();
    } catch (e) {
      throw Exception('Greška pri brisanju plana: $e');
    }
  }

  Future<void> updatePlan(String userId, String planId, String newTitle) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('plans')
          .doc(planId)
          .update({'title': newTitle});
    } catch (e) {
      throw Exception('Greška pri ažuriranju plana: $e');
    }
  }

  Future<void> setPlanDay(
    String userId,
    String planId,
    String dayKey,
    String dayName,
    List<String> exerciseIds,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('plans')
          .doc(planId)
          .update({
            'days.$dayKey': {'name': dayName, 'exerciseIds': exerciseIds},
          });
    } catch (e) {
      throw Exception('Greška pri postavljanju dana u plan: $e');
    }
  }

  Future<void> setActivePlan(String userId, String planId) async {
    try {
      final allPlans = await getPlans(userId);
      for (var plan in allPlans) {
        if (plan.isActive) {
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('plans')
              .doc(plan.id)
              .update({'isActive': false});
        }
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('plans')
          .doc(planId)
          .update({'isActive': true});
    } catch (e) {
      throw Exception('Greška pri postavljanju aktivnog plana: $e');
    }
  }

  Future<Plan?> getActivePlan(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('plans')
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      return Plan.fromMap(snapshot.docs.first.data(), snapshot.docs.first.id);
    } catch (e) {
      throw Exception('Greška pri preuzimanju aktivnog plana: $e');
    }
  }

  Future<String> saveWorkout(String userId, Workout workout) async {
    try {
      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('workouts')
          .add(workout.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Greška pri čuvanju treninga: $e');
    }
  }

  Future<List<Workout>> getWorkouts(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('workouts')
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Workout.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Greška pri preuzimanju treninga: $e');
    }
  }

  Future<List<Workout>> getWorkoutsByDate(String userId, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('workouts')
          .where('date', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
          .where('date', isLessThan: endOfDay.toIso8601String())
          .get();

      return snapshot.docs
          .map((doc) => Workout.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Greška pri preuzimanju treninga za datum: $e');
    }
  }

  Future<String> addBodyMetric(
    String userId,
    double weight,
    DateTime date,
  ) async {
    try {
      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('bodyMetrics')
          .add({'weight': weight, 'date': date.toIso8601String()});
      return docRef.id;
    } catch (e) {
      throw Exception('Greška pri dodavanju mere: $e');
    }
  }

  Future<List<BodyMetric>> getBodyMetrics(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('bodyMetrics')
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => BodyMetric.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Greška pri preuzimanju mera: $e');
    }
  }

  Stream<List<BodyMetric>> watchBodyMetrics(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('bodyMetrics')
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => BodyMetric.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // ===== Javne vežbe (Public Exercises) =====
  
  Future<String> addPublicExercise(String name) async {
    try {
      final docRef = await _firestore.collection('publicExercises').add({
        'name': name,
        'createdAt': DateTime.now().toIso8601String(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Greška pri dodavanju javne vežbe: $e');
    }
  }

  Future<List<Exercise>> getPublicExercises() async {
    try {
      final snapshot = await _firestore
          .collection('publicExercises')
          .orderBy('name')
          .get();

      return snapshot.docs
          .map((doc) => Exercise.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Greška pri preuzimanju javnih vežbi: $e');
    }
  }

  Stream<List<Exercise>> watchPublicExercises() {
    return _firestore
        .collection('publicExercises')
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Exercise.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> deletePublicExercise(String exerciseId) async {
    try {
      await _firestore
          .collection('publicExercises')
          .doc(exerciseId)
          .delete();
    } catch (e) {
      throw Exception('Greška pri brisanju javne vežbe: $e');
    }
  }

  // ===== Javni planovi (Public Plans) =====
  
  Future<String> addPublicPlan(String title) async {
    try {
      final docRef = await _firestore.collection('publicPlans').add({
        'title': title,
        'days': {},
        'isActive': false,
        'createdAt': DateTime.now().toIso8601String(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Greška pri dodavanju javnog plana: $e');
    }
  }

  Future<List<Plan>> getPublicPlans() async {
    try {
      final snapshot = await _firestore
          .collection('publicPlans')
          .orderBy('title')
          .get();

      return snapshot.docs
          .map((doc) => Plan.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Greška pri preuzimanju javnih planova: $e');
    }
  }

  Stream<List<Plan>> watchPublicPlans() {
    return _firestore
        .collection('publicPlans')
        .orderBy('title')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Plan.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> deletePublicPlan(String planId) async {
    try {
      await _firestore.collection('publicPlans').doc(planId).delete();
    } catch (e) {
      throw Exception('Greška pri brisanju javnog plana: $e');
    }
  }
}
