import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repo_arborist/features/contact/controllers/contact_controller.dart';
import 'package:repo_arborist/features/contact/models/contact_message_model.dart';

/// Contact form screen
class ContactScreen extends ConsumerStatefulWidget {
  /// Constructor
  const ContactScreen({
    required this.patOwner,
    required this.repositoryOwner,
    super.key,
  });

  /// PAT owner username (who is logged in)
  final String patOwner;

  /// Repository owner username (currently viewing)
  final String repositoryOwner;

  @override
  ConsumerState<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends ConsumerState<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contentController = TextEditingController();
  ContactType? _selectedType;

  @override
  void dispose() {
    _nameController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await ref.read(contactControllerProvider.notifier).submitMessage(
          patOwner: widget.patOwner,
          repositoryOwner: widget.repositoryOwner,
          name: _nameController.text,
          content: _contentController.text,
          type: _selectedType,
        );

    final state = ref.read(contactControllerProvider);

    if (!mounted) {
      return;
    }

    state.when(
      data: (_) {
        // Success
        showDialog<void>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            title: Text(
              'contact.success_title'.tr(),
              style: const TextStyle(color: Colors.white),
            ),
            content: Text(
              'contact.success_message'.tr(),
              style: const TextStyle(color: Color(0xFF94A3B8)),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  Navigator.of(context).pop();
                },
                child: Text(
                  'common.ok'.tr(),
                  style: const TextStyle(color: Color(0xFF14B8A6)),
                ),
              ),
            ],
          ),
        );
      },
      loading: () {},
      error: (error, stack) {
        // Error
        showDialog<void>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            title: Text(
              'common.error'.tr(),
              style: const TextStyle(color: Colors.white),
            ),
            content: Text(
              'contact.error_submit_failed'.tr(),
              style: const TextStyle(color: Color(0xFF94A3B8)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(
                  'common.ok'.tr(),
                  style: const TextStyle(color: Color(0xFF14B8A6)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(contactControllerProvider);
    final isLoading = state is AsyncLoading;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F1729),
              Color(0xFF1E293B),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  border: const Border(
                    bottom: BorderSide(
                      color: Color(0xFF14B8A6),
                      width: 2,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      offset: const Offset(0, 2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0x2014B8A6),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0x5014B8A6),
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Color(0xFF14B8A6),
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'contact.title'.tr(),
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Form
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Name field
                        Text(
                          'contact.name_label'.tr(),
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'contact.name_hint'.tr(),
                            hintStyle: const TextStyle(
                              color: Color(0xFF64748B),
                            ),
                            filled: true,
                            fillColor: const Color(0xFF1E293B),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0x5014B8A6),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0x5014B8A6),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF14B8A6),
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'contact.error_empty_name'.tr();
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 24),

                        // Type dropdown
                        Text(
                          'contact.type_label'.tr(),
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<ContactType>(
                          initialValue: _selectedType,
                          dropdownColor: const Color(0xFF1E293B),
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFF1E293B),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0x5014B8A6),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0x5014B8A6),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF14B8A6),
                                width: 2,
                              ),
                            ),
                          ),
                          items: ContactType.values.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type.translationKey.tr()),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedType = value;
                            });
                          },
                        ),

                        const SizedBox(height: 24),

                        // Content field
                        Text(
                          'contact.content_label'.tr(),
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _contentController,
                          style: const TextStyle(color: Colors.white),
                          maxLines: 8,
                          decoration: InputDecoration(
                            hintText: 'contact.content_hint'.tr(),
                            hintStyle: const TextStyle(
                              color: Color(0xFF64748B),
                            ),
                            filled: true,
                            fillColor: const Color(0xFF1E293B),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0x5014B8A6),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0x5014B8A6),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF14B8A6),
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'contact.error_empty_content'.tr();
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 32),

                        // Submit button
                        ElevatedButton(
                          onPressed: isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF14B8A6),
                            disabledBackgroundColor: const Color(0x5014B8A6),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  'contact.submit_button'.tr(),
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
