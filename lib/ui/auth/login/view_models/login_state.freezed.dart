// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'login_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LoginState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LoginState()';
}


}

/// @nodoc
class $LoginStateCopyWith<$Res>  {
$LoginStateCopyWith(LoginState _, $Res Function(LoginState) __);
}


/// Adds pattern-matching-related methods to [LoginState].
extension LoginStatePatterns on LoginState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( LoginLoading value)?  loading,TResult Function( LoginEnterEmail value)?  enterEmail,TResult Function( LoginEnterEmailAndName value)?  enterEmailAndName,TResult Function( LoginSubmitting value)?  submitting,TResult Function( LoginEnterOtp value)?  enterOtp,TResult Function( LoginError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case LoginLoading() when loading != null:
return loading(_that);case LoginEnterEmail() when enterEmail != null:
return enterEmail(_that);case LoginEnterEmailAndName() when enterEmailAndName != null:
return enterEmailAndName(_that);case LoginSubmitting() when submitting != null:
return submitting(_that);case LoginEnterOtp() when enterOtp != null:
return enterOtp(_that);case LoginError() when error != null:
return error(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( LoginLoading value)  loading,required TResult Function( LoginEnterEmail value)  enterEmail,required TResult Function( LoginEnterEmailAndName value)  enterEmailAndName,required TResult Function( LoginSubmitting value)  submitting,required TResult Function( LoginEnterOtp value)  enterOtp,required TResult Function( LoginError value)  error,}){
final _that = this;
switch (_that) {
case LoginLoading():
return loading(_that);case LoginEnterEmail():
return enterEmail(_that);case LoginEnterEmailAndName():
return enterEmailAndName(_that);case LoginSubmitting():
return submitting(_that);case LoginEnterOtp():
return enterOtp(_that);case LoginError():
return error(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( LoginLoading value)?  loading,TResult? Function( LoginEnterEmail value)?  enterEmail,TResult? Function( LoginEnterEmailAndName value)?  enterEmailAndName,TResult? Function( LoginSubmitting value)?  submitting,TResult? Function( LoginEnterOtp value)?  enterOtp,TResult? Function( LoginError value)?  error,}){
final _that = this;
switch (_that) {
case LoginLoading() when loading != null:
return loading(_that);case LoginEnterEmail() when enterEmail != null:
return enterEmail(_that);case LoginEnterEmailAndName() when enterEmailAndName != null:
return enterEmailAndName(_that);case LoginSubmitting() when submitting != null:
return submitting(_that);case LoginEnterOtp() when enterOtp != null:
return enterOtp(_that);case LoginError() when error != null:
return error(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loading,TResult Function( String? email)?  enterEmail,TResult Function( String? email)?  enterEmailAndName,TResult Function( bool requireName,  String? email)?  submitting,TResult Function( String email)?  enterOtp,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case LoginLoading() when loading != null:
return loading();case LoginEnterEmail() when enterEmail != null:
return enterEmail(_that.email);case LoginEnterEmailAndName() when enterEmailAndName != null:
return enterEmailAndName(_that.email);case LoginSubmitting() when submitting != null:
return submitting(_that.requireName,_that.email);case LoginEnterOtp() when enterOtp != null:
return enterOtp(_that.email);case LoginError() when error != null:
return error(_that.message);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loading,required TResult Function( String? email)  enterEmail,required TResult Function( String? email)  enterEmailAndName,required TResult Function( bool requireName,  String? email)  submitting,required TResult Function( String email)  enterOtp,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case LoginLoading():
return loading();case LoginEnterEmail():
return enterEmail(_that.email);case LoginEnterEmailAndName():
return enterEmailAndName(_that.email);case LoginSubmitting():
return submitting(_that.requireName,_that.email);case LoginEnterOtp():
return enterOtp(_that.email);case LoginError():
return error(_that.message);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loading,TResult? Function( String? email)?  enterEmail,TResult? Function( String? email)?  enterEmailAndName,TResult? Function( bool requireName,  String? email)?  submitting,TResult? Function( String email)?  enterOtp,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case LoginLoading() when loading != null:
return loading();case LoginEnterEmail() when enterEmail != null:
return enterEmail(_that.email);case LoginEnterEmailAndName() when enterEmailAndName != null:
return enterEmailAndName(_that.email);case LoginSubmitting() when submitting != null:
return submitting(_that.requireName,_that.email);case LoginEnterOtp() when enterOtp != null:
return enterOtp(_that.email);case LoginError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class LoginLoading implements LoginState {
  const LoginLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LoginState.loading()';
}


}




/// @nodoc


class LoginEnterEmail implements LoginState {
  const LoginEnterEmail({this.email});
  

 final  String? email;

/// Create a copy of LoginState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoginEnterEmailCopyWith<LoginEnterEmail> get copyWith => _$LoginEnterEmailCopyWithImpl<LoginEnterEmail>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginEnterEmail&&(identical(other.email, email) || other.email == email));
}


@override
int get hashCode => Object.hash(runtimeType,email);

@override
String toString() {
  return 'LoginState.enterEmail(email: $email)';
}


}

/// @nodoc
abstract mixin class $LoginEnterEmailCopyWith<$Res> implements $LoginStateCopyWith<$Res> {
  factory $LoginEnterEmailCopyWith(LoginEnterEmail value, $Res Function(LoginEnterEmail) _then) = _$LoginEnterEmailCopyWithImpl;
@useResult
$Res call({
 String? email
});




}
/// @nodoc
class _$LoginEnterEmailCopyWithImpl<$Res>
    implements $LoginEnterEmailCopyWith<$Res> {
  _$LoginEnterEmailCopyWithImpl(this._self, this._then);

  final LoginEnterEmail _self;
  final $Res Function(LoginEnterEmail) _then;

/// Create a copy of LoginState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? email = freezed,}) {
  return _then(LoginEnterEmail(
email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class LoginEnterEmailAndName implements LoginState {
  const LoginEnterEmailAndName({this.email});
  

 final  String? email;

/// Create a copy of LoginState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoginEnterEmailAndNameCopyWith<LoginEnterEmailAndName> get copyWith => _$LoginEnterEmailAndNameCopyWithImpl<LoginEnterEmailAndName>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginEnterEmailAndName&&(identical(other.email, email) || other.email == email));
}


@override
int get hashCode => Object.hash(runtimeType,email);

@override
String toString() {
  return 'LoginState.enterEmailAndName(email: $email)';
}


}

/// @nodoc
abstract mixin class $LoginEnterEmailAndNameCopyWith<$Res> implements $LoginStateCopyWith<$Res> {
  factory $LoginEnterEmailAndNameCopyWith(LoginEnterEmailAndName value, $Res Function(LoginEnterEmailAndName) _then) = _$LoginEnterEmailAndNameCopyWithImpl;
@useResult
$Res call({
 String? email
});




}
/// @nodoc
class _$LoginEnterEmailAndNameCopyWithImpl<$Res>
    implements $LoginEnterEmailAndNameCopyWith<$Res> {
  _$LoginEnterEmailAndNameCopyWithImpl(this._self, this._then);

  final LoginEnterEmailAndName _self;
  final $Res Function(LoginEnterEmailAndName) _then;

/// Create a copy of LoginState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? email = freezed,}) {
  return _then(LoginEnterEmailAndName(
email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class LoginSubmitting implements LoginState {
  const LoginSubmitting({required this.requireName, this.email});
  

 final  bool requireName;
 final  String? email;

/// Create a copy of LoginState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoginSubmittingCopyWith<LoginSubmitting> get copyWith => _$LoginSubmittingCopyWithImpl<LoginSubmitting>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginSubmitting&&(identical(other.requireName, requireName) || other.requireName == requireName)&&(identical(other.email, email) || other.email == email));
}


@override
int get hashCode => Object.hash(runtimeType,requireName,email);

@override
String toString() {
  return 'LoginState.submitting(requireName: $requireName, email: $email)';
}


}

/// @nodoc
abstract mixin class $LoginSubmittingCopyWith<$Res> implements $LoginStateCopyWith<$Res> {
  factory $LoginSubmittingCopyWith(LoginSubmitting value, $Res Function(LoginSubmitting) _then) = _$LoginSubmittingCopyWithImpl;
@useResult
$Res call({
 bool requireName, String? email
});




}
/// @nodoc
class _$LoginSubmittingCopyWithImpl<$Res>
    implements $LoginSubmittingCopyWith<$Res> {
  _$LoginSubmittingCopyWithImpl(this._self, this._then);

  final LoginSubmitting _self;
  final $Res Function(LoginSubmitting) _then;

/// Create a copy of LoginState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? requireName = null,Object? email = freezed,}) {
  return _then(LoginSubmitting(
requireName: null == requireName ? _self.requireName : requireName // ignore: cast_nullable_to_non_nullable
as bool,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class LoginEnterOtp implements LoginState {
  const LoginEnterOtp({required this.email});
  

 final  String email;

/// Create a copy of LoginState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoginEnterOtpCopyWith<LoginEnterOtp> get copyWith => _$LoginEnterOtpCopyWithImpl<LoginEnterOtp>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginEnterOtp&&(identical(other.email, email) || other.email == email));
}


@override
int get hashCode => Object.hash(runtimeType,email);

@override
String toString() {
  return 'LoginState.enterOtp(email: $email)';
}


}

/// @nodoc
abstract mixin class $LoginEnterOtpCopyWith<$Res> implements $LoginStateCopyWith<$Res> {
  factory $LoginEnterOtpCopyWith(LoginEnterOtp value, $Res Function(LoginEnterOtp) _then) = _$LoginEnterOtpCopyWithImpl;
@useResult
$Res call({
 String email
});




}
/// @nodoc
class _$LoginEnterOtpCopyWithImpl<$Res>
    implements $LoginEnterOtpCopyWith<$Res> {
  _$LoginEnterOtpCopyWithImpl(this._self, this._then);

  final LoginEnterOtp _self;
  final $Res Function(LoginEnterOtp) _then;

/// Create a copy of LoginState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? email = null,}) {
  return _then(LoginEnterOtp(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class LoginError implements LoginState {
  const LoginError({required this.message});
  

 final  String message;

/// Create a copy of LoginState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoginErrorCopyWith<LoginError> get copyWith => _$LoginErrorCopyWithImpl<LoginError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'LoginState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $LoginErrorCopyWith<$Res> implements $LoginStateCopyWith<$Res> {
  factory $LoginErrorCopyWith(LoginError value, $Res Function(LoginError) _then) = _$LoginErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$LoginErrorCopyWithImpl<$Res>
    implements $LoginErrorCopyWith<$Res> {
  _$LoginErrorCopyWithImpl(this._self, this._then);

  final LoginError _self;
  final $Res Function(LoginError) _then;

/// Create a copy of LoginState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(LoginError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
