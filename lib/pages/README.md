# pages/ — UI 화면 레이어

각 파일은 라우팅 가능한 독립 화면(Screen)입니다.  
화면은 `Providers`를 구독하여 상태를 읽고, 사용자 액션을 `Providers`로 전달합니다.

## 화면 간 네비게이션 흐름

```mermaid
flowchart TD
    SPLASH["🖥️ SplashPage\n앱 시작 / 토큰 검증"]
    LOGIN["🔐 LoginPage\n이메일 로그인"]
    REGISTER["📝 RegisterPage\n회원가입"]
    HOME["🏠 HomePage\n메인 대시보드"]
    COUNSEL["💬 CounselPage\n상담 세션 (멀티모달)"]
    HISTORY["📋 HistoryPage\n상담 기록"]
    PROFILE["👤 ProfilePage\n사용자 설정"]

    SPLASH -- "토큰 유효" --> HOME
    SPLASH -- "토큰 없음 / 만료" --> LOGIN
    LOGIN -- "로그인 성공" --> HOME
    LOGIN -- "회원가입 클릭" --> REGISTER
    REGISTER -- "가입 완료" --> LOGIN
    HOME -- "새 상담 시작" --> COUNSEL
    HOME -- "기록 보기" --> HISTORY
    HOME -- "프로필" --> PROFILE
    HISTORY -- "세션 선택" --> COUNSEL
    COUNSEL -- "세션 종료" --> HOME
```

## 각 화면의 데이터 흐름

```mermaid
flowchart LR
    subgraph Page["📄 Page (예: CounselPage)"]
        UI["Widget Tree"]
        CB["Callback / Event"]
    end

    subgraph Provider["🔄 Provider"]
        STATE["State"]
        ACTION["Action Method"]
    end

    UI -- "watch(provider)" --> STATE
    STATE -- "rebuild" --> UI
    CB -- "ref.read(provider).action()" --> ACTION
```

## 폴더 구성 예시

```
pages/
├── splash/
│   └── splash_page.dart
├── auth/
│   ├── login_page.dart
│   └── register_page.dart
├── home/
│   └── home_page.dart
├── counsel/
│   └── counsel_page.dart
├── history/
│   └── history_page.dart
└── profile/
    └── profile_page.dart
```
