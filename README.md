# 데일리 로맨틱 (Daily Romantic)

Flutter로 만든 iOS / Android 앱입니다. 코드 하나로 두 플랫폼을 함께 빌드합니다.

## 개발 환경 준비

1. [Flutter SDK](https://docs.flutter.dev/get-started/install) 설치 (3.41 이상)
2. iOS 빌드 (Mac만 가능)
   - App Store에서 Xcode 설치
   - `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer`
   - `sudo xcodebuild -runFirstLaunch`
   - Swift Package Manager 사용 설정 (CocoaPods 설치 불필요):
     `flutter config --enable-swift-package-manager`
3. Android 빌드: Android Studio 설치 후 에뮬레이터 생성
4. `flutter doctor` 로 빠진 항목이 없는지 확인

## 기술 스택

- 앱: Flutter (iOS + Android)
- DB · 로그인: Supabase (무료 플랜) — 이메일 / 카카오 / 네이버 로그인
- 지도·위치: OpenStreetMap 지도 + GPS + 도보 길찾기 (무료, 키 없음)
- 결제: 시연용 화면 (실제 결제 없음)
- 설정 방법: [docs/BACKEND_SETUP.md](docs/BACKEND_SETUP.md)

## 실행

```bash
flutter pub get
flutter run --dart-define-from-file=env.json   # 로그인 포함 실행
flutter run            # env.json 없이 데모 모드로 실행 (앱 안에서만 가입·로그인)
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
│   │   └── app_strings.dart  # 여러 화면에서 쓰는 문구
│   ├── location/             # GPS, 장소 검색, 도보 길찾기
│   ├── utils/formatters.dart # 금액·시간 표시 형식
│   └── theme/
│       ├── app_colors.dart   # 브랜드 컬러 (색 변경은 여기서)
│       ├── app_spacing.dart  # 여백·모서리 값
│       └── app_theme.dart    # 라이트/다크 테마
├── features/                 # 기능(화면) 단위로 폴더 분리
│   ├── auth/                 # 로그인·회원가입 (이메일, 카카오, 네이버)
│   ├── pickup/               # 선물 픽업 주문 흐름 S1~S5
│   │   ├── data/             # 모델, 임시 가게 데이터, 주문·찜 상태
│   │   ├── screens/          # S1 경로 입력 ~ S5 픽업 코드
│   │   └── widgets/          # 지도, 가게 카드, 수량 스테퍼
│   ├── orders/               # 주문 탭
│   ├── favorites/            # 찜 탭
│   ├── profile/              # MY 탭
│   └── shell/main_shell.dart # 하단 탭 바
└── shared/widgets/           # 여러 화면에서 쓰는 공용 위젯

supabase/migrations/          # DB 테이블 정의 (SQL)
docs/                         # 설정 가이드
```

## 화면 구성

팀 화면 정의서 v1.0(이도영 프로토타입) 기준입니다.

| 화면 | 파일 |
| --- | --- |
| 로그인 / 회원가입 | `features/auth/login_screen.dart`, `signup_screen.dart` |
| S1 홈 · 경로 입력 | `features/pickup/screens/route_input_screen.dart` |
| S2 가게 목록 | `features/pickup/screens/store_list_screen.dart` |
| S3 메뉴 · 장바구니 | `features/pickup/screens/store_menu_screen.dart` |
| S4 픽업 시간 | `features/pickup/screens/pickup_time_screen.dart` |
| 결제 (시연용) | `features/pickup/screens/payment_screen.dart` |
| S5 픽업 코드 | `features/pickup/screens/pickup_code_screen.dart` |
| 주문 / 찜 / MY 탭 | `features/orders`, `features/favorites`, `features/profile` |

가게·메뉴는 아직 `features/pickup/data/mock_stores.dart`의 임시 데이터이고, 지도에서는 실제 도보 경로 위에 배치됩니다.

## 팀 규칙 (제안)

- 새 기능은 `lib/features/<기능명>/` 폴더를 만들어 그 안에 작업 → 팀원 간 충돌 최소화
- 색상·여백은 화면에 직접 쓰지 말고 `core/theme`의 값을 사용
- 화면에서는 `Theme.of(context)`로 색과 글꼴을 가져오기
- 하단 탭 추가/변경은 `features/shell/main_shell.dart`의 `_tabs` 목록만 수정
