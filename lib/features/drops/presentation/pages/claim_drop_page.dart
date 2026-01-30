import 'package:flutter/material.dart';
import 'package:art_drop_finder/features/drops/domain/entities/art_drop.dart';
import 'package:art_drop_finder/features/drops/presentation/controllers/drops_controller.dart';
import 'package:art_drop_finder/features/drops/presentation/widgets/drop_show_card.dart';
import 'package:art_drop_finder/core/widgets/app_logo.dart';

class ClaimDropPage extends StatefulWidget {
  final DropsController controller;
  final String dropId;

  const ClaimDropPage({
    super.key,
    required this.controller,
    required this.dropId,
  });

  @override
  State<ClaimDropPage> createState() => _ClaimDropPageState();
}

class _ClaimDropPageState extends State<ClaimDropPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _commentController = TextEditingController();
  bool _isSubmitting = false;
  bool _isSubmitted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      await widget.controller.claimDrop(
        dropId: widget.dropId,
        claimerName: _nameController.text,
        comment: _commentController.text,
      );
      if (!mounted) {
        return;
      }
      setState(() => _isSubmitted = true);
      _showMessage('Danke! Dein Drop wurde beansprucht.');
    } catch (error) {
      if (mounted) {
        _showMessage('Beanspruchen fehlgeschlagen: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const AppLogoTitle(title: 'Drop beanspruchen')),
      body: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, _) {
          ArtDrop? drop;
          for (final item in widget.controller.drops) {
            if (item.id == widget.dropId) {
              drop = item;
              break;
            }
          }
          final dropTitle = drop?.title ?? 'Unbekannter Drop';
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 800;
                    final form = _ClaimForm(
                      formKey: _formKey,
                      nameController: _nameController,
                      commentController: _commentController,
                      dropTitle: dropTitle,
                      isSubmitting: _isSubmitting,
                      isSubmitted: _isSubmitted,
                      onSubmit: _submit,
                    );
                    final card = drop == null
                        ? const SizedBox.shrink()
                        : DropShowCard(
                            drop: drop,
                            dropImages: widget.controller.dropImagesForDrop(
                              drop.id,
                            ),
                            environmentImages: widget.controller
                                .environmentImagesForDrop(drop.id),
                            claims: widget.controller.claimsForDrop(drop.id),
                            posts: widget.controller.postsForDrop(drop.id),
                          );
                    if (isWide) {
                      return Column(
                        children: [
                          Text(
                            "Gratulation!",
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          const SizedBox(height: 32),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: card),
                              const SizedBox(width: 24),
                              Expanded(child: form),
                            ],
                          ),
                        ],
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (drop != null) ...[card, const SizedBox(height: 16)],
                        form,
                      ],
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ClaimForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController commentController;
  final String dropTitle;
  final bool isSubmitting;
  final bool isSubmitted;
  final VoidCallback onSubmit;

  const _ClaimForm({
    required this.formKey,
    required this.nameController,
    required this.commentController,
    required this.dropTitle,
    required this.isSubmitting,
    required this.isSubmitted,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Du hast den Drop \"$dropTitle\" gefunden. "
            "Bitte fülle das Formular aus, um den Drop zu beanspruchen.",
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.warning, color: Colors.red),
            contentPadding: EdgeInsets.zero,
            subtitle: Text(
              "Bitte nehme den Art Drop nur mit wenn du ihn über die App beansprucht hast.",
              style: TextStyle(
                color: Colors.red[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: nameController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Dein Name oder Nickname',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Bitte gebe deinen Namen oder Nickname ein.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: commentController,
            textInputAction: TextInputAction.newline,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Kommentar (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: isSubmitting || isSubmitted ? null : onSubmit,
            child: Text(
              isSubmitting
                  ? 'Sende...'
                  : isSubmitted
                  ? 'Gesendet'
                  : 'Drop beanspruchen',
            ),
          ),
        ],
      ),
    );
  }
}
