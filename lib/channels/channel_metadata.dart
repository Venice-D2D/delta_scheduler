// TODO add channel identifier
class ChannelMetadata {
  final String address;
  final String apIdentifier;
  final String password;

  ChannelMetadata(this.address, this.apIdentifier, this.password);

  @override
  String toString() {
    return "$address;$apIdentifier;$password";
  }

  @override
  bool operator ==(Object other) {
    return other is ChannelMetadata && address == other.address && apIdentifier == other.apIdentifier && password == other.password;
  }

  @override
  int get hashCode => Object.hash(address, apIdentifier, password);
}