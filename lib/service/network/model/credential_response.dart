class CredentialResponse {
  final int userId;
  final String legacyPartnerId;
  final String name;
  final String clientId;
  final String secret;
  final String role;
  final String lastUpdate;

  CredentialResponse(
      {this.userId,
      this.legacyPartnerId,
      this.name,
      this.clientId,
      this.secret,
      this.role,
      this.lastUpdate});

  factory CredentialResponse.fromJson(Map<String, dynamic> json) {
    return CredentialResponse(
        userId: json['user_id'],
        legacyPartnerId: json['legacy_partner_id'],
        name: json['name'],
        clientId: json['clientID'],
        secret: json['secret'],
        role: json['Role'],
        lastUpdate: json['LastUpdate']);
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'legacy_partner_id': legacyPartnerId,
        'name': name,
        'clientID': clientId,
        'secret': secret,
        'Role': role,
        'LastUpdate': lastUpdate,
      };
}
