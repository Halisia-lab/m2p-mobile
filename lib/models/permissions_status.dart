enum PermissionStatus {
  /// Permission to access the location services is denied by the user.
  denied,

  /// Permission to access the location services is granted by the user.
  granted,

  /// The user granted restricted access to the location services (only on iOS).
  restricted,

  /// Permission is in an unknown state
  unknown
}