# 백엔드 · 로그인 설정 가이드

모두 무료 플랜으로 진행합니다. 순서대로 따라 하면 카카오 / 네이버 로그인이 동작합니다.

| 역할 | 서비스 | 무료 범위 (2026년 10월 기준, 변경될 수 있음) |
| --- | --- | --- |
| DB · 로그인 · 파일 저장 | [Supabase](https://supabase.com) Free | DB 500MB, 파일 1GB, 월 활성 사용자 5만 명, 프로젝트 2개 |
| 카카오 로그인 | [Kakao Developers](https://developers.kakao.com) | 무료 |
| 네이버 로그인 | [NAVER Developers](https://developers.naver.com) | 무료 |
| 지도 | [OpenStreetMap](https://www.openstreetmap.org) 타일 | 무료, 가입·키 없음 |
| 장소 검색 | [Nominatim](https://nominatim.org) | 무료, 가입·키 없음 (초당 1회) |
| 도보 길찾기 | [OSRM 공개 서버](https://routing.openstreetmap.de) | 무료, 가입·키 없음 |

> Supabase 무료 프로젝트는 **7일 동안 요청이 없으면 일시정지**됩니다. 데이터는 남아 있고, 대시보드에서 Restore를 누르면 다시 켜집니다. 발표 전날 꼭 확인하세요.

---

## 1. Supabase 프로젝트 만들기

1. supabase.com 가입 → **New project** (Region: `Northeast Asia (Seoul)`)
2. **Project Settings → API Keys**에서 아래 두 값을 복사
   - Project URL
   - Publishable key
3. 프로젝트 루트에서 `env.example.json`을 `env.json`으로 복사하고 값을 채움 (`env.json`은 git에 올라가지 않음)
4. **Authentication → URL Configuration → Redirect URLs**에 추가:
   ```
   dailyromantic://login-callback
   ```
5. **SQL Editor**에서 `supabase/migrations/` 안의 SQL 파일을 순서대로 실행 (profiles 테이블 생성)

Supabase 콜백 주소 (카카오·네이버 설정에 사용):
```
https://<프로젝트ID>.supabase.co/auth/v1/callback
```

## 2. 이메일 회원가입·로그인

Supabase는 이메일 로그인이 기본으로 켜져 있어서 따로 켤 필요가 없습니다.

- **Authentication → Sign In / Providers → Email**에서 **Confirm email**을 끄는 것을 권장합니다.
  - 켜 두면 가입 후 인증 메일을 눌러야 로그인할 수 있습니다.
  - Supabase 기본 메일 서버는 보낼 수 있는 양이 매우 적고, 프로젝트 팀원 주소로만 보내도록 제한될 수 있어서 수업 시연에는 꺼 두는 편이 안전합니다.
- 켜 둔 경우에도 앱은 "메일함을 확인해 주세요" 안내를 띄우도록 처리되어 있습니다.
- 회원가입 때 입력한 닉네임은 `profiles` 테이블에 자동으로 저장됩니다.

## 3. 카카오 로그인

**Kakao Developers**
1. 내 애플리케이션 → 애플리케이션 추가
2. **앱 키**에서 `REST API 키` 복사
3. **카카오 로그인** → 활성화 ON
4. **카카오 로그인 → Redirect URI**에 위의 Supabase 콜백 주소 등록
5. **카카오 로그인 → 보안**에서 Client Secret 생성 후 복사 (활성화 상태로)
6. **동의항목**: 닉네임, 프로필 사진 설정
   - 이메일(`account_email`)은 비즈 앱 전환이 필요해서, 우선은 이메일 없이 진행합니다.

**Supabase**
1. **Authentication → Sign In / Providers → Kakao** 켜기
2. Client ID = REST API 키, Client Secret = 위에서 만든 시크릿
3. 이메일 동의항목을 안 쓰므로 **이메일 없는 사용자 허용** 옵션을 켭니다

## 4. 네이버 로그인

네이버는 Supabase 기본 목록에 없어서 **커스텀 OIDC provider**로 등록합니다. 네이버가 OIDC 표준을 지원하므로 별도 서버 코드는 필요 없습니다. (무료 플랜은 커스텀 provider 3개까지)

**NAVER Developers**
1. Application → 애플리케이션 등록, 사용 API: **네이버 로그인**
2. 제공 정보: 별명, 프로필 사진
3. 환경: **iOS / Android / PC 웹** 추가
   - PC 웹의 Callback URL에 **Supabase 커스텀 provider 화면에 표시되는 Callback URL**을 등록 (아래 Supabase 2번 참고)
4. `Client ID`, `Client Secret` 복사
5. 앱이 **개발 중** 상태면 **멤버 관리**에 등록한 테스터 계정만 로그인됩니다. 팀원 네이버 아이디를 미리 추가하세요.

**Supabase**
1. **Authentication → Sign In / Providers → Custom provider 추가**
2. 아래처럼 입력
   | 항목 | 값 |
   | --- | --- |
   | Type | OIDC |
   | Identifier | `custom:naver` (앱 코드와 같아야 함) |
   | Issuer URL | `https://nid.naver.com` |
   | Client ID / Secret | 네이버에서 복사한 값 |
   | Scopes | `openid`, `profile` |
   | Email optional | 켜기 |
3. 화면에 나오는 Callback URL을 네이버 Callback URL에 등록

## 5. 실행해서 확인

```bash
flutter run --dart-define-from-file=env.json
```

`env.json` 없이 `flutter run`만 하면 **데모 모드**로 실행됩니다.
서버 없이 앱 안에서만 회원가입·로그인이 동작하고(카카오·네이버 버튼도 바로 로그인 처리), 앱을 끄면 가입 정보가 사라집니다. UI 작업이나 발표 시연용입니다.

---

## 지도·위치

따로 설정할 것이 없습니다. 위치 권한 문구는 iOS `Info.plist`, Android `AndroidManifest.xml`에 들어 있습니다.

- **현재 위치**: 폰 GPS (`geolocator`). 처음 실행할 때 위치 권한을 물어봅니다.
- **목적지 검색**: 장소 이름으로 검색합니다. 결과가 여러 개면 고르는 창이 뜹니다.
- **경로**: 실제 도보 경로를 지도에 점선으로 그립니다. 길찾기 서버에 연결하지 못하면 직선(점 무늬)으로 대신 그립니다.
- **가게 위치**: 아직 실제 가게 데이터가 없어서, 임시 가게 4곳을 사용자의 실제 경로 위에 배치합니다.

**시뮬레이터에서 위치 바꾸기** (iOS): Simulator 메뉴 → Features → Location → Custom Location, 또는

```bash
xcrun simctl location booted set 37.5572,126.9245
```

> 모두 공개 무료 서버라 수업·시연 정도의 사용량만 허용됩니다. 실제 출시할 때는 네이버 지도·카카오맵 API(무료 사용량 있음, 키 필요)로 바꾸는 것을 권장합니다. 코드에서는 `lib/core/location/`의 서비스 파일만 바꾸면 됩니다.

## 배포는 어떻게 하나요?

| 대상 | 무료 방법 | 유료 방법 |
| --- | --- | --- |
| iOS | Xcode로 내 아이폰에 직접 설치 (무료 Apple ID, **7일마다 재설치**, 기기 3대까지). 발표는 시뮬레이터나 내 폰으로 시연 | TestFlight / App Store: Apple Developer Program **연 $99** |
| Android | `flutter build apk` → APK 파일을 팀원에게 직접 공유, 또는 Firebase App Distribution (무료) | Play 스토어: **1회 $25** |
| 백엔드 | Supabase가 서버 역할까지 하므로 별도 서버 배포 없음 | — |

iOS를 다른 사람 폰에 무료로 설치해 주는 방법은 없습니다. 수업 시연이 목적이면 무료 방법으로 충분합니다.
