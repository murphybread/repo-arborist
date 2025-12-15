import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repo_arborist/features/contact/models/contact_message_model.dart';

/// Provider for contact controller
final contactControllerProvider =
    AsyncNotifierProvider<ContactController, void>(
      ContactController.new,
    );

/// Contact controller to handle message submission
class ContactController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // No initial state needed
  }

  /// Submit contact message to Firestore
  Future<void> submitMessage({
    required String patOwner,
    required String repositoryOwner,
    required String name,
    required String content,
    ContactType? type,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final message = ContactMessageModel(
        patOwner: patOwner.trim(),
        repositoryOwner: repositoryOwner.trim(),
        name: name.trim(),
        content: content.trim(),
        timestamp: DateTime.now(),
        type: type,
      );

      // Store in Firestore using 'githubjson' database
      final firestore = FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'githubjson',
      );

      await firestore.collection('contact_messages').add(message.toJson());

      debugPrint('Contact message submitted: ${message.name}');
    });
  }
}
