import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:template/core/services/firestore_cache_service.dart';
import 'package:template/core/services/local_cache_service.dart';
import 'package:template/firebase_options.dart';

/// 앱 초기화 및 외부 서비스 설정
///
/// Firebase, Analytics 등 앱에서 사용하는 외부 서비스를 초기화합니다.
///
/// ## Firebase 설정
/// 템플릿 모드에서는 Firebase를 초기화하지 않습니다.
/// 실제 프로젝트에서 사용하려면:
/// 1. `flutterfire configure` 명령어 실행
/// 2. [enableFirebase] 상수를 true로 변경
class AppSetup {
  /// Firebase 활성화 여부
  static const enableFirebase = true;

  /// Firestore 캐시 사용 여부
  static const enableFirestoreCache = true;

  /// 앱 초기화
  static Future<void> initialize() async {
    await _initializeDotEnv();
    await _initializeFirebase();
    await _initializeCache();
  }

  /// 환경변수 초기화
  static Future<void> _initializeDotEnv() async {
    try {
      await dotenv.load(fileName: '.env');
      debugPrint('환경변수 로드 완료');
    } catch (e) {
      // .env 파일이 없어도 앱은 정상 동작 (CI/CD, 테스트 환경)
      debugPrint('환경변수 로드 실패 (선택사항): $e');
    }
  }

  /// 로컬 캐시 초기화
  static Future<void> _initializeCache() async {
    try {
      // Hive 로컬 캐시 초기화
      final localCache = LocalCacheService();
      await localCache.init();
      debugPrint('로컬 캐시 (Hive) 초기화 완료');

      // Firestore 캐시 초기화 (선택적)
      if (enableFirebase && enableFirestoreCache) {
        final firestoreCache = FirestoreCacheService();
        await firestoreCache.init();
        debugPrint('Firestore 캐시 초기화 완료');
      }
    } catch (e, stack) {
      debugPrint('캐시 초기화 실패: $e');
      debugPrint('Stack trace: $stack');
      rethrow;
    }
  }

  /// Firebase 초기화
  static Future<void> _initializeFirebase() async {
    if (!enableFirebase) {
      debugPrint('Firebase가 비활성화되어 있습니다 (템플릿 모드)');
      return;
    }

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Crashlytics 설정
      FlutterError.onError = (errorDetails) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      };

      // 비동기 에러 처리
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };

      debugPrint('Firebase 초기화 완료');
    } catch (e, stack) {
      debugPrint('Firebase 초기화 실패: $e');
      debugPrint('Stack trace: $stack');
      rethrow;
    }
  }

  /// Zone 에러 핸들러
  ///
  /// runZonedGuarded의 onError 콜백으로 사용
  static void handleZoneError(Object error, StackTrace stack) {
    if (enableFirebase) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    } else {
      debugPrint('Uncaught error: $error');
      debugPrint('Stack trace: $stack');
    }
  }
}
