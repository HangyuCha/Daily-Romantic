import 'package:flutter/material.dart';

import '../../../core/location/geo.dart';
import '../../../core/location/location_service.dart';
import '../../../core/location/map_services.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/choice_chip_group.dart';
import '../../../shared/widgets/page_scaffold.dart';
import '../data/models.dart';
import 'store_list_screen.dart';

/// S1. 홈 — 경로(필수) + 받는 사람 + 카테고리 입력
/// 출발지는 GPS 현재 위치로 채우고, 목적지는 장소 이름으로 검색한다.
class RouteInputScreen extends StatefulWidget {
  const RouteInputScreen({super.key});

  @override
  State<RouteInputScreen> createState() => _RouteInputScreenState();
}

class _RouteInputScreenState extends State<RouteInputScreen> {
  final _origin = TextEditingController();
  final _destination = TextEditingController(text: '신촌역');
  var _recipient = Recipient.school;
  var _category = GiftCategory.all;

  /// GPS로 잡은 출발지. 사용자가 출발지 글자를 고치면 null이 되고 이름으로 검색한다.
  LatLng? _gpsPoint;
  String? _gpsLabel;
  var _locating = false;
  String? _locationError;
  var _searching = false;

  @override
  void initState() {
    super.initState();
    _origin.addListener(_onOriginEdited);
    _destination.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) => _locate());
  }

  @override
  void dispose() {
    _origin.dispose();
    _destination.dispose();
    super.dispose();
  }

  void _onOriginEdited() {
    if (_gpsPoint != null && _origin.text != _gpsLabel) _gpsPoint = null;
    setState(() {});
  }

  Future<void> _locate() async {
    final services = MapScope.of(context);
    setState(() {
      _locating = true;
      _locationError = null;
    });
    try {
      final point = await services.location.currentPosition();
      String? name;
      try {
        name = await services.places.nameOf(point);
      } catch (_) {
        // 이름을 못 가져와도 좌표는 쓸 수 있다.
      }
      if (!mounted) return;
      _gpsLabel = name ?? '현재 위치';
      _origin.text = _gpsLabel!;
      _gpsPoint = point;
    } on LocationFailure catch (e) {
      if (mounted) setState(() => _locationError = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _locationError = '현재 위치를 찾지 못했어요. 출발지를 직접 입력해 주세요.');
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  bool get _canSearch =>
      !_searching &&
      !_locating &&
      _origin.text.trim().isNotEmpty &&
      _destination.text.trim().isNotEmpty;

  Future<void> _search() async {
    FocusScope.of(context).unfocus();
    final services = MapScope.of(context);
    final navigator = Navigator.of(context);
    setState(() => _searching = true);
    try {
      final origin = _gpsPoint != null
          ? Place(name: _origin.text.trim(), point: _gpsPoint!)
          : await _findPlace(_origin.text.trim());
      if (origin == null) return;
      final destination = await _findPlace(
        _destination.text.trim(),
        near: origin.point,
      );
      if (destination == null) return;

      final route = await services.routing.walkingRoute(
        origin.point,
        destination.point,
      );
      if (route.distanceMeters > 20000) {
        _showMessage(
          '걸어가기엔 너무 멀어요 (${(route.distanceMeters / 1000).round()}km). '
          '가까운 목적지를 골라 주세요.',
        );
        return;
      }
      if (!mounted) return;
      navigator.push(
        MaterialPageRoute(
          builder: (_) => StoreListScreen(
            query: RouteQuery(
              origin: origin,
              destination: destination,
              route: route,
              recipient: _recipient,
              category: _category,
            ),
          ),
        ),
      );
    } catch (_) {
      _showMessage('경로를 찾지 못했어요. 인터넷 연결을 확인해 주세요.');
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  /// 장소 이름으로 검색한다. 결과가 여러 개면 사용자가 고르게 한다.
  Future<Place?> _findPlace(String query, {LatLng? near}) async {
    final results = await MapScope.of(context).places.search(query, near: near);
    if (results.isEmpty) {
      _showMessage("'$query'을(를) 찾지 못했어요. 역이나 건물 이름으로 검색해 보세요.");
      return null;
    }
    if (results.length == 1 || !mounted) return results.first;
    return showModalBottomSheet<Place>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _PlacePickerSheet(query: query, places: results),
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final labelStyle = theme.textTheme.bodyMedium?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    return Scaffold(
      body: PageScaffold(
        title: '어디로 가세요?',
        subtitle: '목적지로 가는 길목에서 15분 안에 들를 수 있는 가게를 찾아드려요.',
        bottom: FilledButton(
          onPressed: _canSearch ? _search : null,
          child: _searching
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('가는 길 가게 찾기'),
        ),
        children: [
          TextField(
            controller: _origin,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              prefixIcon: Icon(
                _gpsPoint != null
                    ? Icons.my_location_rounded
                    : Icons.location_searching_rounded,
                color: scheme.primary,
                size: 20,
              ),
              labelText: '현재 위치',
              hintText: _locating ? '현재 위치를 찾는 중…' : '출발지를 입력하세요',
              floatingLabelBehavior: FloatingLabelBehavior.always,
              helperText: _locationError,
              helperMaxLines: 2,
              helperStyle: TextStyle(color: scheme.primary),
              suffixIcon: _locating
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      tooltip: '현재 위치로 설정',
                      onPressed: _locate,
                      icon: const Icon(Icons.gps_fixed_rounded, size: 20),
                    ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _destination,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _canSearch ? _search() : null,
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.place_rounded,
                color: scheme.primary,
                size: 20,
              ),
              labelText: '목적지',
              hintText: '역, 건물, 장소 이름 (예: 신촌역)',
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
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

class _PlacePickerSheet extends StatelessWidget {
  const _PlacePickerSheet({required this.query, required this.places});

  final String query;
  final List<Place> places;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.6,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                0,
                AppSpacing.screenPadding,
                AppSpacing.sm,
              ),
              child: Text(
                "'$query' 중 어디인가요?",
                style: theme.textTheme.titleMedium,
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final place in places)
                    ListTile(
                      leading: Icon(
                        Icons.place_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      title: Text(place.name),
                      subtitle: place.address == null
                          ? null
                          : Text(place.address!),
                      onTap: () => Navigator.of(context).pop(place),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}
