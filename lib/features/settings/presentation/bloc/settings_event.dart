part of 'settings_bloc.dart';

@freezed
class SettingsEvent with _$SettingsEvent {
  const factory SettingsEvent.logoutRequested() = LogoutRequested;

  const factory SettingsEvent.deleteAccountRequested({
    required String firestoreDatabaseId,
  }) = DeleteAccountRequested;
}


