import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_dimens.dart';
import '../../providers/providers.dart';
import 'college_picker.dart';

/// Shared "sign up / join the leaderboard" flow used by the welcome screen, the
/// leaderboard guest banner and the profile tab. Collects a display name and
/// college, signs in with Google, syncs the user's stats, and clears guest mode.
///
/// Returns true if the user ended up signed in.
Future<bool> showSignUpFlow(BuildContext context, WidgetRef ref) async {
  final auth = ref.read(leaderboardAuthProvider);
  if (auth == null) {
    _toast(context, 'Leaderboard backend is not available.');
    return false;
  }
  final id = await ref.read(lbIdentityProvider.future);
  if (!context.mounted) return false;

  // Already signed in? This becomes a plain "edit profile" sheet — no Google
  // button, since there's nothing to connect.
  final signedIn = auth.isSignedIn;

  final result = await showModalBottomSheet<({String name, String? college})>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _IdentitySheet(
      initialName: id.name,
      initialCollege:
          (id.college != null && id.college!.isNotEmpty) ? id.college : null,
      signedIn: signedIn,
    ),
  );
  if (result == null) return false;
  final typed = result.name;
  final selectedCollege = result.college;

  try {
    String? googleName;
    if (!auth.isSignedIn) googleName = await auth.signInWithGoogle();
    final name = typed.isNotEmpty
        ? typed
        : ((googleName != null && googleName.trim().isNotEmpty)
            ? googleName.trim()
            : 'Aspirant');
    final college = (selectedCollege != null && selectedCollege.trim().isNotEmpty)
        ? selectedCollege.trim()
        : null;
    await saveLbIdentity(ref, name, college);
    await ref
        .read(leaderboardRepositoryProvider)
        .syncMyStats(ref.read(myStatsProvider), name: name, college: college);
    await setGuestMode(ref, false);
    ref.invalidate(boardPoolProvider);
    if (context.mounted) {
      _toast(context, signedIn ? 'Profile updated' : 'You\'re on the leaderboard! 🏆');
    }
    return true;
  } catch (e) {
    if (context.mounted) _toast(context, 'Could not join: $e');
    return false;
  }
}

void _toast(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}


/// The join / edit-profile sheet. It owns its controller so the dispose happens
/// when the route leaves the tree — releasing it right after `await
/// showModalBottomSheet` is too early, because that future completes when the
/// pop *starts*, while the sheet is still animating out and rebuilding.
class _IdentitySheet extends StatefulWidget {
  const _IdentitySheet({
    required this.initialName,
    required this.initialCollege,
    required this.signedIn,
  });
  final String initialName;
  final String? initialCollege;
  final bool signedIn;

  @override
  State<_IdentitySheet> createState() => _IdentitySheetState();
}

class _IdentitySheetState extends State<_IdentitySheet> {
  late final _nameCtl = TextEditingController(text: widget.initialName);
  late String? _college = widget.initialCollege;

  @override
  void dispose() {
    _nameCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final media = MediaQuery.of(context);
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: media.size.height * 0.9),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: AppSpacing.xl,
            right: AppSpacing.xl,
            top: AppSpacing.lg,
            bottom: media.viewInsets.bottom + AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.signedIn ? 'Edit your profile' : 'Join the leaderboard',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(
                  widget.signedIn
                      ? 'Update your display name and college.'
                      : 'Compete on streaks, XP and problems solved.',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _nameCtl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Display name'),
              ),
              const SizedBox(height: AppSpacing.md),
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () async {
                  final picked =
                      await showCollegePicker(context, current: _college);
                  if (picked != null && mounted) {
                    setState(() => _college = picked.isEmpty ? null : picked);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'College',
                    suffixIcon: Icon(Icons.arrow_drop_down),
                  ),
                  child: Text(
                    _college ?? 'Select your college',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _college == null
                          ? theme.colorScheme.onSurfaceVariant
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                  onPressed: () => Navigator.pop(
                      context, (name: _nameCtl.text.trim(), college: _college)),
                  icon: Icon(widget.signedIn ? Icons.check_rounded : Icons.login,
                      size: 18),
                  label: Text(widget.signedIn ? 'Save' : 'Continue with Google')),
            ],
          ),
        ),
      ),
    );
  }
}
