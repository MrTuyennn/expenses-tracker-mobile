import 'package:expense_tracker_mobile/domain/dto/category_dto.dart';
import 'package:expense_tracker_mobile/domain/usecases/get_category_usecase.dart';
import 'package:injectable/injectable.dart';

/// Service for caching categories in memory to reduce redundant API calls.
/// Categories are cached for 5 minutes and shared across all BLoCs.
@lazySingleton
class CategoryCacheService {
  List<CategoryDto>? _cachedCategories;
  DateTime? _lastFetchTime;
  static const Duration _cacheDuration = Duration(minutes: 5);

  Future<List<CategoryDto>> getCategories(GetCategoryUsecase usecase) async {
    if (_cachedCategories != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
      return _cachedCategories!;
    }

    final result = await usecase.call();
    return result.fold((failure) => throw failure, (categories) {
      _cachedCategories = categories;
      _lastFetchTime = DateTime.now();
      return categories;
    });
  }

  void invalidate() {
    _cachedCategories = null;
    _lastFetchTime = null;
  }

  bool get isCacheValid {
    return _cachedCategories != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheDuration;
  }
}
