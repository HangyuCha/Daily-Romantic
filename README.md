# 데일리 로맨틱 (Daily Romantic)

Flutter로 만든 iOS / Android 앱입니다. 코드 하나로 두 플랫폼을 함께 빌드합니다.

## 개발 환경 준비

1. [Flutter SDK](https://docs.flutter.dev/get-started/install) 설치 (3.41 이상)
2. iOS 빌드 (Mac만 가능)
   - App Store에서 Xcode 설치
   - `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer`
   - `sudo xcodebuild -runFirstLaunch`
   - CocoaPods 설치: `brew install cocoapods`
3. Android 빌드: Android Studio 설치 후 에뮬레이터 생성
4. `flutter doctor` 로 빠진 항목이 없는지 확인

## 기술 스택

- 앱: Flutter (iOS + Android)
- DB · 로그인: Supabase (무료 플랜) — 카카오 / 네이버 로그인
- 설정 방법: [docs/BACKEND_SETUP.md](docs/BACKEND_SETUP.md)

## 실행

```bash
flutter pub get
flutter run --dart-define-from-file=env.json   # 로그인 포함 실행
flutter run            # env.json 없이 UI만 확인
flutter test           # 테스트
flutter analyze        # 코드 검사
```

iOS 시뮬레이터 열기: `open -a Simulator`

## 폴더 구조

```
lib/
├── main.dart                 # 진입점
├── app.dart                  # MaterialApp, 테마 연결
├── core/
│   ├── config/
│   │   └── env.dart          # Supabase 주소·키 (env.json에서 주입)
│   ├── constants/
│   │   └── app_strings.dart  # 앱 문구 모음
│   └── theme/
│       ├── app_colors.dart   # 브랜드 컬러 (색 변경은 여기서)
│       ├── app_spacing.dart  # 여백·모서리 값
│       └── app_theme.dart    # 라이트/다크 테마
├── features/                 # 기능(화면) 단위로 폴더 분리
│   ├── auth/                 # 카카오·네이버 로그인
│   ├── shell/main_shell.dart # 하단 탭 바
│   ├── home/
│   ├── calendar/
│   └── profile/
└── shared/widgets/           # 여러 화면에서 쓰는 공용 위젯

supabase/migrations/          # DB 테이블 정의 (SQL)
docs/                         # 설정 가이드
```

## 팀 규칙 (제안)

- 새 기능은 `lib/features/<기능명>/` 폴더를 만들어 그 안에 작업 → 팀원 간 충돌 최소화
- 색상·여백·문구는 화면에 직접 쓰지 말고 `core/`의 값을 사용
- 화면에서는 `Theme.of(context)`로 색과 글꼴을 가져오기
- 하단 탭 추가/변경은 `features/shell/main_shell.dart`의 `_tabs` 목록만 수정
