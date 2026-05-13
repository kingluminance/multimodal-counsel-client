# DeepCare — Multimodal Counsel Client (Flutter)

> 멀티모달 AI 기반 심리 상담 모바일/웹 클라이언트

---

## 프로젝트 전체 데이터 흐름 (Level 0 — Context Diagram)

```mermaid
flowchart TD
    USER(["👤 사용자"])
    APP["🟦 DeepCare App"]
    BACKEND(["🖥️ Backend API Server"])
    AI(["🤖 Multimodal AI Engine"])

    USER -- "텍스트 / 음성 / 이미지 입력" --> APP
    APP -- "REST / WebSocket 요청" --> BACKEND
    BACKEND -- "멀티모달 데이터" --> AI
    AI -- "AI 분석 결과" --> BACKEND
    BACKEND -- "상담 응답 / 세션 데이터" --> APP
    APP -- "UI 렌더링 (응답 표시)" --> USER
```

---

## Level 1 — 내부 레이어 데이터 흐름

```mermaid
flowchart LR
    subgraph USER_ZONE["사용자 영역"]
        U(["👤 User"])
    end

    subgraph FLUTTER_APP["Flutter App (lib/)"]
        direction TB
        P["📄 Pages\n(UI 화면)"]
        W["🧩 Widgets\n(재사용 컴포넌트)"]
        PR["🔄 Providers\n(상태 관리)"]
        SV["🌐 Services\n(API 통신)"]
        MD["📦 Models\n(데이터 구조)"]
        CO["⚙️ Core\n(공통 유틸)"]
    end

    subgraph BACKEND_ZONE["Backend 영역"]
        API(["🖥️ REST API"])
        WS(["🔌 WebSocket"])
    end

    U -- "입력" --> P
    P -- "위젯 사용" --> W
    P -- "상태 구독 / 액션 디스패치" --> PR
    PR -- "서비스 호출" --> SV
    SV -- "HTTP 요청" --> API
    SV -- "실시간 스트림" --> WS
    API -- "JSON 응답" --> SV
    WS -- "스트리밍 메시지" --> SV
    SV -- "Model 파싱" --> MD
    MD -- "데이터 전달" --> PR
    PR -- "상태 업데이트" --> P
    CO -- "테마 / 상수 / 유틸 제공" --> P
    CO -- "테마 / 상수 / 유틸 제공" --> SV
    P -- "렌더링" --> U
```

---

## Level 2 — 주요 기능별 데이터 흐름

### 1. 인증 흐름 (Authentication)

```mermaid
sequenceDiagram
    actor User
    participant LoginPage as 📄 LoginPage
    participant AuthProvider as 🔄 AuthProvider
    participant AuthService as 🌐 AuthService
    participant API as 🖥️ Backend API

    User->>LoginPage: 이메일 / 비밀번호 입력
    LoginPage->>AuthProvider: login(email, password)
    AuthProvider->>AuthService: signIn(email, password)
    AuthService->>API: POST /auth/login
    API-->>AuthService: JWT Access Token + Refresh Token
    AuthService-->>AuthProvider: AuthModel (token, user info)
    AuthProvider-->>LoginPage: 상태 업데이트 (isAuthenticated = true)
    LoginPage-->>User: 홈 화면으로 이동
```

### 2. 멀티모달 상담 흐름 (Counseling Session)

```mermaid
sequenceDiagram
    actor User
    participant CounselPage as 📄 CounselPage
    participant SessionProvider as 🔄 SessionProvider
    participant CounselService as 🌐 CounselService
    participant API as 🖥️ Backend API
    participant AI as 🤖 AI Engine

    User->>CounselPage: 텍스트 / 음성 / 이미지 전송
    CounselPage->>SessionProvider: sendMessage(content, type)
    SessionProvider->>CounselService: postMessage(sessionId, payload)
    CounselService->>API: POST /counsel/session/{id}/message
    API->>AI: 멀티모달 분석 요청
    AI-->>API: 감정 분석 + 상담 응답
    API-->>CounselService: MessageResponseModel
    CounselService-->>SessionProvider: 파싱된 응답 모델
    SessionProvider-->>CounselPage: 메시지 리스트 상태 업데이트
    CounselPage-->>User: AI 응답 표시
```

### 3. 세션 히스토리 흐름 (Session History)

```mermaid
sequenceDiagram
    actor User
    participant HistoryPage as 📄 HistoryPage
    participant HistoryProvider as 🔄 HistoryProvider
    participant HistoryService as 🌐 HistoryService
    participant API as 🖥️ Backend API

    User->>HistoryPage: 히스토리 화면 진입
    HistoryPage->>HistoryProvider: fetchSessions()
    HistoryProvider->>HistoryService: getSessions(userId)
    HistoryService->>API: GET /counsel/sessions
    API-->>HistoryService: List<SessionModel>
    HistoryService-->>HistoryProvider: 파싱된 세션 목록
    HistoryProvider-->>HistoryPage: 상태 업데이트
    HistoryPage-->>User: 세션 목록 렌더링
```

---

## 디렉터리 구조

```
frontend/
├── lib/
│   ├── core/            # 공통 상수, 테마, 유틸리티
│   │   ├── constants/   # API URL, 앱 상수
│   │   ├── theme/       # 앱 테마 정의
│   │   └── utils/       # 헬퍼 함수
│   ├── models/          # 데이터 모델 (JSON 직렬화)
│   ├── pages/           # 화면 단위 Widget (라우트 대상)
│   ├── providers/       # 상태 관리 (Riverpod / Provider)
│   ├── services/        # 외부 API 통신 레이어
│   ├── widgets/         # 재사용 가능한 UI 컴포넌트
│   └── main.dart        # 앱 진입점
├── android/
├── ios/
├── web/
├── test/
└── pubspec.yaml
```

각 하위 폴더의 상세 흐름은 해당 폴더의 `README.md`를 참조하세요.
