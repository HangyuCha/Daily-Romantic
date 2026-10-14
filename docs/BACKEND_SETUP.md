# 백엔드 · 로그인 설정 가이드

모두 무료 플랜으로 진행합니다. 순서대로 따라 하면 카카오 / 네이버 로그인이 동작합니다.

| 역할 | 서비스 | 무료 범위 (2026년 10월 기준, 변경될 수 있음) |
| --- | --- | --- |
| DB · 로그인 · 파일 저장 | [Supabase](https://supabase.com) Free | DB 500MB, 파일 1GB, 월 활성 사용자 5만 명, 프로젝트 2개 |
| 카카오 로그인 | [Kakao Developers](https://developers.kakao.com) | 무료 |
| 네이버 로그인 | [NAVER Developers](https://developers.naver.com) | 무료 |

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

## 2. 카카오 로그인

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

## 3. 네이버 로그인

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

## 4. 실행해서 확인

```bash
flutter run --dart-define-from-file=env.json
```

`env.json` 없이 `flutter run`만 하면 로그인 화면을 건너뛰고 메인 화면만 보입니다 (UI 작업용).

---

## 배포는 어떻게 하나요?

| 대상 | 무료 방법 | 유료 방법 |
| --- | --- | --- |
| iOS | Xcode로 내 아이폰에 직접 설치 (무료 Apple ID, **7일마다 재설치**, 기기 3대까지). 발표는 시뮬레이터나 내 폰으로 시연 | TestFlight / App Store: Apple Developer Program **연 $99** |
| Android | `flutter build apk` → APK 파일을 팀원에게 직접 공유, 또는 Firebase App Distribution (무료) | Play 스토어: **1회 $25** |
| 백엔드 | Supabase가 서버 역할까지 하므로 별도 서버 배포 없음 | — |

iOS를 다른 사람 폰에 무료로 설치해 주는 방법은 없습니다. 수업 시연이 목적이면 무료 방법으로 충분합니다.
