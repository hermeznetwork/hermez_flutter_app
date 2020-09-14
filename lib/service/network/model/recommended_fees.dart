class RecommendedFees {
  final double existingAccount;
  final double createAccount;
  final double createAccountInternal;

  RecommendedFees({this.existingAccount, this.createAccount, this.createAccountInternal});

  factory RecommendedFees.fromJson(Map<String, dynamic> json) {
    return RecommendedFees(
        existingAccount: json['existingAccount'],
        createAccount: json['createAccount'],
        createAccountInternal: json['createAccountInternal']
    );
  }

  Map<String, dynamic> toJson() => {
    'existingAccount': existingAccount,
    'createAccount': createAccount,
    'createAccountInternal': createAccountInternal
  };

}
