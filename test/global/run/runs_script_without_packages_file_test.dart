// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:path/path.dart' as p;
import 'package:pub/src/io.dart';
import 'package:test/test.dart';

import '../../descriptor.dart' as d;
import '../../test_pub.dart';

void main() {
  test('runs a snapshotted script without a .dart_tool/package_config file',
      () async {
    final server = await servePackages();
    server.serve('foo', '1.0.0', contents: [
      d.dir('bin', [d.file('script.dart', "main(args) => print('ok');")])
    ]);

    await runPub(args: ['global', 'activate', 'foo']);

    // Mimic the global packages installed by pub <1.12, which didn't create a
    // .packages file for global installs.
    deleteEntry(p.join(d.sandbox, cachePath,
        'global_packages/foo/.dart_tool/package_config.json'));

    var pub = await pubRun(global: true, args: ['foo:script']);
    expect(pub.stdout, emitsThrough('ok'));
    await pub.shouldExit();
  });

  test(
      'runs an unsnapshotted script without a .dart_tool/package_config.json file',
      () async {
    await d.dir('foo', [
      d.libPubspec('foo', '1.0.0'),
      d.dir('bin', [d.file('foo.dart', "main() => print('ok');")])
    ]).create();

    await runPub(args: ['global', 'activate', '--source', 'path', '../foo']);

    deleteEntry(p.join(d.sandbox, cachePath,
        'global_packages/foo/.dart_tool/package_config.json'));

    var pub = await pubRun(global: true, args: ['foo']);
    expect(pub.stdout, emitsThrough('ok'));
    await pub.shouldExit();
  });
}
