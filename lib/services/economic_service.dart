import 'package:dio/dio.dart';
import 'api_client.dart';

/// 경제 상태 (E-1 ~ E-3) — 카테고리 12
/// GET   /clients/{client_id}/economic  — 조회
/// POST  /clients/{client_id}/economic  — 등록
/// PATCH /clients/{client_id}/economic  — 수정
class EconomicService {
  final Dio _dio = ApiClient().dio;

  /// E-1: 경제 상태 조회
  /// - 200 → { economic_id, income_type, monthly_income, welfare_benefit_yn,
  ///           benefit_types[], debt_yn, housing_cost }
  Future<Map<String, dynamic>> get(String clientId) async {
    final res = await _dio.get('/clients/$clientId/economic');
    return res.data as Map<String, dynamic>;
  }

  /// E-2: 경제 상태 등록
  /// - 201 → { economic_id }
  Future<Map<String, dynamic>> create(
    String clientId, {
    String? incomeType,
    int? monthlyIncome,
    bool? welfareBenefitYn,
    List<String>? benefitTypes,
    bool? debtYn,
    int? housingCost,
  }) async {
    final res = await _dio.post('/clients/$clientId/economic', data: {
      if (incomeType != null) 'income_type': incomeType,
      if (monthlyIncome != null) 'monthly_income': monthlyIncome,
      if (welfareBenefitYn != null) 'welfare_benefit_yn': welfareBenefitYn,
      if (benefitTypes != null) 'benefit_types': benefitTypes,
      if (debtYn != null) 'debt_yn': debtYn,
      if (housingCost != null) 'housing_cost': housingCost,
    });
    return res.data as Map<String, dynamic>;
  }

  /// E-3: 경제 상태 수정
  /// - 200 → { economic_id, updated_fields }
  Future<Map<String, dynamic>> update(
    String clientId,
    Map<String, dynamic> data,
  ) async {
    final res = await _dio.patch('/clients/$clientId/economic', data: data);
    return res.data as Map<String, dynamic>;
  }
}
