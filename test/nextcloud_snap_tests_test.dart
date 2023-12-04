import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:nextcloud/nextcloud.dart';

void main() {
  group('NextcloudSnapTests', () {
    final random = Random();

    final client = NextcloudClient(
      Uri.parse('http://localhost'),
      loginName: 'admin',
      password: 'admin',
    );

    for (var i = 0; i < 20; i++) {
      test('upload small files $i', () async {
        final path = PathUri.parse('$i.bin');
        final length = i * 1024;
        final data = Uint8List.fromList(
            List.generate(length, (final index) => random.nextInt(256)));

        final putResponse = await client.webdav.put(
          data,
          path,
        );
        expect(putResponse.statusCode, 201);

        final propfindResponse = await client.webdav.propfind(
          path,
          prop: WebDavPropWithoutValues.fromBools(
            davgetcontentlength: true,
            ocsize: true,
          ),
          depth: WebDavDepth.zero,
        );
        final props = propfindResponse.responses.single.propstats.single.prop;
        expect(props.davgetcontentlength, length);
        expect(props.ocsize, length);

        final getResponse = await client.webdav.get(path);
        expect(getResponse, data);
      });
    }
  });
}
