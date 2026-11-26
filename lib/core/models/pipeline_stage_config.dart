import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../enums/application_enums.dart';

enum StageColorKey {
  slate,
  indigo,
  blue,
  amber,
  teal,
  violet,
  rose,
  emerald;

  Color dotColor(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return switch (this) {
      StageColorKey.slate =>
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
      StageColorKey.indigo =>
        isDark ? const Color(0xFF818CF8) : const Color(0xFF4F46E5),
      StageColorKey.blue =>
        isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
      StageColorKey.amber =>
        isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
      StageColorKey.teal =>
        isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0D9488),
      StageColorKey.violet =>
        isDark ? const Color(0xFFA78BFA) : const Color(0xFF7C3AED),
      StageColorKey.rose =>
        isDark ? const Color(0xFFFB7185) : const Color(0xFFE11D48),
      StageColorKey.emerald =>
        isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
    };
  }

  (Color bg, Color fg) chipColors(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return switch (this) {
      StageColorKey.slate => isDark
          ? (const Color(0xFF252D3F), const Color(0xFFCBD5E1))
          : (const Color(0xFFF1F5F9), const Color(0xFF334155)),
      StageColorKey.indigo => isDark
          ? (const Color(0xFF272456), const Color(0xFFC7D2FE))
          : (const Color(0xFFE2DFFF), const Color(0xFF312E81)),
      StageColorKey.blue => isDark
          ? (const Color(0xFF172C4D), const Color(0xFFBFDBFE))
          : (const Color(0xFFDBEAFE), const Color(0xFF1E3A8A)),
      StageColorKey.amber => isDark
          ? (const Color(0xFF3E2C0A), const Color(0xFFFDE68A))
          : (const Color(0xFFFEF3C7), const Color(0xFF92400E)),
      StageColorKey.teal => isDark
          ? (const Color(0xFF0B3632), const Color(0xFF99F6E4))
          : (const Color(0xFFCCFBF1), const Color(0xFF115E59)),
      StageColorKey.violet => isDark
          ? (const Color(0xFF2E1A4D), const Color(0xFFDDD6FE))
          : (const Color(0xFFEDE9FE), const Color(0xFF5B21B6)),
      StageColorKey.rose => isDark
          ? (const Color(0xFF471526), const Color(0xFFFECDD3))
          : (const Color(0xFFFFE4E6), const Color(0xFF9F1239)),
      StageColorKey.emerald => isDark
          ? (const Color(0xFF0A3327), const Color(0xFFA7F3D0))
          : (const Color(0xFFD1FAE5), const Color(0xFF065F46)),
    };
  }
}

class PipelineStageConfig extends Equatable {
  const PipelineStageConfig({
    required this.id,
    required this.label,
    required this.colorKey,
  });

  /// Stable stage identifier stored in `JobApplication.currentStatus` and
  /// `StatusTransition.toStatus`. Built-in stages keep their enum `.name`
  /// ('wishlist', 'applied', 'screening', 'interview', 'offering').
  final String id;

  /// Display title shown in Kanban columns, forms, detail badges, & analytics.
  final String label;

  /// Semantic dot/badge color key.
  final StageColorKey colorKey;

  PipelineStageConfig copyWith({
    String? id,
    String? label,
    StageColorKey? colorKey,
  }) {
    return PipelineStageConfig(
      id: id ?? this.id,
      label: label ?? this.label,
      colorKey: colorKey ?? this.colorKey,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'colorKey': colorKey.name,
      };

  static PipelineStageConfig fromJson(Map<String, dynamic> json) {
    final colorName = json['colorKey'] as String?;
    return PipelineStageConfig(
      id: (json['id'] as String? ?? '').trim(),
      label: (json['label'] as String? ?? '').trim(),
      colorKey: StageColorKey.values.firstWhere(
        (c) => c.name == colorName,
        orElse: () => StageColorKey.indigo,
      ),
    );
  }

  /// Default 5 active pipeline stages matching the MVP PRD.
  static List<PipelineStageConfig> defaults({bool isId = false}) => [
        const PipelineStageConfig(
          id: 'wishlist',
          label: 'Wishlist',
          colorKey: StageColorKey.slate,
        ),
        PipelineStageConfig(
          id: 'applied',
          label: isId ? 'Dilamar' : 'Applied',
          colorKey: StageColorKey.indigo,
        ),
        const PipelineStageConfig(
          id: 'screening',
          label: 'Screening',
          colorKey: StageColorKey.blue,
        ),
        const PipelineStageConfig(
          id: 'interview',
          label: 'Interview',
          colorKey: StageColorKey.amber,
        ),
        const PipelineStageConfig(
          id: 'offering',
          label: 'Offering',
          colorKey: StageColorKey.teal,
        ),
      ];

  static StageColorKey defaultColorForBuiltIn(String statusId) {
    return switch (statusId) {
      'wishlist' => StageColorKey.slate,
      'applied' => StageColorKey.indigo,
      'screening' => StageColorKey.blue,
      'interview' => StageColorKey.amber,
      'offering' => StageColorKey.teal,
      _ => StageColorKey.violet,
    };
  }

  static final Set<String> terminalStatusIds =
      ApplicationStatus.terminalOutcomes.map((e) => e.name).toSet();

  static bool isTerminalStatusId(String statusId) =>
      terminalStatusIds.contains(statusId);

  static String encodeList(List<PipelineStageConfig> stages) {
    return jsonEncode(stages.map((e) => e.toJson()).toList());
  }

  static List<PipelineStageConfig>? decodeList(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      final parsed = <PipelineStageConfig>[];
      final seen = <String>{};
      for (final item in decoded) {
        if (item is! Map<String, dynamic>) continue;
        final cfg = PipelineStageConfig.fromJson(item);
        if (cfg.id.isEmpty ||
            cfg.label.isEmpty ||
            isTerminalStatusId(cfg.id) ||
            seen.contains(cfg.id)) {
          continue;
        }
        seen.add(cfg.id);
        parsed.add(cfg);
      }
      return parsed.isEmpty ? null : parsed;
    } catch (_) {
      return null;
    }
  }

  /// Generates a clean unique ID for a new custom stage.
  static String generateCustomId(String label, Iterable<String> existingIds) {
    final existing = existingIds.toSet();
    final slug = label
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    final base = slug.isEmpty ? 'stage' : 'custom_$slug';
    if (!existing.contains(base) && !isTerminalStatusId(base)) return base;
    var i = 2;
    while (existing.contains('${base}_$i') || isTerminalStatusId('${base}_$i')) {
      i++;
    }
    return '${base}_$i';
  }

  @override
  List<Object?> get props => [id, label, colorKey];
}
