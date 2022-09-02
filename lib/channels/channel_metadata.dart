class ChannelMetadata {
  final String address;
  final String identifier;
  final String password;

  ChannelMetadata(this.address, this.identifier, this.password);

  @override
  String toString() {
    return "$address;$identifier;$password";
  }

  @override
  bool operator ==(Object other) {
    return other is ChannelMetadata && address == other.address && identifier == other.identifier && password == other.password;
  }

  @override
  int get hashCode => int.parse("${address.hashCode}${identifier.hashCode}${password.hashCode}");
}