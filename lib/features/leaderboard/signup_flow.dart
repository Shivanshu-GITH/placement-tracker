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
  final nameCtl = TextEditingController(text: id.name);
  String? selectedCollege =
      (id.college != null && id.college!.isNotEmpty) ? id.college : null;
  if (!context.mounted) {
    nameCtl.dispose();
    return false;
  }

  // Already signed in? This becomes a plain "edit profile" sheet — no Google
  // button, since there's nothing to connect.
  final signedIn = auth.isSignedIn;

  final ok = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheet) => Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.xl,
          right: AppSpacing.xl,
          top: AppSpacing.lg,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(signedIn ? 'Edit your profile' : 'Join the leaderboard',
                style: Theme.of(ctx)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(
                signedIn
                    ? 'Update your display name and college.'
                    : 'Compete on streaks, XP and problems solved.',
                style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(ctx).colorScheme.onSurfaceVariant)),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: nameCtl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Display name'),
            ),
            const SizedBox(height: AppSpacing.md),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () async {
                final picked =
                    await showCollegePicker(ctx, current: selectedCollege);
                if (picked != null) {
                  setSheet(
                      () => selectedCollege = picked.isEmpty ? null : picked);
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'College',
                  suffixIcon: Icon(Icons.arrow_drop_down),
                ),
                child: Text(
                  selectedCollege ?? 'Select your college',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selectedCollege == null
                        ? Theme.of(ctx).colorScheme.onSurfaceVariant
                        : Theme.of(ctx).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
                onPressed: () => Navigator.pop(ctx, true),
                icon: Icon(signedIn ? Icons.check_rounded : Icons.login,
                    size: 18),
                label: Text(signedIn ? 'Save' : 'Continue with Google')),
          ],
        ),
      ),
    ),
  );
  // The sheet is closed now, so capture the typed value and release the
  // controller (it can't be disposed from inside the builder).
  final typed = nameCtl.text.trim();
  nameCtl.dispose();
  if (ok != true) return false;

  try {
    String? googleName;
    if (!auth.isSignedIn) googleName = await auth.signInWithGoogle();
    final name = typed.isNotEmpty
        ? typed
        : ((googleName != null && googleName.trim().isNotEmpty)
            ? googleName.trim()
            : 'Aspirant');
    final college =
        (selectedCollege != null && selectedCollege!.trim().isNotEmpty)
            ? selectedCollege!.trim()
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
