// Post-build update script: tracks future changes and updates docs/CHANGELOG.md only.
// Usage: dart .windsurf/post_build_update.dart
// Behavior:
// - Uses Git if available to detect modified files since last recorded commit.
// - Records the latest HEAD commit in .windsurf/.post_build_state.json.
// - Appends an entry to docs/CHANGELOG.md with today's date and each modified file:
//     ## YYYY-MM-DD
//     - Future change detected: <file>
// - Never regenerates or modifies any other docs.
// - Prints: "🟢 No docs regenerated. Only CHANGELOG updated if needed."

import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final projectRoot = Directory.current.path;
  final windsrfDir = Directory('.windsurf');
  final stateFile = File('.windsurf/.post_build_state.json');
  final changelogFile = File('docs/CHANGELOG.md');

  // Ensure .windsurf exists
  if (!await windsrfDir.exists()) {
    await windsrfDir.create(recursive: true);
  }

  // Load last known commit
  String? lastKnownCommit;
  if (await stateFile.exists()) {
    try {
      final data = jsonDecode(await stateFile.readAsString()) as Map<String, dynamic>;
      lastKnownCommit = data['lastKnownCommit'] as String?;
    } catch (_) {}
  }

  // Detect if Git repo
  final isGitRepo = await _isGitRepo();

  List<String> changedFiles = [];
  if (isGitRepo) {
    final head = (await _run(['git', 'rev-parse', 'HEAD'])).trim();

    if (lastKnownCommit != null && lastKnownCommit!.isNotEmpty) {
      // Files changed between lastKnownCommit and HEAD
      final diff = await _run(['git', 'diff', '--name-only', lastKnownCommit!, head]);
      changedFiles = diff
          .split('\n')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    } else {
      // First run: consider current working tree changes only
      final status = await _run(['git', 'status', '--porcelain']);
      changedFiles = status
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .map((l) => l.length > 3 ? l.substring(3) : l)
          .toList();
    }

    // Exclude docs changes and self/state to avoid self-triggering
    changedFiles = changedFiles.where((p) {
      if (p.startsWith('docs/CHANGELOG.md')) return false; // avoid immediate re-detection
      if (p.startsWith('docs/')) return false; // ignore documentation folder per requirement
      if (p.startsWith('.windsurf/')) return false;
      if (p.startsWith('.git/')) return false;
      if (p.startsWith('build/') || p.startsWith('build\\')) return false;
      return true;
    }).toList();

    // If there are changes, append to docs/CHANGELOG.md
    if (changedFiles.isNotEmpty) {
      await _appendChangesToChangelog(changedFiles, changelogFile);
    }

    // Update state with current HEAD (even if no changes appended)
    await stateFile.writeAsString(jsonEncode({'lastKnownCommit': head}), flush: true);
  } else {
    // Fallback: no Git, do nothing except ensure message print
  }

  // Always print this message per requirement
  stdout.writeln('🟢 No docs regenerated. Only CHANGELOG updated if needed.');
}

Future<bool> _isGitRepo() async {
  try {
    final result = await Process.run('git', ['rev-parse', '--is-inside-work-tree']);
    if (result.exitCode == 0) {
      return (result.stdout as String).trim() == 'true';
    }
  } catch (_) {}
  return false;
}

Future<String> _run(List<String> cmd, {String? cwd}) async {
  final result = await Process.run(cmd.first, cmd.sublist(1), workingDirectory: cwd);
  if (result.exitCode != 0) {
    return '';
  }
  return (result.stdout as String?) ?? '';
}

Future<void> _appendChangesToChangelog(List<String> files, File changelogFile) async {
  // Ensure docs/ exists
  final docsDir = Directory('docs');
  if (!await docsDir.exists()) {
    await docsDir.create(recursive: true);
  }

  final today = DateTime.now();
  final dateStr = '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

  String existing = '';
  if (await changelogFile.exists()) {
    existing = await changelogFile.readAsString();
  } else {
    // Initialize with a header if new
    existing = '# 📝 سجل التغييرات (Changelog)\n\n';
  }

  final buffer = StringBuffer();

  // If today's section exists, append to it; otherwise, add new section.
  final sectionHeader = '## $dateStr';
  if (existing.contains('\n$sectionHeader')) {
    // Insert after header line
    final lines = existing.split('\n');
    bool inToday = false;
    for (final line in lines) {
      buffer.writeln(line);
      if (line.trim() == sectionHeader) {
        inToday = true;
        // Append bullets immediately after header
        for (final f in files) {
          buffer.writeln('- Future change detected: $f');
        }
        continue;
      }
      // Stop special handling when next header appears
      if (inToday && line.startsWith('## ') && line.trim() != sectionHeader) {
        inToday = false;
      }
    }
  } else {
    // Prepend new section to top for recency
    final newSection = StringBuffer()
      ..writeln(sectionHeader)
      ..writelnAll(files.map((f) => '- Future change detected: $f'))
      ..writeln('');
    buffer
      ..writeln(newSection.toString())
      ..write(existing);
  }

  await changelogFile.writeAsString(buffer.toString());
}

extension _WritelnAll on StringBuffer {
  void writelnAll(Iterable items) {
    for (final i in items) {
      writeln(i);
    }
  }
}
