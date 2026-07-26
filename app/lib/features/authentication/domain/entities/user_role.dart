/// Mirrors the Postgres `user_role` enum. `admin` accounts are provisioned
/// directly in the database, never self-registered — [selectableForSignUp]
/// is what the registration role-picker should offer.
enum UserRole {
  farmer,
  buyer,
  expert,
  admin;

  String get apiValue => name;

  static UserRole fromApiValue(String value) => UserRole.values.firstWhere(
        (role) => role.apiValue == value,
        orElse: () => UserRole.buyer,
      );

  static const List<UserRole> selectableForSignUp = [UserRole.farmer, UserRole.buyer, UserRole.expert];

  String get label => switch (this) {
        UserRole.farmer => 'Farmer',
        UserRole.buyer => 'Buyer',
        UserRole.expert => 'Agricultural Expert',
        UserRole.admin => 'Administrator',
      };
}
