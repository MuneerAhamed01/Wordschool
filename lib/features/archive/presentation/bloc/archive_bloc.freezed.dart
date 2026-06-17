// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'archive_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ArchiveEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int year, int month) loadMonth,
    required TResult Function() previousMonth,
    required TResult Function() nextMonth,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int year, int month)? loadMonth,
    TResult? Function()? previousMonth,
    TResult? Function()? nextMonth,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int year, int month)? loadMonth,
    TResult Function()? previousMonth,
    TResult Function()? nextMonth,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadMonth value) loadMonth,
    required TResult Function(PreviousMonth value) previousMonth,
    required TResult Function(NextMonth value) nextMonth,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadMonth value)? loadMonth,
    TResult? Function(PreviousMonth value)? previousMonth,
    TResult? Function(NextMonth value)? nextMonth,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadMonth value)? loadMonth,
    TResult Function(PreviousMonth value)? previousMonth,
    TResult Function(NextMonth value)? nextMonth,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ArchiveEventCopyWith<$Res> {
  factory $ArchiveEventCopyWith(
          ArchiveEvent value, $Res Function(ArchiveEvent) then) =
      _$ArchiveEventCopyWithImpl<$Res, ArchiveEvent>;
}

/// @nodoc
class _$ArchiveEventCopyWithImpl<$Res, $Val extends ArchiveEvent>
    implements $ArchiveEventCopyWith<$Res> {
  _$ArchiveEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ArchiveEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$LoadMonthImplCopyWith<$Res> {
  factory _$$LoadMonthImplCopyWith(
          _$LoadMonthImpl value, $Res Function(_$LoadMonthImpl) then) =
      __$$LoadMonthImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int year, int month});
}

/// @nodoc
class __$$LoadMonthImplCopyWithImpl<$Res>
    extends _$ArchiveEventCopyWithImpl<$Res, _$LoadMonthImpl>
    implements _$$LoadMonthImplCopyWith<$Res> {
  __$$LoadMonthImplCopyWithImpl(
      _$LoadMonthImpl _value, $Res Function(_$LoadMonthImpl) _then)
      : super(_value, _then);

  /// Create a copy of ArchiveEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? year = null,
    Object? month = null,
  }) {
    return _then(_$LoadMonthImpl(
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
      month: null == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$LoadMonthImpl implements LoadMonth {
  const _$LoadMonthImpl({required this.year, required this.month});

  @override
  final int year;
  @override
  final int month;

  @override
  String toString() {
    return 'ArchiveEvent.loadMonth(year: $year, month: $month)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoadMonthImpl &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.month, month) || other.month == month));
  }

  @override
  int get hashCode => Object.hash(runtimeType, year, month);

  /// Create a copy of ArchiveEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoadMonthImplCopyWith<_$LoadMonthImpl> get copyWith =>
      __$$LoadMonthImplCopyWithImpl<_$LoadMonthImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int year, int month) loadMonth,
    required TResult Function() previousMonth,
    required TResult Function() nextMonth,
  }) {
    return loadMonth(year, month);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int year, int month)? loadMonth,
    TResult? Function()? previousMonth,
    TResult? Function()? nextMonth,
  }) {
    return loadMonth?.call(year, month);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int year, int month)? loadMonth,
    TResult Function()? previousMonth,
    TResult Function()? nextMonth,
    required TResult orElse(),
  }) {
    if (loadMonth != null) {
      return loadMonth(year, month);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadMonth value) loadMonth,
    required TResult Function(PreviousMonth value) previousMonth,
    required TResult Function(NextMonth value) nextMonth,
  }) {
    return loadMonth(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadMonth value)? loadMonth,
    TResult? Function(PreviousMonth value)? previousMonth,
    TResult? Function(NextMonth value)? nextMonth,
  }) {
    return loadMonth?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadMonth value)? loadMonth,
    TResult Function(PreviousMonth value)? previousMonth,
    TResult Function(NextMonth value)? nextMonth,
    required TResult orElse(),
  }) {
    if (loadMonth != null) {
      return loadMonth(this);
    }
    return orElse();
  }
}

abstract class LoadMonth implements ArchiveEvent {
  const factory LoadMonth({required final int year, required final int month}) =
      _$LoadMonthImpl;

  int get year;
  int get month;

  /// Create a copy of ArchiveEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoadMonthImplCopyWith<_$LoadMonthImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PreviousMonthImplCopyWith<$Res> {
  factory _$$PreviousMonthImplCopyWith(
          _$PreviousMonthImpl value, $Res Function(_$PreviousMonthImpl) then) =
      __$$PreviousMonthImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$PreviousMonthImplCopyWithImpl<$Res>
    extends _$ArchiveEventCopyWithImpl<$Res, _$PreviousMonthImpl>
    implements _$$PreviousMonthImplCopyWith<$Res> {
  __$$PreviousMonthImplCopyWithImpl(
      _$PreviousMonthImpl _value, $Res Function(_$PreviousMonthImpl) _then)
      : super(_value, _then);

  /// Create a copy of ArchiveEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$PreviousMonthImpl implements PreviousMonth {
  const _$PreviousMonthImpl();

  @override
  String toString() {
    return 'ArchiveEvent.previousMonth()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$PreviousMonthImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int year, int month) loadMonth,
    required TResult Function() previousMonth,
    required TResult Function() nextMonth,
  }) {
    return previousMonth();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int year, int month)? loadMonth,
    TResult? Function()? previousMonth,
    TResult? Function()? nextMonth,
  }) {
    return previousMonth?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int year, int month)? loadMonth,
    TResult Function()? previousMonth,
    TResult Function()? nextMonth,
    required TResult orElse(),
  }) {
    if (previousMonth != null) {
      return previousMonth();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadMonth value) loadMonth,
    required TResult Function(PreviousMonth value) previousMonth,
    required TResult Function(NextMonth value) nextMonth,
  }) {
    return previousMonth(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadMonth value)? loadMonth,
    TResult? Function(PreviousMonth value)? previousMonth,
    TResult? Function(NextMonth value)? nextMonth,
  }) {
    return previousMonth?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadMonth value)? loadMonth,
    TResult Function(PreviousMonth value)? previousMonth,
    TResult Function(NextMonth value)? nextMonth,
    required TResult orElse(),
  }) {
    if (previousMonth != null) {
      return previousMonth(this);
    }
    return orElse();
  }
}

abstract class PreviousMonth implements ArchiveEvent {
  const factory PreviousMonth() = _$PreviousMonthImpl;
}

/// @nodoc
abstract class _$$NextMonthImplCopyWith<$Res> {
  factory _$$NextMonthImplCopyWith(
          _$NextMonthImpl value, $Res Function(_$NextMonthImpl) then) =
      __$$NextMonthImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$NextMonthImplCopyWithImpl<$Res>
    extends _$ArchiveEventCopyWithImpl<$Res, _$NextMonthImpl>
    implements _$$NextMonthImplCopyWith<$Res> {
  __$$NextMonthImplCopyWithImpl(
      _$NextMonthImpl _value, $Res Function(_$NextMonthImpl) _then)
      : super(_value, _then);

  /// Create a copy of ArchiveEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$NextMonthImpl implements NextMonth {
  const _$NextMonthImpl();

  @override
  String toString() {
    return 'ArchiveEvent.nextMonth()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$NextMonthImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int year, int month) loadMonth,
    required TResult Function() previousMonth,
    required TResult Function() nextMonth,
  }) {
    return nextMonth();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int year, int month)? loadMonth,
    TResult? Function()? previousMonth,
    TResult? Function()? nextMonth,
  }) {
    return nextMonth?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int year, int month)? loadMonth,
    TResult Function()? previousMonth,
    TResult Function()? nextMonth,
    required TResult orElse(),
  }) {
    if (nextMonth != null) {
      return nextMonth();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadMonth value) loadMonth,
    required TResult Function(PreviousMonth value) previousMonth,
    required TResult Function(NextMonth value) nextMonth,
  }) {
    return nextMonth(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadMonth value)? loadMonth,
    TResult? Function(PreviousMonth value)? previousMonth,
    TResult? Function(NextMonth value)? nextMonth,
  }) {
    return nextMonth?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadMonth value)? loadMonth,
    TResult Function(PreviousMonth value)? previousMonth,
    TResult Function(NextMonth value)? nextMonth,
    required TResult orElse(),
  }) {
    if (nextMonth != null) {
      return nextMonth(this);
    }
    return orElse();
  }
}

abstract class NextMonth implements ArchiveEvent {
  const factory NextMonth() = _$NextMonthImpl;
}

/// @nodoc
mixin _$ArchiveState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(int year, int month,
            Map<String, UserGameDataEntity> gameHistoryByDate)
        loaded,
    required TResult Function(String message) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(int year, int month,
            Map<String, UserGameDataEntity> gameHistoryByDate)?
        loaded,
    TResult? Function(String message)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(int year, int month,
            Map<String, UserGameDataEntity> gameHistoryByDate)?
        loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ArchiveStateCopyWith<$Res> {
  factory $ArchiveStateCopyWith(
          ArchiveState value, $Res Function(ArchiveState) then) =
      _$ArchiveStateCopyWithImpl<$Res, ArchiveState>;
}

/// @nodoc
class _$ArchiveStateCopyWithImpl<$Res, $Val extends ArchiveState>
    implements $ArchiveStateCopyWith<$Res> {
  _$ArchiveStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ArchiveState
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
    extends _$ArchiveStateCopyWithImpl<$Res, _$InitialImpl>
    implements _$$InitialImplCopyWith<$Res> {
  __$$InitialImplCopyWithImpl(
      _$InitialImpl _value, $Res Function(_$InitialImpl) _then)
      : super(_value, _then);

  /// Create a copy of ArchiveState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$InitialImpl implements _Initial {
  const _$InitialImpl();

  @override
  String toString() {
    return 'ArchiveState.initial()';
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
    required TResult Function(int year, int month,
            Map<String, UserGameDataEntity> gameHistoryByDate)
        loaded,
    required TResult Function(String message) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(int year, int month,
            Map<String, UserGameDataEntity> gameHistoryByDate)?
        loaded,
    TResult? Function(String message)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(int year, int month,
            Map<String, UserGameDataEntity> gameHistoryByDate)?
        loaded,
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
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _Initial implements ArchiveState {
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
    extends _$ArchiveStateCopyWithImpl<$Res, _$LoadingImpl>
    implements _$$LoadingImplCopyWith<$Res> {
  __$$LoadingImplCopyWithImpl(
      _$LoadingImpl _value, $Res Function(_$LoadingImpl) _then)
      : super(_value, _then);

  /// Create a copy of ArchiveState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LoadingImpl implements _Loading {
  const _$LoadingImpl();

  @override
  String toString() {
    return 'ArchiveState.loading()';
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
    required TResult Function(int year, int month,
            Map<String, UserGameDataEntity> gameHistoryByDate)
        loaded,
    required TResult Function(String message) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(int year, int month,
            Map<String, UserGameDataEntity> gameHistoryByDate)?
        loaded,
    TResult? Function(String message)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(int year, int month,
            Map<String, UserGameDataEntity> gameHistoryByDate)?
        loaded,
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
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _Loading implements ArchiveState {
  const factory _Loading() = _$LoadingImpl;
}

/// @nodoc
abstract class _$$LoadedImplCopyWith<$Res> {
  factory _$$LoadedImplCopyWith(
          _$LoadedImpl value, $Res Function(_$LoadedImpl) then) =
      __$$LoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {int year, int month, Map<String, UserGameDataEntity> gameHistoryByDate});
}

/// @nodoc
class __$$LoadedImplCopyWithImpl<$Res>
    extends _$ArchiveStateCopyWithImpl<$Res, _$LoadedImpl>
    implements _$$LoadedImplCopyWith<$Res> {
  __$$LoadedImplCopyWithImpl(
      _$LoadedImpl _value, $Res Function(_$LoadedImpl) _then)
      : super(_value, _then);

  /// Create a copy of ArchiveState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? year = null,
    Object? month = null,
    Object? gameHistoryByDate = null,
  }) {
    return _then(_$LoadedImpl(
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
      month: null == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as int,
      gameHistoryByDate: null == gameHistoryByDate
          ? _value._gameHistoryByDate
          : gameHistoryByDate // ignore: cast_nullable_to_non_nullable
              as Map<String, UserGameDataEntity>,
    ));
  }
}

/// @nodoc

class _$LoadedImpl implements _Loaded {
  const _$LoadedImpl(
      {required this.year,
      required this.month,
      required final Map<String, UserGameDataEntity> gameHistoryByDate})
      : _gameHistoryByDate = gameHistoryByDate;

  @override
  final int year;
  @override
  final int month;
  final Map<String, UserGameDataEntity> _gameHistoryByDate;
  @override
  Map<String, UserGameDataEntity> get gameHistoryByDate {
    if (_gameHistoryByDate is EqualUnmodifiableMapView)
      return _gameHistoryByDate;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_gameHistoryByDate);
  }

  @override
  String toString() {
    return 'ArchiveState.loaded(year: $year, month: $month, gameHistoryByDate: $gameHistoryByDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoadedImpl &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.month, month) || other.month == month) &&
            const DeepCollectionEquality()
                .equals(other._gameHistoryByDate, _gameHistoryByDate));
  }

  @override
  int get hashCode => Object.hash(runtimeType, year, month,
      const DeepCollectionEquality().hash(_gameHistoryByDate));

  /// Create a copy of ArchiveState
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
    required TResult Function(int year, int month,
            Map<String, UserGameDataEntity> gameHistoryByDate)
        loaded,
    required TResult Function(String message) error,
  }) {
    return loaded(year, month, gameHistoryByDate);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(int year, int month,
            Map<String, UserGameDataEntity> gameHistoryByDate)?
        loaded,
    TResult? Function(String message)? error,
  }) {
    return loaded?.call(year, month, gameHistoryByDate);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(int year, int month,
            Map<String, UserGameDataEntity> gameHistoryByDate)?
        loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(year, month, gameHistoryByDate);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
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
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class _Loaded implements ArchiveState {
  const factory _Loaded(
          {required final int year,
          required final int month,
          required final Map<String, UserGameDataEntity> gameHistoryByDate}) =
      _$LoadedImpl;

  int get year;
  int get month;
  Map<String, UserGameDataEntity> get gameHistoryByDate;

  /// Create a copy of ArchiveState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoadedImplCopyWith<_$LoadedImpl> get copyWith =>
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
    extends _$ArchiveStateCopyWithImpl<$Res, _$ErrorImpl>
    implements _$$ErrorImplCopyWith<$Res> {
  __$$ErrorImplCopyWithImpl(
      _$ErrorImpl _value, $Res Function(_$ErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of ArchiveState
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
    return 'ArchiveState.error(message: $message)';
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

  /// Create a copy of ArchiveState
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
    required TResult Function(int year, int month,
            Map<String, UserGameDataEntity> gameHistoryByDate)
        loaded,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(int year, int month,
            Map<String, UserGameDataEntity> gameHistoryByDate)?
        loaded,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(int year, int month,
            Map<String, UserGameDataEntity> gameHistoryByDate)?
        loaded,
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
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _Error implements ArchiveState {
  const factory _Error(final String message) = _$ErrorImpl;

  String get message;

  /// Create a copy of ArchiveState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
