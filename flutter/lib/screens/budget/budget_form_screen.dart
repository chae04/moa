import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:moa/constants/colors.dart';
import 'package:moa/models/budget_category_model.dart';
import 'package:moa/models/budget_model.dart';
import 'package:moa/services/budget_category_service.dart';
import 'package:moa/services/budget_service.dart';
import 'package:moa/constants/styles.dart';

class BudgetFormScreen extends StatefulWidget {
  final int? deleteCategoryId; // 삭제할 카테고리 ID
  BudgetFormScreen({super.key, this.deleteCategoryId});
  @override
  State<BudgetFormScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetFormScreen> {
  final BudgetService _budgetService = BudgetService();
  final BudgetCategoryService _budgetCategoryService = BudgetCategoryService();
  Map<int, bool> showOnHome = {};

  List<BudgetCategoryModel> categories = [];
  Map<int, int> budgetRatios = {};
  Map<int, bool> includeInDaily = {};
  Map<int, TextEditingController> controllers = {};
  final savingRatioController = TextEditingController();
  final investRatioController = TextEditingController();
  int savingRatio = 0;
  int investRatio = 0;

  bool isLoading = true;

  // 화면에 보이는 카테고리 (삭제 예정 카테고리 제외)
  List<BudgetCategoryModel> get visibleCategories => // get: 괄호 없이 필드처럼 쓰는 계산 속성
      categories // 서버/DB에서 불러온 활성 카테고리 목록
          .where((c) => c.id != widget.deleteCategoryId) // 삭제 예정 카테고리는 뺌
          .toList();

  String selectedMonth =
      '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}';

  List<String> getMonthList() {
    final now = DateTime.now();
    return List.generate(12, (i) {
      final month = DateTime(now.year, now.month + i);
      return '${month.year}-${month.month.toString().padLeft(2, '0')}';
    });
  }

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await _budgetCategoryService.getCategories();
      // 선택한 월(처음엔 이번 달)에 적용되는 비율 묶음. 저장한 적이 없으면 applyFrom == null
      final budget = await _budgetService.getRatios(selectedMonth);
      if (!mounted) return; // 요청하는 동안 화면을 벗어났으면 setState 하지 않음

      setState(() {
        categories = cats;
        for (var c in cats) {
          budgetRatios[c.id] = 0;
          includeInDaily[c.id] = c.includeInDaily; // 일일 포함은 카테고리에 저장된 값
          controllers[c.id] = TextEditingController();
          showOnHome[c.id] = c.showOnHome;
        }

        // 기존 비율 채우기
        if (budget.applyFrom != null) {
          savingRatio = budget.savingRatio;
          investRatio = budget.investRatio;
          savingRatioController.text = budget.savingRatio.toString();
          investRatioController.text = budget.investRatio.toString();
          for (var c in budget.categories) {
            // 비율 묶음에는 있지만 이미 삭제된 카테고리는 controllers에 없음 → 화면에 안 나오므로 건너뜀
            if (!controllers.containsKey(c.categoryId)) continue;
            budgetRatios[c.categoryId] = c.ratio;
            controllers[c.categoryId]!.text = c.ratio.toString();
          }
        }
      });
    } on DioException catch (e) {
      if (!mounted) return;
      final message = e.response?.data?['message'] ?? '예산 비율을 불러오지 못했어요.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => isLoading = false); // 성공/실패 모두 스피너 끄기
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: Text(
                      '예산 비율 설정',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                  ),

                  // 적용 시작 월
                  InputDecorator(
                    decoration: InputDecoration(labelText: '적용 시작 월'),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedMonth,
                        items: getMonthList().map<DropdownMenuItem<String>>((
                          String value,
                        ) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        // 카테고리 삭제 흐름에서는 이번 달로 고정 (onChanged가 null이면 드롭다운 비활성화)
                        // 다음 달부터로 저장하면 이번 달 비율에 그 카테고리가 남아서 서버가 삭제를 400으로 막음
                        onChanged: widget.deleteCategoryId != null
                            ? null
                            : (String? newValue) {
                                setState(() {
                                  selectedMonth = newValue!;
                                });
                              },
                      ),
                    ),
                  ),

                  Expanded(
                    child: Scrollbar(
                      thumbVisibility: false,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(top: 20, bottom: 20, right: 10),
                        child: Column(
                          children: [
                            // 카테고리별 비율 입력
                            Column(
                              children: [
                                SizedBox(height: 8),
                                ...visibleCategories.map((category) {
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 15),
                                    child: Row(
                                      children: [
                                        // 카테고리 이름 (고정 너비)
                                        SizedBox(
                                          width: 60,
                                          child: Text(
                                            category.name,
                                            style: TextStyle(fontSize: 13),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        // 비율 입력 (짧게)
                                        Expanded(
                                          child: TextField(
                                            controller: controllers[category.id],
                                            decoration: inputDecoration('%'),
                                            keyboardType: TextInputType.number,
                                            onChanged: (value) {
                                              setState(() {
                                                budgetRatios[category.id] =
                                                    int.tryParse(value) ?? 0;
                                              });
                                            },
                                          ),
                                        ),
                                        SizedBox(width: 10),

                                        // 일일 예산 체크박스
                                        GestureDetector(
                                          onTap: () {
                                            setState(
                                              () => includeInDaily[category.id] =
                                                  !(includeInDaily[category.id] ?? false),
                                            );
                                          },

                                          child: Icon(
                                            (includeInDaily[category.id] ?? false)
                                                ? Icons.calendar_month
                                                : Icons.calendar_month_outlined,
                                            color: (includeInDaily[category.id] ?? false)
                                                ? primaryColor
                                                : Colors.grey[300],
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        // 홈화면 표시
                                        GestureDetector(
                                          onTap: () {
                                            final currentShowOnHome =
                                                showOnHome[category.id] ?? false;
                                            if (!currentShowOnHome &&
                                                showOnHome.values
                                                        .where((v) => v)
                                                        .length >=
                                                    5) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    '홈화면에는 최대 5개까지 표시할 수 있어요',
                                                  ),
                                                ),
                                              );
                                              return;
                                            }
                                            setState(
                                              () => showOnHome[category.id] =
                                                  !currentShowOnHome,
                                            );
                                          },
                                          child: Icon(
                                            (showOnHome[category.id] ?? false)
                                                ? Icons.home
                                                : Icons.home_outlined,
                                            color: (showOnHome[category.id] ?? false)
                                                ? primaryColor
                                                : Colors.grey[300],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                                Divider(color: Colors.grey[200]),
                                SizedBox(height: 12),
                                Padding(
                                  padding: EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 60,
                                        child: Text('저축', style: TextStyle(fontSize: 13)),
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: TextField(
                                          controller: savingRatioController,
                                          decoration: inputDecoration('%'),
                                          keyboardType: TextInputType.number,
                                          onChanged: (value) {
                                            setState(
                                              () =>
                                                  savingRatio = int.tryParse(value) ?? 0,
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 60,
                                        child: Text('투자', style: TextStyle(fontSize: 13)),
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: TextField(
                                          controller: investRatioController,
                                          decoration: inputDecoration('%'),
                                          keyboardType: TextInputType.number,
                                          onChanged: (value) {
                                            setState(
                                              () =>
                                                  investRatio = int.tryParse(value) ?? 0,
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // 버튼
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final totalRatio =
                                visibleCategories.fold(
                                  // 보이는 카테고리만 순회
                                  0, // 시작값 0
                                  (sum, c) =>
                                      sum +
                                      (budgetRatios[c.id] ?? 0), // 그 카테고리 비율을 더함, 없으면 0
                                ) +
                                savingRatio +
                                investRatio;

                            if (totalRatio != 100) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('비율 합계가 100%가 되어야 합니다. 현재: $totalRatio'),
                                ),
                              );
                              return;
                            }

                            // BudgetModel 생성 (서버 BudgetRatioRequest 모양)
                            final budget = BudgetModel(
                              applyFrom: selectedMonth, // 이 월부터 적용
                              savingRatio: savingRatio,
                              investRatio: investRatio,
                              categories:
                                  visibleCategories // 삭제 예정 카테고리 제외
                                      .map(
                                        (c) => CategoryRatio(
                                          categoryId: c.id,
                                          name: c.name, // toJson에서는 빠짐
                                          ratio: budgetRatios[c.id] ?? 0,
                                        ),
                                      )
                                      .toList(),
                            );

                            try {
                              // 비율 저장 (합계 100, 지난 달 여부는 서버가 다시 검증)
                              await _budgetService.saveRatios(budget);

                              // 비율을 먼저 저장해야 삭제 가능: 이번 달 비율에 남아 있으면 서버가 삭제를 막음
                              if (widget.deleteCategoryId != null) {
                                await _budgetCategoryService.deleteCategory(
                                  widget.deleteCategoryId!,
                                );
                              }

                              // showOnHome, includeInDaily 업데이트
                              // - visibleCategories: 방금 삭제한 카테고리는 서버에서 404가 나므로 제외
                              // - 정렬: 홈 표시를 끄는 카테고리를 먼저 보내야 서버의 "홈 최대 5개" 검사에 걸리지 않음
                              final toUpdate = [...visibleCategories]
                                ..sort(
                                  (a, b) => ((showOnHome[a.id] ?? false) ? 1 : 0)
                                      .compareTo((showOnHome[b.id] ?? false) ? 1 : 0),
                                );
                              for (var c in toUpdate) {
                                c.showOnHome = showOnHome[c.id] ?? false;
                                c.includeInDaily = includeInDaily[c.id] ?? false;
                                await _budgetCategoryService.updateCategory(c);
                              }
                            } on DioException catch (e) {
                              // 서버 검증 실패(400), 서버 꺼짐 등 → 화면을 닫지 않고 메시지만
                              if (!context.mounted) return; // 아래에서 쓰는 context가 살아 있는지 검사
                              final message = e.response?.data?['message'] ?? '저장에 실패했어요.';
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text(message)));
                              return;
                            }

                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                          child: Text('저장'),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('돌아가기'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
