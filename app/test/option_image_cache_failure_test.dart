import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kospia/features/auth/services/session_service.dart';
import 'package:kospia/features/identify/widgets/option_image.dart';
import 'package:provider/provider.dart';

class _NoSessionService extends SessionService {
  @override
  Future<KospiaSession?> loadSession() async => null;
}

class _DelayedSessionService extends SessionService {
  final List<Completer<KospiaSession?>> requests = [];

  @override
  Future<KospiaSession?> loadSession() {
    final request = Completer<KospiaSession?>();
    requests.add(request);
    return request.future;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async {
          throw PlatformException(code: 'unavailable');
        });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });
  });

  testWidgets('cache directory failure displays the placeholder', (
    tester,
  ) async {
    await tester.pumpWidget(
      Provider<SessionService>.value(
        value: _NoSessionService(),
        child: const MaterialApp(
          home: OptionImage(
            imageId: 'cache-failure-test',
            placeholder: Text('No image'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('No image'), findsOneWidget);
  });

  testWidgets('old image completion cannot finish a newer load', (
    tester,
  ) async {
    final session = _DelayedSessionService();

    Widget image(String id) => Provider<SessionService>.value(
      value: session,
      child: MaterialApp(
        home: OptionImage(imageId: id, placeholder: const Text('No image')),
      ),
    );

    await tester.pumpWidget(image('race-old'));
    await tester.pump();
    expect(session.requests, hasLength(1));

    await tester.pumpWidget(image('race-new'));
    await tester.pump();
    expect(session.requests, hasLength(2));

    session.requests.first.complete(null);
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('No image'), findsNothing);

    session.requests.last.complete(null);
    await tester.pumpAndSettle();
    expect(find.text('No image'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
