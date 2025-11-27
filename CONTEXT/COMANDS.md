### 1\. 코드 생성 (flutter_gen)

이미지 경로 등을 자동으로 변환해주는 비서(`build_runner`)를 부르는 명령어입니다.

```bash
# 기본: 코드 생성 실행
dart run build_runner build

# 강력 추천: 기존 파일과 충돌 날 때 (싹 지우고 다시 생성)
dart run build_runner build --delete-conflicting-outputs
```

### 2\. 앱 실행 (코드스페이스 환경)

모니터가 없는 서버 환경에서 웹 브라우저로 앱을 띄우기 위한 명령어입니다.

```bash
# 1. 프로젝트에 웹 지원 기능 추가 (최초 1회 필수)
flutter create --platforms web .

# 2. 웹 서버 모드로 실행 (포트 8080 개방)
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080
```

### 3\. Git & 환경 설정 (트러블슈팅)

코드스페이스나 컨테이너 환경에서 발생했던 권한 및 동기화 문제 해결입니다.

```bash
# Git 'dubious ownership' 에러 해결 (권한 부여)
git config --global --add safe.directory /workspaces/repo-arborist

# 서버 코드 안전하게 가져오기 (충돌 방지 루틴)
git stash           # 내 작업 임시 저장
git pull origin main # 서버 코드 가져오기
git stash pop       # 내 작업 다시 꺼내기 (이후 충돌 해결)

# 패키지 의존성 설치 (라이브러리 다운로드)
flutter pub get
```
