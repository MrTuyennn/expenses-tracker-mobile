import 'package:equatable/equatable.dart';
import 'package:expense_tracker_mobile/core/services/category_cache_service.dart';
import 'package:expense_tracker_mobile/data/models/request/category_request.dart';
import 'package:expense_tracker_mobile/domain/usecases/create_category_usecase.dart';
import 'package:expense_tracker_mobile/domain/usecases/delete_category_usecase.dart';
import 'package:expense_tracker_mobile/domain/usecases/get_category_usecase.dart';
import 'package:expense_tracker_mobile/domain/usecases/update_category_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failure.dart';
import '../../../../domain/dto/category_dto.dart';

part 'category_event.dart';
part 'category_state.dart';

@lazySingleton
class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final GetCategoryUsecase _getCategoryUsecase;
  final CreateCategoryUseCase _createCategoryUseCase;
  final UpdateCategoryUsecase _updateCategoryUsecase;
  final DeleteCategoryUsecase _deleteCategoryUsecase;
  final CategoryCacheService _cacheService;

  CategoryBloc(
    this._getCategoryUsecase,
    this._createCategoryUseCase,
    this._updateCategoryUsecase,
    this._deleteCategoryUsecase,
    this._cacheService,
  ) : super(CategoryInitial()) {
    on<GetCategoryEvent>(_onGetCategory);
    on<CreateCategoryEvent>(_onCreateCategory);
    on<UpdateCategoryEvent>(_onUpdateCategory);
    on<DeleteCategoryEvent>(_onDeleteCategory);
  }

  Future<void> _onGetCategory(GetCategoryEvent event, Emitter<CategoryState> emit) async {
    emit(CategoryLoading());
    try {
      final categories = await _cacheService.getCategories(_getCategoryUsecase);
      emit(CategoryLoaded(categories: categories));
    } catch (e) {
      if (e is Failure) {
        emit(CategoryError(failure: e));
      } else {
        emit(CategoryError(failure: UnknownFailure(message: e.toString())));
      }
    }
  }

  Future<void> _onCreateCategory(CreateCategoryEvent event, Emitter<CategoryState> emit) async {
    emit(CategoryLoading());
    final request = CategoryRequest(name: event.name);
    final result = await _createCategoryUseCase.call(request);
    result.fold((failure) => emit(CategoryError(failure: failure)), (message) {
      _cacheService.invalidate();
      emit(CreateCategorySuccess(message: message));
    });
  }

  Future<void> _onUpdateCategory(UpdateCategoryEvent event, Emitter<CategoryState> emit) async {
    emit(UpdateCategoryLoading());
    final result = await _updateCategoryUsecase.call(event.id, CategoryRequest(name: event.name));
    result.fold((failure) => emit(UpdateCategoryError(failure: failure)), (message) {
      _cacheService.invalidate();
      emit(UpdateCategorySuccess(message: message));
    });
  }

  Future<void> _onDeleteCategory(DeleteCategoryEvent event, Emitter<CategoryState> emit) async {
    emit(DeleteCategoryLoading());
    final result = await _deleteCategoryUsecase.call(event.id);
    result.fold((failure) => emit(DeleteCategoryError(failure: failure)), (message) {
      _cacheService.invalidate();
      emit(DeleteCategorySuccess());
    });
  }
}
