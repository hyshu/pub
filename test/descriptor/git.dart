// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:path/path.dart' as p;
import 'package:pub/src/git.dart' as git;
import 'package:test_descriptor/test_descriptor.dart';

/// Describes a Git repository and its contents.
class GitRepoDescriptor extends DirectoryDescriptor {
  GitRepoDescriptor(super.name, List<Descriptor> super.contents);

  /// Creates the Git repository and commits the contents.
  @override
  Future create([String? parent]) async {
    await super.create(parent);
    await _runGitCommands(parent, [
      ['init'],
      ['config', 'core.excludesfile', ''],
      ['add', '.'],
      ['commit', '-m', 'initial commit', '--allow-empty'],
    ]);
  }

  /// Writes this descriptor to the filesystem, then commits any changes from
  /// the previous structure to the Git repo.
  ///
  /// [parent] defaults to [sandbox].
  Future commit([String? parent]) async {
    await super.create(parent);
    await _runGitCommands(parent, [
      ['add', '.'],
      ['commit', '-m', 'update'],
    ]);
  }

  /// Adds a tag named [tag] to the repo described by `this`.
  ///
  /// [parent] defaults to [sandbox].
  Future tag(String tag, [String? parent]) async {
    await _runGitCommands(parent, [
      ['tag', '-a', tag, '-m', 'Some message'],
    ]);
  }

  /// Return a Future that completes to the commit in the git repository
  /// referred to by [ref].
  ///
  /// [parent] defaults to [sandbox].
  Future<String> revParse(String ref, [String? parent]) async {
    final output = await _runGit(['rev-parse', ref], parent);
    return (output as String).trim();
  }

  /// Runs a Git command in this repository.
  ///
  /// [parent] defaults to [sandbox].
  Future<void> runGit(List<String> args, [String? parent]) =>
      _runGit(args, parent);

  Future<dynamic> _runGit(List<String> args, String? parent) {
    // Explicitly specify the committer information. Git needs this to commit
    // and we don't want to rely on the buildbots having this already set up.
    final environment = {
      'GIT_AUTHOR_NAME': 'Pub Test',
      'GIT_AUTHOR_EMAIL': 'pub@dartlang.org',
      'GIT_COMMITTER_NAME': 'Pub Test',
      'GIT_COMMITTER_EMAIL': 'pub@dartlang.org',
      // To make stable commits ids we fix the date.
      'GIT_COMMITTER_DATE': DateTime.utc(1970).toIso8601String(),
      'GIT_AUTHOR_DATE': DateTime.utc(1970).toIso8601String(),
    };

    return git.run(
      args,
      workingDir: p.join(parent ?? sandbox, name),
      environment: environment,
    );
  }

  Future _runGitCommands(String? parent, List<List<String>> commands) async {
    for (var command in commands) {
      await _runGit(command, parent);
    }
  }
}
