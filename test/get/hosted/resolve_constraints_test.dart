// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';

import '../../descriptor.dart' as d;
import '../../test_pub.dart';

void main() {
  test('resolves version constraints from a pub server', () async {
    await servePackages()
      ..serve('foo', '1.2.3', deps: {'baz': '>=2.0.0'})
      ..serve('bar', '2.3.4', deps: {'baz': '<3.0.0'})
      ..serve('baz', '2.0.3')
      ..serve('baz', '2.0.4')
      ..serve('baz', '3.0.1');

    await d.appDir(dependencies: {'foo': 'any', 'bar': 'any'}).create();

    await pubGet();

    await d.cacheDir({
      'foo': '1.2.3',
      'bar': '2.3.4',
      'baz': '2.0.4',
    }).validate();
    await d.appPackageConfigFile([
      d.packageConfigEntry(name: 'foo', version: '1.2.3'),
      d.packageConfigEntry(name: 'bar', version: '2.3.4'),
      d.packageConfigEntry(name: 'baz', version: '2.0.4'),
    ]).validate();
  });
}
