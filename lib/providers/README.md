# providers/ — 상태 관리 레이어

앱 전역 및 화면별 상태를 관리합니다.  
`Pages`로부터 액션을 받아 `Services`를 호출하고, 결과 상태를 `Pages`에 노출합니다.

## Provider 데이터 흐름

```mermaid
flowchart TD
    PAGE["📄 Page"]
    PROV["🔄 Provider"]
    SVC["🌐 Service"]
    MODEL["📦 Model"]

    PAGE -- "액션 호출 (read)" --> PROV
    PROV -- "서비스 메서드 호출" --> SVC
    SVC -- "API 응답 파싱" --> MODEL
    MODEL -- "데이터 반환" --> PROV
    PROV -- "상태 업데이트" --> PAGE
    PAGE -- "상태 구독 (watch)" --> PROV
```

## 주요 Provider 목록

```mermaid
flowchart LR
    subgraph Providers["providers/"]
        AUTH["🔐 AuthProvider\n로그인 / 로그아웃 / 토큰"]
        SESSION["💬 SessionProvider\n상담 세션 메시지"]
        HISTORY["📋 HistoryProvider\n세션 히스토리 목록"]
        USER["👤 UserProvider\n사용자 프로필"]
    end

    AUTH -- "인증 상태 공유" --> SESSION
    AUTH -- "인증 상태 공유" --> HISTORY
    AUTH -- "인증 상태 공유" --> USER
```

## 상태 생명주기

```mermaid
stateDiagram-v2
    [*] --> idle : 초기화
    idle --> loading : 액션 호출
    loading --> success : 서비스 응답 성공
    loading --> error : 서비스 응답 실패
    success --> idle : 상태 유지
    error --> idle : 에러 초기화
```

## 폴더 구성 예시

```
providers/
├── auth_provider.dart
├── session_provider.dart
├── history_provider.dart
└── user_provider.dart
```
