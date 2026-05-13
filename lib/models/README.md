# models/ — 데이터 모델 레이어

API 응답을 Dart 객체로 매핑하는 데이터 클래스를 정의합니다.  
`fromJson` / `toJson`을 통해 직렬화/역직렬화를 처리합니다.

## 모델 간 관계

```mermaid
erDiagram
    UserModel {
        String id
        String email
        String name
        String profileImageUrl
    }

    SessionModel {
        String id
        String userId
        DateTime createdAt
        DateTime endedAt
        String status
    }

    MessageModel {
        String id
        String sessionId
        String role
        String contentType
        String content
        String mediaUrl
        DateTime timestamp
    }

    EmotionModel {
        String messageId
        String dominantEmotion
        double confidence
        Map scores
    }

    AuthModel {
        String accessToken
        String refreshToken
        UserModel user
    }

    UserModel ||--o{ SessionModel : "has many"
    SessionModel ||--o{ MessageModel : "has many"
    MessageModel ||--o| EmotionModel : "has one"
    AuthModel ||--|| UserModel : "contains"
```

## JSON 직렬화 흐름

```mermaid
flowchart LR
    API["🖥️ API JSON 응답"]
    FACTORY["Model.fromJson()"]
    DART_OBJ["Dart Model 객체"]
    TO_JSON["model.toJson()"]
    REQ_BODY["요청 Body"]

    API -- "Map<String, dynamic>" --> FACTORY
    FACTORY -- "파싱" --> DART_OBJ
    DART_OBJ -- "직렬화" --> TO_JSON
    TO_JSON -- "Map<String, dynamic>" --> REQ_BODY
```

## 폴더 구성 예시

```
models/
├── auth_model.dart
├── user_model.dart
├── session_model.dart
├── message_model.dart
└── emotion_model.dart
```
