import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';

class BoardWritePage extends StatefulWidget {
  const BoardWritePage({super.key});

  @override
  State<BoardWritePage> createState() => _BoardWritePageState();
}

class _BoardWritePageState extends State<BoardWritePage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _category = '공지사항';

  final _categories = ['공지사항', '자료실', '자료게시판', '프로그램'];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('글쓰기', style: AppTypography.h3),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              '등록',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const Divider(color: AppColors.border, height: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 카테고리 선택
                  Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundSubtle,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _category,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textHint, size: 18),
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
                        dropdownColor: AppColors.backgroundWhite,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        items: _categories
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) => setState(() => _category = v!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: AppColors.border, height: 1),
                  // 제목 입력
                  TextField(
                    controller: _titleController,
                    style: AppTypography.h4.copyWith(fontSize: 18),
                    decoration: InputDecoration(
                      hintText: '제목을 입력하세요',
                      hintStyle: AppTypography.h4.copyWith(fontSize: 18, color: AppColors.textHint),
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    ),
                  ),
                  const Divider(color: AppColors.border, height: 1),
                  // 내용 입력
                  Expanded(
                    child: TextField(
                      controller: _contentController,
                      maxLines: null,
                      expands: true,
                      style: AppTypography.bodyMedium,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: InputDecoration(
                        hintText: '내용을 입력하세요',
                        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textHint),
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 하단 툴바
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border, width: 1)),
              color: AppColors.backgroundWhite,
            ),
            padding: EdgeInsets.only(
              left: 8,
              right: 8,
              top: 8,
              bottom: 8 + MediaQuery.of(context).padding.bottom,
            ),
            child: Row(
              children: [
                _ToolbarButton(icon: Icons.attach_file, onTap: () {}),
                _ToolbarButton(icon: Icons.link, onTap: () {}),
                _ToolbarButton(icon: Icons.bar_chart, onTap: () {}),
                _ToolbarButton(
                  child: Text('B', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w900)),
                  onTap: () {},
                ),
                _ToolbarButton(
                  child: Text('I', style: AppTypography.bodyMedium.copyWith(fontStyle: FontStyle.italic)),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData? icon;
  final Widget? child;
  final VoidCallback onTap;

  const _ToolbarButton({this.icon, this.child, required this.onTap})
      : assert(icon != null || child != null);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        child: Center(
          child: icon != null
              ? Icon(icon, color: AppColors.textSecondary, size: 22)
              : child,
        ),
      ),
    );
  }
}
