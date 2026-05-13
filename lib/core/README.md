# core/ — 공통 기반 레이어

앱 전체에서 참조하는 상수, 테마, 유틸리티 함수를 제공합니다.  
다른 레이어에 의존하지 않으며, 모든 레이어가 이 폴더를 참조할 수 있습니다.

## core/ 내부 구조 및 흐름

```mermaid
flowchart TD
    subgraph Core["core/"]
        CONST["📌 constants/\nAPI URL, 앱 상수, 라우트 이름"]
        THEME["🎨 theme/\n색상, 타이포그래피, 컴포넌트 테마"]
        UTILS["🔧 utils/\n날짜 포맷, 유효성 검사, 에러 처리"]
    end

    PAGES["📄 pages/"]
    WIDGETS["🧩 widgets/"]
    SERVICES["🌐 services/"]

    CONST -- "BASE_URL, ROUTES" --> SERVICES
    CONST -- "ROUTES" --> PAGES
    THEME -- "ThemeData" --> PAGES
    THEME -- "색상/스타일" --> WIDGETS
    UTILS -- "헬퍼 함수" --> PAGES
    UTILS -- "헬퍼 함수" --> SERVICES
    UTILS -- "헬퍼 함수" --> WIDGETS
```

## constants/ — 주요 상수

```mermaid
flowchart LR
    subgraph constants["constants/"]
        API["api_constants.dart\nBASE_URL, 엔드포인트 경로"]
        APP["app_constants.dart\n앱 이름, 버전, 페이지네이션 크기"]
        ROUTE["route_constants.dart\n화면 라우트 이름 문자열"]
    end
```

## theme/ — 앱 테마

```mermaid
flowchart LR
    subgraph theme["theme/"]
        COLOR["app_colors.dart\n브랜드 컬러 팔레트"]
        TEXT["app_text_styles.dart\n폰트 스타일 정의"]
        THEME_DATA["app_theme.dart\nThemeData 조합 및 export"]
    end

    COLOR --> THEME_DATA
    TEXT --> THEME_DATA
    THEME_DATA -- "MaterialApp.theme" --> APP["main.dart"]
```

## utils/ — 유틸리티 함수

```mermaid
flowchart LR
    subgraph utils["utils/"]
        DATE["date_utils.dart\n날짜/시간 포맷"]
        VALID["validators.dart\n입력 유효성 검사"]
        ERR["error_handler.dart\nAPI 에러 파싱 및 사용자 메시지"]
    end
```

## 폴더 구성 예시

```
core/
├── constants/
│   ├── api_constants.dart
│   ├── app_constants.dart
│   └── route_constants.dart
├── theme/
│   ├── app_colors.dart
│   ├── app_text_styles.dart
│   └── app_theme.dart
└── utils/
    ├── date_utils.dart
    ├── validators.dart
    └── error_handler.dart
```
