import 'package:dio/dio.dart';
import 'api_client.dart';

/// 상담 유형별 플로우 (FL-1 ~ FL-10)
/// [위기개입]      POST/GET/PATCH /sessions/{session_id}/crisis-protocol|crisis-checklist
/// [프로그램신청]  POST/GET/PATCH /clients/{client_id}/programs
/// [사례관리]      POST/GET       /clients/{client_id}/case-stages
/// [가족상담]      PATCH          /sessions/{session_id}/speaker-config
class FlowService {
  final Dio _dio = ApiClient().dio;

  // ─────────────────────────── 위기개입 ────────────────────────────

  /// FL-1: 위기 프로토콜 활성화
  /// - 슈퍼바이저·관리자에게 Push 즉시 발송
  /// - crisisType: 자살|자해|학대|가정폭력|방임 등
  /// - 201 → { protocol_id, checklist_url, notified: [] }
  Future<Map<String, dynamic>> activateCrisisProtocol(
    String sessionId, {
    required String crisisType,
    bool notifySupervisor = true,
  }) async {
    final res = await _dio.post('/sessions/$sessionId/crisis-protocol', data: {
      'crisis_type': crisisType,
      'notify_supervisor': notifySupervisor,
    });
    return res.data['data'] as Map<String, dynamic>;
  }

  /// FL-2: 위기조치 체크리스트 조회
  /// - 200 → { items: [{ id, label, required, done }] }
  Future<Map<String, dynamic>> getCrisisChecklist(String sessionId) async {
    final res = await _dio.get('/sessions/$sessionId/crisis-checklist');
    return res.data['data'] as Map<String, dynamic>;
  }

  /// FL-3: 위기조치 체크리스트 완료 처리
  /// - 필수 항목 미완료 시 회기 저장 불가
  /// - 200 → { all_required_done: bool }
  Future<Map<String, dynamic>> completeCrisisChecklist(
    String sessionId, {
    required List<Map<String, dynamic>> checklistItems,
  }) async {
    final res = await _dio.patch(
      '/sessions/$sessionId/crisis-checklist',
      data: {'checklist_items': checklistItems},
    );
    return res.data['data'] as Map<String, dynamic>;
  }

  // ────────────────────────── 프로그램 신청 ────────────────────────

  /// FL-4: 프로그램 신청 등록
  /// - 자격조건 자동 체크
  /// - 201 → { application_id, status: "접수", docs_pending: [] }
  Future<Map<String, dynamic>> applyProgram(
    String clientId, {
    required String programId,
    List<String>? docsRequired,
  }) async {
    final res = await _dio.post('/clients/$clientId/programs', data: {
      'program_id': programId,
      if (docsRequired != null) 'docs_required': docsRequired,
    });
    return res.data['data'] as Map<String, dynamic>;
  }

  /// FL-5: 프로그램 신청 현황 조회
  /// - 200 → { applications: [{ application_id, program_name, status, docs_pending }] }
  /// - status: 접수 | 심사 | 결정 | 통보
  Future<Map<String, dynamic>> listPrograms(String clientId) async {
    final res = await _dio.get('/clients/$clientId/programs');
    return res.data['data'] as Map<String, dynamic>;
  }

  /// FL-6: 프로그램 신청 상태 변경
  /// - status: 접수 | 심사 | 결정 | 통보
  /// - 200 → { application_id, status }
  Future<Map<String, dynamic>> updateProgramStatus(
    String clientId,
    String progId, {
    required String status,
  }) async {
    final res = await _dio.patch(
      '/clients/$clientId/programs/$progId',
      data: {'status': status},
    );
    return res.data['data'] as Map<String, dynamic>;
  }

  // ─────────────────────────── 사례관리 ────────────────────────────

  /// FL-7: 사례관리 단계 등록
  /// - stage: 초기사정 | 욕구사정 | 서비스계획 | 개입 | 모니터링 | 종결
  /// - 201 → { stage_id, stage, progress_pct }
  Future<Map<String, dynamic>> createCaseStage(
    String clientId, {
    required String stage,
    List<String>? goals,
  }) async {
    final res = await _dio.post('/clients/$clientId/case-stages', data: {
      'stage': stage,
      if (goals != null) 'goals': goals,
    });
    return res.data['data'] as Map<String, dynamic>;
  }

  /// FL-8: 사례관리 단계 목록 조회
  /// - 200 → { stages: [{ stage_id, stage, goals[], progress_pct }] }
  Future<Map<String, dynamic>> listCaseStages(String clientId) async {
    final res = await _dio.get('/clients/$clientId/case-stages');
    return res.data['data'] as Map<String, dynamic>;
  }

  /// FL-9: 사례관리 목표 달성률 조회
  /// - 200 → { total_goals, achieved, progress_pct }
  Future<Map<String, dynamic>> caseStageProgress(String clientId) async {
    final res = await _dio.get('/clients/$clientId/case-stages/progress');
    return res.data['data'] as Map<String, dynamic>;
  }

  // ─────────────────────────── 가족상담 ────────────────────────────

  /// FL-10: 화자 분리 설정 (가족 구성원별 발언 분리 STT)
  /// - 200 → { session_id, speaker_count }
  Future<Map<String, dynamic>> speakerConfig(
    String sessionId, {
    required List<String> speakerFamilyMemberIds,
  }) async {
    final res = await _dio.patch(
      '/sessions/$sessionId/speaker-config',
      data: {'speakers': speakerFamilyMemberIds},
    );
    return res.data['data'] as Map<String, dynamic>;
  }
}
