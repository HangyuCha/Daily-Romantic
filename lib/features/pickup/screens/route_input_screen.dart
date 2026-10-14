import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/choice_chip_group.dart';
import '../../../shared/widgets/page_scaffold.dart';
import '../data/models.dart';
import 'store_list_screen.dart';

/// S1. 홈 — 경로(필수) + 받는 사람 + 카테고리 입력
class RouteInputScreen extends StatefulWidget {
  const RouteInputScreen({super.key});

  @override
  State<RouteInputScreen> createState() => _RouteInputScreenState();
}

class _RouteInputScreenState extends State<RouteInputScreen> {
  // 위치 검색이 붙기 전까지 프로토타입 기본값을 넣어 둔다.
  final _origin = TextEditingController(text: '홍대입구역');
  final _destination = TextEditingController(text: '신촌 연세로 카페');
  var _recipient = Recipient.school;
  var _category = GiftCategory.all;

  @override
  void initState() {
    super.initState();
    _origin.addListener(_refresh);
    _destination.addListener(_refresh);
  }

  @override
  void dispose() {
    _origin.dispose();
    _destination.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  bool get _canSearch =>
      _origin.text.trim().isNotEmpty && _destination.text.trim().isNotEmpty;

  void _search() {
    FocusScope.of(context).unfocus();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StoreListScreen(
          query: RouteQuery(
            origin: _origin.text.trim(),
            destination: _destination.text.trim(),
            recipient: _recipient,
            category: _category,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return Scaffold(
      body: PageScaffold(
        title: '어디로 가세요?',
        subtitle: '목적지로 가는 길목에서 15분 안에 들를 수 있는 가게를 찾아드려요.',
        bottom: FilledButton(
          onPressed: _canSearch ? _search : null,
          child: const Text('가는 길 가게 찾기'),
        ),
        children: [
          _LocationField(
            controller: _origin,
            label: '현재 위치',
            icon: Icons.my_location_rounded,
          ),
          const SizedBox(height: AppSpacing.sm),
          _LocationField(
            controller: _destination,
            label: '목적지',
            icon: Icons.place_rounded,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('누구에게 주실 건가요?', style: labelStyle),
          const SizedBox(height: AppSpacing.sm),
          ChoiceChipGroup<Recipient>(
            options: Recipient.values,
            selected: _recipient,
            labelOf: (r) => r.label,
            onSelected: (r) => setState(() => _recipient = r),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('무엇을 찾으세요?', style: labelStyle),
          const SizedBox(height: AppSpacing.sm),
          ChoiceChipGroup<GiftCategory>(
            options: GiftCategory.filterOptions,
            selected: _category,
            labelOf: (c) => c.label,
            onSelected: (c) => setState(() => _category = c),
          ),
        ],
      ),
    );
  }
}

class _LocationField extends StatelessWidget {
  const _LocationField({
    required this.controller,
    required this.label,
    required this.icon,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: scheme.primary, size: 20),
        labelText: label,
        hintText: '$label을(를) 입력하세요',
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }
}
