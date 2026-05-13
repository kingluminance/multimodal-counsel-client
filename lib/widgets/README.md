# widgets/ — 재사용 UI 컴포넌트 레이어

여러 화면에서 공유되는 UI 컴포넌트를 모아둡니다.  
`Pages`로부터 props(파라미터)를 받아 렌더링하며, 비즈니스 로직을 포함하지 않습니다.

## 위젯 사용 흐름

```mermaid
flowchart TD
    PAGE["📄 Page"]

    subgraph Widgets["widgets/"]
        CHAT_BUBBLE["💬 ChatBubble\n메시지 말풍선"]
        MEDIA_INPUT["🎤 MediaInputBar\n텍스트 / 음성 / 이미지 입력"]
        EMOTION_BADGE["😊 EmotionBadge\n감정 분석 뱃지"]
        SESSION_CARD["📋 SessionCard\n상담 세션 카드"]
        LOADING["⏳ LoadingOverlay\n로딩 표시"]
        APP_BTN["🔘 AppButton\n공통 버튼"]
    end

    PAGE -- "props 전달" --> CHAT_BUBBLE
    PAGE -- "props 전달" --> MEDIA_INPUT
    PAGE -- "props 전달" --> EMOTION_BADGE
    PAGE -- "props 전달" --> SESSION_CARD
    PAGE -- "props 전달" --> LOADING
    PAGE -- "props 전달" --> APP_BTN

    MEDIA_INPUT -- "onSend(content, type) 콜백" --> PAGE
    SESSION_CARD -- "onTap 콜백" --> PAGE
    APP_BTN -- "onPressed 콜백" --> PAGE
```

## 위젯 계층 구조 예시 (CounselPage)

```mermaid
flowchart TD
    CP["CounselPage"]
    SCAFFOLD["Scaffold"]
    APPBAR["AppBar"]
    BODY["ListView"]
    CB1["ChatBubble (user)"]
    CB2["ChatBubble (AI)"]
    EB["EmotionBadge"]
    MIB["MediaInputBar"]

    CP --> SCAFFOLD
    SCAFFOLD --> APPBAR
    SCAFFOLD --> BODY
    SCAFFOLD --> MIB
    BODY --> CB1
    BODY --> CB2
    CB2 --> EB
```

## 폴더 구성 예시

```
widgets/
├── chat_bubble.dart
├── media_input_bar.dart
├── emotion_badge.dart
├── session_card.dart
├── loading_overlay.dart
└── app_button.dart
```
