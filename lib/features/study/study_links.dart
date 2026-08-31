import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Builds "study elsewhere" deep links for a topic and opens them, so a learner
/// can jump straight from a note into a Google search or a primed ChatGPT chat.
class StudyLinks {
  const StudyLinks._();

  /// A Google search scoped to interview/GATE prep for [title].
  static String google(String title, {String subject = ''}) {
    final q = subject.isEmpty ? '$title interview' : '$title $subject interview';
    return 'https://www.google.com/search?q=${Uri.encodeQueryComponent(q)}';
  }

  /// A ChatGPT link pre-filled with a "teach me" prompt. `?q=` is auto-submitted
  /// by chatgpt.com when the user is signed in.
  static String chatgpt(String title, {String subject = ''}) {
    final ctx = subject.isEmpty ? '' : ' in $subject';
    final prompt =
        'Explain "$title"$ctx for a placement/tech interview. Cover the core '
        'idea, a simple example, common follow-up questions, and one gotcha. '
        'Keep it concise and beginner-friendly.';
    return 'https://chatgpt.com/?q=${Uri.encodeQueryComponent(prompt)}';
  }

  /// Opens [url] in the external browser; on failure copies it to the clipboard
  /// and shows a snackbar. Safe to call from any widget with a [context].
  static Future<void> open(BuildContext context, String url) async {
    if (url.isEmpty) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    final uri = Uri.tryParse(url);
    if (uri != null &&
        await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      return;
    }
    await Clipboard.setData(ClipboardData(text: url));
    messenger?.showSnackBar(
      const SnackBar(content: Text('Link copied to clipboard')),
    );
  }
}
