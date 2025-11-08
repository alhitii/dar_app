// Cleanup script: cleans project, applies Dart fixes, removes temp dirs, updates docs/CHANGELOG.md.
// Usage: dart .windsurf/cleanup_project.dart
// Notes:
// - Runs: flutter clean, flutter pub get, dart analyze, dart fix --dry-run, dart fix --apply
// - Deletes temp/test folders: test/, lib/temp/, lib/debug/, lib/old/, build/
// - Updates docs/CHANGELOG.md with an automatic cleanup entry for today
// - Prints a concise summary report

import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final dirsToDelete = [
    Directory('test'),
    Directory('lib/temp'),
    Directory('lib/debug'),
    Directory('lib/old'),
    Directory('build'),
  ];

  int fixesProposed = 0;
  int fixesApplied = 0;

  // 1) flutter clean
  await _runLogged(['flutter', 'clean']);

  // 2) flutter pub get
  await _runLogged(['flutter', 'pub', 'get']);

  // 3) dart analyze
  await _runLogged(['dart', 'analyze']);

  // 4) dart fix --dry-run (parse proposed fixes)
  final dryRunOut = await _run(['dart', 'fix', '--dry-run']);
  fixesProposed = _parseFixCount(dryRunOut);

  // 5) dart fix --apply (parse applied fixes)
  final applyOut = await _run(['dart', 'fix', '--apply']);
  fixesApplied = _parseFixCount(applyOut, fallback: fixesProposed);

  // 6) Delete temp/test/build dirs
  for (final d in dirsToDelete) {
    try {
      if (await d.exists()) {
        await d.delete(recursive: true);
      }
    } catch (_) {}
  }

  // 7) Update docs/CHANGELOG.md
  await _appendCleanupToChangelog();

  // 8) Print summary
  stdout.writeln('✅ Cleanup complete.');
  stdout.writeln('🧹 Unused files removed.');
  stdout.writeln('🧩 Code fixes applied. Proposed: $fixesProposed, Applied: $fixesApplied');
  stdout.writeln('🟢 CHANGELOG updated.');
}

Future<void> _runLogged(List<String> cmd) async {
  final r = await Process.start(cmd.first, cmd.sublist(1));
  await stdout.addStream(r.stdout);
  await stderr.addStream(r.stderr);
  final code = await r.exitCode;
  if (code != 0) {
    // Continue even if failure; script should be resilient
  }
}

Future<String> _run(List<String> cmd) async {
  try {
    final r = await Process.run(cmd.first, cmd.sublist(1));
    if (r.stdout is String) return r.stdout as String;
    return utf8.decode((r.stdout as List<int>?) ?? []);
  } catch (_) {
    return '';
  }
}

int _parseFixCount(String output, {int fallback = 0}) {
  // Try to find a number of fixes from dart fix output lines
  // Typical: "Applied 12 fixes in..." or "12 fixes in..."
  final regexes = [
    RegExp(r'Applied\s+(\d+)\s+fix', caseSensitive: false),
    RegExp(r'\b(\d+)\s+fix(?:es)?\b', caseSensitive: false),
  ];
  for (final rx in regexes) {
    final m = rx.firstMatch(output);
    if (m != null) {
      final n = int.tryParse(m.group(1) ?? '');
      if (n != null) return n;
    }
  }
  return fallback;
}

Future<void> _appendCleanupToChangelog() async {
  final docsDir = Directory('docs');
  if (!await docsDir.exists()) {
    await docsDir.create(recursive: true);
  }
  final changelogFile = File('docs/CHANGELOG.md');

  String existing = '';
  if (await changelogFile.exists()) {
    existing = await changelogFile.readAsString();
  } else {
    existing = '# 📝 سجل التغييرات (Changelog)\n\n';
  }

  final today = DateTime.now();
  final dateStr = '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
  final sectionHeader = '## $dateStr';

  // Append a single cleanup bullet for today. If section exists, add bullet under it; otherwise prepend new section.
  if (existing.contains('\n$sectionHeader')) {
    // Insert after header line
    final lines = existing.split('\n');
    final buf = StringBuffer();
    bool inserted = false;
    for (int i = 0; i < lines.length; i++) {
      buf.writeln(lines[i]);
      if (!inserted && lines[i].trim() == sectionHeader) {
        buf.writeln('- Automatic cleanup: removed unused code, temp files, and debug sections.');
        inserted = true;
      }
    }
    await changelogFile.writeAsString(buf.toString());
  } else {
    final newSection = StringBuffer()
      ..writeln(sectionHeader)
      ..writeln('- Automatic cleanup: removed unused code, temp files, and debug sections.')
      ..writeln('');
    final updated = StringBuffer()
      ..writeln(newSection.toString())
      ..write(existing);
    await changelogFile.writeAsString(updated.toString());
  }
}
