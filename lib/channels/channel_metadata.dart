class ChannelMetadata {
  final String address;
  final String identifier;
  final String password;

  ChannelMetadata(this.address, this.identifier, this.password);

  @override
  String toString() {
    return "$address;$identifier;$password";
  }
}