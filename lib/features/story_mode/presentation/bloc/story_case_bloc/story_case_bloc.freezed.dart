// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'story_case_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$StoryCaseEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadTodayCase,
    required TResult Function() retry,
    required TResult Function(StoryModeProgressEntity progress) progressUpdated,
    required TResult Function() resetForLogout,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadTodayCase,
    TResult? Function()? retry,
    TResult? Function(StoryModeProgressEntity progress)? progressUpdated,
    TResult? Function()? resetForLogout,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadTodayCase,
    TResult Function()? retry,
    TResult Function(StoryModeProgressEntity progress)? progressUpdated,
    TResult Function()? resetForLogout,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadTodayCase value) loadTodayCase,
    required TResult Function(Retry value) retry,
    required TResult Function(ProgressUpdated value) progressUpdated,
    required TResult Function(ResetForLogout value) resetForLogout,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadTodayCase value)? loadTodayCase,
    TResult? Function(Retry value)? retry,
    TResult? Function(ProgressUpdated value)? progressUpdated,
    TResult? Function(ResetForLogout value)? resetForLogout,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadTodayCase value)? loadTodayCase,
    TResult Function(Retry value)? retry,
    TResult Function(ProgressUpdated value)? progressUpdated,
    TResult Function(ResetForLogout value)? resetForLogout,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StoryCaseEventCopyWith<$Res> {
  factory $StoryCaseEventCopyWith(
          StoryCaseEvent value, $Res Function(StoryCaseEvent) then) =
      _$StoryCaseEventCopyWithImpl<$Res, StoryCaseEvent>;
}

/// @nodoc
class _$StoryCaseEventCopyWithImpl<$Res, $Val extends StoryCaseEvent>
    implements $StoryCaseEventCopyWith<$Res> {
  _$StoryCaseEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StoryCaseEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$LoadTodayCaseImplCopyWith<$Res> {
  factory _$$LoadTodayCaseImplCopyWith(
          _$LoadTodayCaseImpl value, $Res Function(_$LoadTodayCaseImpl) then) =
      __$$LoadTodayCaseImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoadTodayCaseImplCopyWithImpl<$Res>
    extends _$StoryCaseEventCopyWithImpl<$Res, _$LoadTodayCaseImpl>
    implements _$$LoadTodayCaseImplCopyWith<$Res> {
  __$$LoadTodayCaseImplCopyWithImpl(
      _$LoadTodayCaseImpl _value, $Res Function(_$LoadTodayCaseImpl) _then)
      : super(_value, _then);

  /// Create a copy of StoryCaseEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LoadTodayCaseImpl implements LoadTodayCase {
  const _$LoadTodayCaseImpl();

  @override
  String toString() {
    return 'StoryCaseEvent.loadTodayCase()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LoadTodayCaseImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadTodayCase,
    required TResult Function() retry,
    required TResult Function(StoryModeProgressEntity progress) progressUpdated,
    required TResult Function() resetForLogout,
  }) {
    return loadTodayCase();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadTodayCase,
    TResult? Function()? retry,
    TResult? Function(StoryModeProgressEntity progress)? progressUpdated,
    TResult? Function()? resetForLogout,
  }) {
    return loadTodayCase?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadTodayCase,
    TResult Function()? retry,
    TResult Function(StoryModeProgressEntity progress)? progressUpdated,
    TResult Function()? resetForLogout,
    required TResult orElse(),
  }) {
    if (loadTodayCase != null) {
      return loadTodayCase();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadTodayCase value) loadTodayCase,
    required TResult Function(Retry value) retry,
    required TResult Function(ProgressUpdated value) progressUpdated,
    required TResult Function(ResetForLogout value) resetForLogout,
  }) {
    return loadTodayCase(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadTodayCase value)? loadTodayCase,
    TResult? Function(Retry value)? retry,
    TResult? Function(ProgressUpdated value)? progressUpdated,
    TResult? Function(ResetForLogout value)? resetForLogout,
  }) {
    return loadTodayCase?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadTodayCase value)? loadTodayCase,
    TResult Function(Retry value)? retry,
    TResult Function(ProgressUpdated value)? progressUpdated,
    TResult Function(ResetForLogout value)? resetForLogout,
    required TResult orElse(),
  }) {
    if (loadTodayCase != null) {
      return loadTodayCase(this);
    }
    return orElse();
  }
}

abstract class LoadTodayCase implements StoryCaseEvent {
  const factory LoadTodayCase() = _$LoadTodayCaseImpl;
}

/// @nodoc
abstract class _$$RetryImplCopyWith<$Res> {
  factory _$$RetryImplCopyWith(
          _$RetryImpl value, $Res Function(_$RetryImpl) then) =
      __$$RetryImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$RetryImplCopyWithImpl<$Res>
    extends _$StoryCaseEventCopyWithImpl<$Res, _$RetryImpl>
    implements _$$RetryImplCopyWith<$Res> {
  __$$RetryImplCopyWithImpl(
      _$RetryImpl _value, $Res Function(_$RetryImpl) _then)
      : super(_value, _then);

  /// Create a copy of StoryCaseEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$RetryImpl implements Retry {
  const _$RetryImpl();

  @override
  String toString() {
    return 'StoryCaseEvent.retry()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$RetryImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadTodayCase,
    required TResult Function() retry,
    required TResult Function(StoryModeProgressEntity progress) progressUpdated,
    required TResult Function() resetForLogout,
  }) {
    return retry();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadTodayCase,
    TResult? Function()? retry,
    TResult? Function(StoryModeProgressEntity progress)? progressUpdated,
    TResult? Function()? resetForLogout,
  }) {
    return retry?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadTodayCase,
    TResult Function()? retry,
    TResult Function(StoryModeProgressEntity progress)? progressUpdated,
    TResult Function()? resetForLogout,
    required TResult orElse(),
  }) {
    if (retry != null) {
      return retry();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadTodayCase value) loadTodayCase,
    required TResult Function(Retry value) retry,
    required TResult Function(ProgressUpdated value) progressUpdated,
    required TResult Function(ResetForLogout value) resetForLogout,
  }) {
    return retry(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadTodayCase value)? loadTodayCase,
    TResult? Function(Retry value)? retry,
    TResult? Function(ProgressUpdated value)? progressUpdated,
    TResult? Function(ResetForLogout value)? resetForLogout,
  }) {
    return retry?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadTodayCase value)? loadTodayCase,
    TResult Function(Retry value)? retry,
    TResult Function(ProgressUpdated value)? progressUpdated,
    TResult Function(ResetForLogout value)? resetForLogout,
    required TResult orElse(),
  }) {
    if (retry != null) {
      return retry(this);
    }
    return orElse();
  }
}

abstract class Retry implements StoryCaseEvent {
  const factory Retry() = _$RetryImpl;
}

/// @nodoc
abstract class _$$ProgressUpdatedImplCopyWith<$Res> {
  factory _$$ProgressUpdatedImplCopyWith(_$ProgressUpdatedImpl value,
          $Res Function(_$ProgressUpdatedImpl) then) =
      __$$ProgressUpdatedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({StoryModeProgressEntity progress});
}

/// @nodoc
class __$$ProgressUpdatedImplCopyWithImpl<$Res>
    extends _$StoryCaseEventCopyWithImpl<$Res, _$ProgressUpdatedImpl>
    implements _$$ProgressUpdatedImplCopyWith<$Res> {
  __$$ProgressUpdatedImplCopyWithImpl(
      _$ProgressUpdatedImpl _value, $Res Function(_$ProgressUpdatedImpl) _then)
      : super(_value, _then);

  /// Create a copy of StoryCaseEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? progress = null,
  }) {
    return _then(_$ProgressUpdatedImpl(
      null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as StoryModeProgressEntity,
    ));
  }
}

/// @nodoc

class _$ProgressUpdatedImpl implements ProgressUpdated {
  const _$ProgressUpdatedImpl(this.progress);

  @override
  final StoryModeProgressEntity progress;

  @override
  String toString() {
    return 'StoryCaseEvent.progressUpdated(progress: $progress)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProgressUpdatedImpl &&
            (identical(other.progress, progress) ||
                other.progress == progress));
  }

  @override
  int get hashCode => Object.hash(runtimeType, progress);

  /// Create a copy of StoryCaseEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProgressUpdatedImplCopyWith<_$ProgressUpdatedImpl> get copyWith =>
      __$$ProgressUpdatedImplCopyWithImpl<_$ProgressUpdatedImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadTodayCase,
    required TResult Function() retry,
    required TResult Function(StoryModeProgressEntity progress) progressUpdated,
    required TResult Function() resetForLogout,
  }) {
    return progressUpdated(progress);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadTodayCase,
    TResult? Function()? retry,
    TResult? Function(StoryModeProgressEntity progress)? progressUpdated,
    TResult? Function()? resetForLogout,
  }) {
    return progressUpdated?.call(progress);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadTodayCase,
    TResult Function()? retry,
    TResult Function(StoryModeProgressEntity progress)? progressUpdated,
    TResult Function()? resetForLogout,
    required TResult orElse(),
  }) {
    if (progressUpdated != null) {
      return progressUpdated(progress);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadTodayCase value) loadTodayCase,
    required TResult Function(Retry value) retry,
    required TResult Function(ProgressUpdated value) progressUpdated,
    required TResult Function(ResetForLogout value) resetForLogout,
  }) {
    return progressUpdated(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadTodayCase value)? loadTodayCase,
    TResult? Function(Retry value)? retry,
    TResult? Function(ProgressUpdated value)? progressUpdated,
    TResult? Function(ResetForLogout value)? resetForLogout,
  }) {
    return progressUpdated?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadTodayCase value)? loadTodayCase,
    TResult Function(Retry value)? retry,
    TResult Function(ProgressUpdated value)? progressUpdated,
    TResult Function(ResetForLogout value)? resetForLogout,
    required TResult orElse(),
  }) {
    if (progressUpdated != null) {
      return progressUpdated(this);
    }
    return orElse();
  }
}

abstract class ProgressUpdated implements StoryCaseEvent {
  const factory ProgressUpdated(final StoryModeProgressEntity progress) =
      _$ProgressUpdatedImpl;

  StoryModeProgressEntity get progress;

  /// Create a copy of StoryCaseEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProgressUpdatedImplCopyWith<_$ProgressUpdatedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ResetForLogoutImplCopyWith<$Res> {
  factory _$$ResetForLogoutImplCopyWith(
          _$ResetForLogoutImpl value, $Res Function(_$ResetForLogoutImpl) then) =
      __$$ResetForLogoutImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ResetForLogoutImplCopyWithImpl<$Res>
    extends _$StoryCaseEventCopyWithImpl<$Res, _$ResetForLogoutImpl>
    implements _$$ResetForLogoutImplCopyWith<$Res> {
  __$$ResetForLogoutImplCopyWithImpl(
      _$ResetForLogoutImpl _value, $Res Function(_$ResetForLogoutImpl) _then)
      : super(_value, _then);

  /// Create a copy of StoryCaseEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$ResetForLogoutImpl implements ResetForLogout {
  const _$ResetForLogoutImpl();

  @override
  String toString() {
    return 'StoryCaseEvent.resetForLogout()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$ResetForLogoutImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadTodayCase,
    required TResult Function() retry,
    required TResult Function(StoryModeProgressEntity progress) progressUpdated,
    required TResult Function() resetForLogout,
  }) {
    return resetForLogout();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadTodayCase,
    TResult? Function()? retry,
    TResult? Function(StoryModeProgressEntity progress)? progressUpdated,
    TResult? Function()? resetForLogout,
  }) {
    return resetForLogout?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadTodayCase,
    TResult Function()? retry,
    TResult Function(StoryModeProgressEntity progress)? progressUpdated,
    TResult Function()? resetForLogout,
    required TResult orElse(),
  }) {
    if (resetForLogout != null) {
      return resetForLogout();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadTodayCase value) loadTodayCase,
    required TResult Function(Retry value) retry,
    required TResult Function(ProgressUpdated value) progressUpdated,
    required TResult Function(ResetForLogout value) resetForLogout,
  }) {
    return resetForLogout(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadTodayCase value)? loadTodayCase,
    TResult? Function(Retry value)? retry,
    TResult? Function(ProgressUpdated value)? progressUpdated,
    TResult? Function(ResetForLogout value)? resetForLogout,
  }) {
    return resetForLogout?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadTodayCase value)? loadTodayCase,
    TResult Function(Retry value)? retry,
    TResult Function(ProgressUpdated value)? progressUpdated,
    TResult Function(ResetForLogout value)? resetForLogout,
    required TResult orElse(),
  }) {
    if (resetForLogout != null) {
      return resetForLogout(this);
    }
    return orElse();
  }
}

abstract class ResetForLogout implements StoryCaseEvent {
  const factory ResetForLogout() = _$ResetForLogoutImpl;
}

/// @nodoc
mixin _$StoryCaseState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(DetectiveCaseEntity detectiveCase,
            StoryModeProgressEntity? progress)
        loaded,
    required TResult Function(
            DetectiveCaseEntity detectiveCase, StoryModeProgressEntity progress)
        alreadyCompleted,
    required TResult Function(String message) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(DetectiveCaseEntity detectiveCase,
            StoryModeProgressEntity? progress)?
        loaded,
    TResult? Function(DetectiveCaseEntity detectiveCase,
            StoryModeProgressEntity progress)?
        alreadyCompleted,
    TResult? Function(String message)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(DetectiveCaseEntity detectiveCase,
            StoryModeProgressEntity? progress)?
        loaded,
    TResult Function(DetectiveCaseEntity detectiveCase,
            StoryModeProgressEntity progress)?
        alreadyCompleted,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_AlreadyCompleted value) alreadyCompleted,
    required TResult Function(_Error value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_AlreadyCompleted value)? alreadyCompleted,
    TResult? Function(_Error value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_AlreadyCompleted value)? alreadyCompleted,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StoryCaseStateCopyWith<$Res> {
  factory $StoryCaseStateCopyWith(
          StoryCaseState value, $Res Function(StoryCaseState) then) =
      _$StoryCaseStateCopyWithImpl<$Res, StoryCaseState>;
}

/// @nodoc
class _$StoryCaseStateCopyWithImpl<$Res, $Val extends StoryCaseState>
    implements $StoryCaseStateCopyWith<$Res> {
  _$StoryCaseStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StoryCaseState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$InitialImplCopyWith<$Res> {
  factory _$$InitialImplCopyWith(
          _$InitialImpl value, $Res Function(_$InitialImpl) then) =
      __$$InitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$InitialImplCopyWithImpl<$Res>
    extends _$StoryCaseStateCopyWithImpl<$Res, _$InitialImpl>
    implements _$$InitialImplCopyWith<$Res> {
  __$$InitialImplCopyWithImpl(
      _$InitialImpl _value, $Res Function(_$InitialImpl) _then)
      : super(_value, _then);

  /// Create a copy of StoryCaseState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$InitialImpl implements _Initial {
  const _$InitialImpl();

  @override
  String toString() {
    return 'StoryCaseState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$InitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(DetectiveCaseEntity detectiveCase,
            StoryModeProgressEntity? progress)
        loaded,
    required TResult Function(
            DetectiveCaseEntity detectiveCase, StoryModeProgressEntity progress)
        alreadyCompleted,
    required TResult Function(String message) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(DetectiveCaseEntity detectiveCase,
            StoryModeProgressEntity? progress)?
        loaded,
    TResult? Function(DetectiveCaseEntity detectiveCase,
            StoryModeProgressEntity progress)?
        alreadyCompleted,
    TResult? Function(String message)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(DetectiveCaseEntity detectiveCase,
            StoryModeProgressEntity? progress)?
        loaded,
    TResult Function(DetectiveCaseEntity detectiveCase,
            StoryModeProgressEntity progress)?
        alreadyCompleted,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_AlreadyCompleted value) alreadyCompleted,
    required TResult Function(_Error value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_AlreadyCompleted value)? alreadyCompleted,
    TResult? Function(_Error value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_AlreadyCompleted value)? alreadyCompleted,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _Initial implements StoryCaseState {
  const factory _Initial() = _$InitialImpl;
}

/// @nodoc
abstract class _$$LoadingImplCopyWith<$Res> {
  factory _$$LoadingImplCopyWith(
          _$LoadingImpl value, $Res Function(_$LoadingImpl) then) =
      __$$LoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoadingImplCopyWithImpl<$Res>
    extends _$StoryCaseStateCopyWithImpl<$Res, _$LoadingImpl>
    implements _$$LoadingImplCopyWith<$Res> {
  __$$LoadingImplCopyWithImpl(
      _$LoadingImpl _value, $Res Function(_$LoadingImpl) _then)
      : super(_value, _then);

  /// Create a copy of StoryCaseState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LoadingImpl implements _Loading {
  const _$LoadingImpl();

  @override
  String toString() {
    return 'StoryCaseState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(DetectiveCaseEntity detectiveCase,
            StoryModeProgressEntity? progress)
        loaded,
    required TResult Function(
            DetectiveCaseEntity detectiveCase, StoryModeProgressEntity progress)
        alreadyCompleted,
    required TResult Function(String message) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(DetectiveCaseEntity detectiveCase,
            StoryModeProgressEntity? progress)?
        loaded,
    TResult? Function(DetectiveCaseEntity detectiveCase,
            StoryModeProgressEntity progress)?
        alreadyCompleted,
    TResult? Function(String message)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(DetectiveCaseEntity detectiveCase,
            StoryModeProgressEntity? progress)?
        loaded,
    TResult Function(DetectiveCaseEntity detectiveCase,
            StoryModeProgressEntity progress)?
        alreadyCompleted,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_AlreadyCompleted value) alreadyCompleted,
    required TResult Function(_Error value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_AlreadyCompleted value)? alreadyCompleted,
    TResult? Function(_Error value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_AlreadyCompleted value)? alreadyCompleted,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _Loading implements StoryCaseState {
  const factory _Loading() = _$LoadingImpl;
}

/// @nodoc
abstract class _$$LoadedImplCopyWith<$Res> {
  factory _$$LoadedImplCopyWith(
          _$LoadedImpl value, $Res Function(_$LoadedImpl) then) =
      __$$LoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {DetectiveCaseEntity detectiveCase, StoryModeProgressEntity? progress});
}

/// @nodoc
class __$$LoadedImplCopyWithImpl<$Res>
    extends _$StoryCaseStateCopyWithImpl<$Res, _$LoadedImpl>
    implements _$$LoadedImplCopyWith<$Res> {
  __$$LoadedImplCopyWithImpl(
      _$LoadedImpl _value, $Res Function(_$LoadedImpl) _then)
      : super(_value, _then);

  /// Create a copy of StoryCaseState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? detectiveCase = null,
    Object? progress = freezed,
  }) {
    return _then(_$LoadedImpl(
      detectiveCase: null == detectiveCase
          ? _value.detectiveCase
          : detectiveCase // ignore: cast_nullable_to_non_nullable
              as DetectiveCaseEntity,
      progress: freezed == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as StoryModeProgressEntity?,
    ));
  }
}

/// @nodoc

class _$LoadedImpl implements _Loaded {
  const _$LoadedImpl({required this.detectiveCase, this.progress});

  @override
  final DetectiveCaseEntity detectiveCase;
  @override
  final StoryModeProgressEntity? progress;

  @override
  String toString() {
    return 'StoryCaseState.loaded(detectiveCase: $detectiveCase, progress: $progress)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoadedImpl &&
            (identical(other.detectiveCase, detectiveCase) ||
                other.detectiveCase == detectiveCase) &&
            (identical(other.progress, progress) ||
                other.progress == progress));
  }

  @override
  int get hashCode => Object.hash(runtimeType, detectiveCase, progress);

  /// Create a copy of StoryCaseState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoadedImplCopyWith<_$LoadedImpl> get copyWith =>
      __$$LoadedImplCopyWithImpl<_$LoadedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(DetectiveCaseEntity detectiveCase,
            StoryModeProgressEntity? progress)
        loaded,
    required TResult Function(
            DetectiveCaseEntity detectiveCase, StoryModeProgressEntity progress)
        alreadyCompleted,
    required TResult Function(String message) error,
  }) {
    return loaded(detectiveCase, progress);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(DetectiveCaseEntity detectiveCase,
            StoryModeProgressEntity? progress)?
        loaded,
    TResult? Function(DetectiveCaseEntity detectiveCase,
            StoryModeProgressEntity progress)?
        alreadyCompleted,
    TResult? Function(String message)? error,
  }) {
    return loaded?.call(detectiveCase, progress);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(DetectiveCaseEntity detectiveCase,
            StoryModeProgressEntity? progress)?
        loaded,
    TResult Function(DetectiveCaseEntity detectiveCase,
            StoryModeProgressEntity progress)?
        alreadyCompleted,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(detectiveCase, progress);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_AlreadyCompleted value) alreadyCompleted,
    required TResult Function(_Error value) error,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_AlreadyCompleted value)? alreadyCompleted,
    TResult? Function(_Error value)? error,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_AlreadyCompleted value)? alreadyCompleted,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class _Loaded implements StoryCaseState {
  const factory _Loaded(
      {required final DetectiveCaseEntity detectiveCase,
      final StoryModeProgressEntity? progress}) = _$LoadedImpl;

  DetectiveCaseEntity get detectiveCase;
  StoryModeProgressEntity? get progress;

  /// Create a copy of StoryCaseState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoadedImplCopyWith<_$LoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AlreadyCompletedImplCopyWith<$Res> {
  factory _$$AlreadyCompletedImplCopyWith(_$AlreadyCompletedImpl value,
          $Res Function(_$AlreadyCompletedImpl) then) =
      __$$AlreadyCompletedImplCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {DetectiveCaseEntity detectiveCase, StoryModeProgressEntity progress});
}

/// @nodoc
class __$$AlreadyCompletedImplCopyWithImpl<$Res>
    extends _$StoryCaseStateCopyWithImpl<$Res, _$AlreadyCompletedImpl>
    implements _$$AlreadyCompletedImplCopyWith<$Res> {
  __$$AlreadyCompletedImplCopyWithImpl(_$AlreadyCompletedImpl _value,
      $Res Function(_$AlreadyCompletedImpl) _then)
      : super(_value, _then);

  /// Create a copy of StoryCaseState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? detectiveCase = null,
    Object? progress = null,
  }) {
    return _then(_$AlreadyCompletedImpl(
      detectiveCase: null == detectiveCase
          ? _value.detectiveCase
          : detectiveCase // ignore: cast_nullable_to_non_nullable
              as DetectiveCaseEntity,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as StoryModeProgressEntity,
    ));
  }
}

/// @nodoc

class _$AlreadyCompletedImpl implements _AlreadyCompleted {
  const _$AlreadyCompletedImpl(
      {required this.detectiveCase, required this.progress});

  @override
  final DetectiveCaseEntity detectiveCase;
  @override
  final StoryModeProgressEntity progress;

  @override
  String toString() {
    return 'StoryCaseState.alreadyCompleted(detectiveCase: $detectiveCase, progress: $progress)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AlreadyCompletedImpl &&
            (identical(other.detectiveCase, detectiveCase) ||
                other.detectiveCase == detectiveCase) &&
            (identical(other.progress, progress) ||
                other.progress == progress));
  }

  @override
  int get hashCode => Object.hash(runtimeType, detectiveCase, progress);

  /// Create a copy of StoryCaseState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AlreadyCompletedImplCopyWith<_$AlreadyCompletedImpl> get copyWith =>
      __$$AlreadyCompletedImplCopyWithImpl<_$AlreadyCompletedImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(DetectiveCaseEntity detectiveCase,
            StoryModeProgressEntity? progress)
        loaded,
    required TResult Function(
            DetectiveCaseEntity detectiveCase, StoryModeProgressEntity progress)
        alreadyCompleted,
    required TResult Function(String message) error,
  }) {
    return alreadyCompleted(detectiveCase, progress);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(DetectiveCaseEntity detectiveCase,
            StoryModeProgressEntity? progress)?
        loaded,
    TResult? Function(DetectiveCaseEntity detectiveCase,
            StoryModeProgressEntity progress)?
        alreadyCompleted,
    TResult? Function(String message)? error,
  }) {
    return alreadyCompleted?.call(detectiveCase, progress);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(DetectiveCaseEntity detectiveCase,
            StoryModeProgressEntity? progress)?
        loaded,
    TResult Function(DetectiveCaseEntity detectiveCase,
            StoryModeProgressEntity progress)?
        alreadyCompleted,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (alreadyCompleted != null) {
      return alreadyCompleted(detectiveCase, progress);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_AlreadyCompleted value) alreadyCompleted,
    required TResult Function(_Error value) error,
  }) {
    return alreadyCompleted(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_AlreadyCompleted value)? alreadyCompleted,
    TResult? Function(_Error value)? error,
  }) {
    return alreadyCompleted?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_AlreadyCompleted value)? alreadyCompleted,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (alreadyCompleted != null) {
      return alreadyCompleted(this);
    }
    return orElse();
  }
}

abstract class _AlreadyCompleted implements StoryCaseState {
  const factory _AlreadyCompleted(
          {required final DetectiveCaseEntity detectiveCase,
          required final StoryModeProgressEntity progress}) =
      _$AlreadyCompletedImpl;

  DetectiveCaseEntity get detectiveCase;
  StoryModeProgressEntity get progress;

  /// Create a copy of StoryCaseState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AlreadyCompletedImplCopyWith<_$AlreadyCompletedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ErrorImplCopyWith<$Res> {
  factory _$$ErrorImplCopyWith(
          _$ErrorImpl value, $Res Function(_$ErrorImpl) then) =
      __$$ErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$ErrorImplCopyWithImpl<$Res>
    extends _$StoryCaseStateCopyWithImpl<$Res, _$ErrorImpl>
    implements _$$ErrorImplCopyWith<$Res> {
  __$$ErrorImplCopyWithImpl(
      _$ErrorImpl _value, $Res Function(_$ErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of StoryCaseState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$ErrorImpl(
      null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ErrorImpl implements _Error {
  const _$ErrorImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'StoryCaseState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of StoryCaseState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      __$$ErrorImplCopyWithImpl<_$ErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(DetectiveCaseEntity detectiveCase,
            StoryModeProgressEntity? progress)
        loaded,
    required TResult Function(
            DetectiveCaseEntity detectiveCase, StoryModeProgressEntity progress)
        alreadyCompleted,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(DetectiveCaseEntity detectiveCase,
            StoryModeProgressEntity? progress)?
        loaded,
    TResult? Function(DetectiveCaseEntity detectiveCase,
            StoryModeProgressEntity progress)?
        alreadyCompleted,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(DetectiveCaseEntity detectiveCase,
            StoryModeProgressEntity? progress)?
        loaded,
    TResult Function(DetectiveCaseEntity detectiveCase,
            StoryModeProgressEntity progress)?
        alreadyCompleted,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_AlreadyCompleted value) alreadyCompleted,
    required TResult Function(_Error value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_AlreadyCompleted value)? alreadyCompleted,
    TResult? Function(_Error value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_AlreadyCompleted value)? alreadyCompleted,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _Error implements StoryCaseState {
  const factory _Error(final String message) = _$ErrorImpl;

  String get message;

  /// Create a copy of StoryCaseState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
