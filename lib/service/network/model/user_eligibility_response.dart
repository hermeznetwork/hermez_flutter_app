class UserEligibilityResponse {
  final bool isUserEligible;

  UserEligibilityResponse({this.isUserEligible});

  factory UserEligibilityResponse.fromJson(Map<String, dynamic> json) {
    return UserEligibilityResponse(
      isUserEligible: json['isUserEligible'],
    );
  }

  Map<String, dynamic> toJson() => {
        'isUserEligible': isUserEligible,
      };
}
