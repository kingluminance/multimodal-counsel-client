# services/ — API 통신 레이어

외부 Backend API 및 멀티모달 AI 엔진과의 모든 통신을 담당합니다.  
`Providers`로부터 호출되며, 응답을 `Models`로 파싱하여 반환합니다.

## 서비스 레이어 데이터 흐름

```mermaid
flowchart LR
    PROV["🔄 Provider"]

    subgraph Services["services/"]
        AUTH_SVC["🔐 AuthService"]
        COUNSEL_SVC["💬 CounselService"]
        MEDIA_SVC["🎤 MediaService"]
        HISTORY_SVC["📋 HistoryService"]
        USER_SVC["👤 UserService"]
    end

    subgraph Backend["Backend"]
        REST["🖥️ REST API"]
        WS["🔌 WebSocket"]
    end

    PROV --> AUTH_SVC
    PROV --> COUNSEL_SVC
    PROV --> MEDIA_SVC
    PROV --> HISTORY_SVC
    PROV --> USER_SVC

    AUTH_SVC -- "POST /auth/login\nPOST /auth/refresh" --> REST
    COUNSEL_SVC -- "POST /counsel/session\nPOST /counsel/session/{id}/message" --> REST
    COUNSEL_SVC -- "ws://counsel/stream" --> WS
    MEDIA_SVC -- "POST /media/upload" --> REST
    HISTORY_SVC -- "GET /counsel/sessions" --> REST
    USER_SVC -- "GET /user/profile\nPUT /user/profile" --> REST
```

## HTTP 요청/응답 처리 흐름

```mermaid
sequenceDiagram
    participant Prov as 🔄 Provider
    participant Svc as 🌐 Service
    participant HTTP as HTTP Client
    participant API as 🖥️ API Server

    Prov->>Svc: 메서드 호출 (파라미터)
    Svc->>HTTP: 요청 빌드 (headers, body)
    HTTP->>API: HTTP 요청
    API-->>HTTP: HTTP 응답 (JSON)
    HTTP-->>Svc: Response 객체
    Svc->>Svc: JSON → Model 파싱
    Svc-->>Prov: Model 반환
```

## 멀티모달 스트리밍 흐름

```mermaid
sequenceDiagram
    participant Page as 📄 CounselPage
    participant Prov as 🔄 SessionProvider
    participant Svc as 🌐 CounselService
    participant WS as 🔌 WebSocket
    participant AI as 🤖 AI Engine

    Page->>Prov: sendMessage(text/audio/image)
    Prov->>Svc: streamMessage(payload)
    Svc->>WS: WebSocket 연결 + 데이터 전송
    WS->>AI: 멀티모달 입력 스트리밍
    AI-->>WS: 청크 단위 응답
    WS-->>Svc: Stream<String> 반환
    Svc-->>Prov: 스트림 노출
    Prov-->>Page: 실시간 UI 업데이트
```

## 폴더 구성 예시

```
services/
├── auth_service.dart
├── counsel_service.dart
├── media_service.dart
├── history_service.dart
└── user_service.dart
```
