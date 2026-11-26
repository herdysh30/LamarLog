import 'package:url_launcher/url_launcher.dart';

enum ContactKind { url, email, phone, unknown }

class ParsedContact {
  const ParsedContact({
    required this.kind,
    required this.primaryUri,
    this.whatsappUri,
  });

  final ContactKind kind;
  final Uri? primaryUri;
  final Uri? whatsappUri;

  bool get isLaunchable => primaryUri != null;
}

class ContactLauncher {
  const ContactLauncher._();

  static final RegExp _emailRegex = RegExp(
    r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
  );
  static final RegExp _phoneCharsRegex = RegExp(r'^[\d\s\+\-\(\)]+$');
  static final RegExp _domainLikeRegex = RegExp(
    r'^(?:www\.)?[a-zA-Z0-9-]+(?:\.[a-zA-Z]{2,})(?:/.*)?$',
  );

  /// Parses a raw recruiter contact string or vacancy URL into a launchable URI.
  static ParsedContact parse(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return const ParsedContact(kind: ContactKind.unknown, primaryUri: null);
    }

    // 1. Email address
    if (_emailRegex.hasMatch(trimmed)) {
      return ParsedContact(
        kind: ContactKind.email,
        primaryUri: Uri(scheme: 'mailto', path: trimmed),
      );
    }

    // 2. Explicit http/https URL
    final lower = trimmed.toLowerCase();
    if (lower.startsWith('http://') || lower.startsWith('https://')) {
      final uri = Uri.tryParse(trimmed);
      if (uri != null && uri.host.isNotEmpty) {
        return ParsedContact(kind: ContactKind.url, primaryUri: uri);
      }
    }

    // 3. Domain-like URL without scheme (e.g., linkedin.com/in/recruiter)
    if (!trimmed.contains(' ') && _domainLikeRegex.hasMatch(trimmed)) {
      final uri = Uri.tryParse('https://$trimmed');
      if (uri != null && uri.host.isNotEmpty) {
        return ParsedContact(kind: ContactKind.url, primaryUri: uri);
      }
    }

    // 4. Phone / WhatsApp number
    if (_phoneCharsRegex.hasMatch(trimmed)) {
      final digitsOnly = trimmed.replaceAll(RegExp(r'\D'), '');
      if (digitsOnly.length >= 7 && digitsOnly.length <= 16) {
        final telCleaned = trimmed.replaceAll(RegExp(r'[\s\-\(\)]'), '');
        final waDigits = _normalizeWhatsAppDigits(digitsOnly);
        return ParsedContact(
          kind: ContactKind.phone,
          primaryUri: Uri(scheme: 'tel', path: telCleaned),
          whatsappUri: Uri.parse('https://wa.me/$waDigits'),
        );
      }
    }

    return const ParsedContact(kind: ContactKind.unknown, primaryUri: null);
  }

  /// Normalizes Indonesian local numbers (08xx -> 628xx) while keeping
  /// international numbers intact.
  static String _normalizeWhatsAppDigits(String digits) {
    if (digits.startsWith('0') && digits.length >= 9) {
      return '62${digits.substring(1)}';
    }
    return digits;
  }

  /// Builds a Google Maps search URI for an office address or city/district.
  static Uri googleMapsUri(String location) {
    return Uri.https(
      'www.google.com',
      '/maps/search/',
      {'api': '1', 'query': location.trim()},
    );
  }

  static Future<bool> launch(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
