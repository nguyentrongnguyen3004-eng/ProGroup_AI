import 'package:flutter_test/flutter_test.dart';
import 'package:progroup_ai_frontend/services/data_cache_service.dart';

void main() {
  setUp(() {
    DataCacheService.instance.setUserScope('guest');
    DataCacheService.instance.invalidateAll();
  });

  test('getOrFetch caches results within TTL and respects forceRefresh', () async {
    var calls = 0;
    Future<String> fetcher() async {
      calls++;
      return 'value-$calls';
    }

    final first = await DataCacheService.instance.getOrFetch('k1', fetcher);
    final second = await DataCacheService.instance.getOrFetch('k1', fetcher);
    final refreshed = await DataCacheService.instance.getOrFetch(
      'k1',
      fetcher,
      forceRefresh: true,
    );

    expect(first, 'value-1');
    expect(second, 'value-1');
    expect(refreshed, 'value-2');
    expect(calls, 2);
  });

  test('getOrFetch coalesces concurrent in-flight requests for the same key', () async {
    var calls = 0;
    Future<int> slowFetcher() async {
      calls++;
      await Future<void>.delayed(const Duration(milliseconds: 20));
      return 42;
    }

    final results = await Future.wait([
      DataCacheService.instance.getOrFetch('shared', slowFetcher),
      DataCacheService.instance.getOrFetch('shared', slowFetcher),
      DataCacheService.instance.getOrFetch('shared', slowFetcher),
    ]);

    expect(results, [42, 42, 42]);
    expect(calls, 1);
  });

  test('setUserScope isolates cached entries across accounts', () async {
    DataCacheService.instance.setUserScope('sv001');
    final svVal = await DataCacheService.instance.getOrFetch(
      'profile',
      () async => 'student-sv001',
    );
    expect(svVal, 'student-sv001');

    DataCacheService.instance.setUserScope('gv001');
    final gvVal = await DataCacheService.instance.getOrFetch(
      'profile',
      () async => 'lecturer-gv001',
    );
    expect(gvVal, 'lecturer-gv001');
  });

  test('invalidatePrefix removes matching keys without touching others', () async {
    DataCacheService.instance.setUserScope('sv001');
    await DataCacheService.instance.getOrFetch('student:courses', () async => 1);
    await DataCacheService.instance.getOrFetch('student:groups', () async => 2);
    await DataCacheService.instance.getOrFetch('profile', () async => 3);

    DataCacheService.instance.invalidatePrefix('student:');

    var courseCalls = 0;
    var profileCalls = 0;
    final courseVal = await DataCacheService.instance.getOrFetch(
      'student:courses',
      () async {
        courseCalls++;
        return 10;
      },
    );
    final profileVal = await DataCacheService.instance.getOrFetch(
      'profile',
      () async {
        profileCalls++;
        return 30;
      },
    );

    expect(courseVal, 10);
    expect(courseCalls, 1);
    expect(profileVal, 3);
    expect(profileCalls, 0);
  });
}
