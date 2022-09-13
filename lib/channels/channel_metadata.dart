class ChannelMetadata {
  final String channelIdentifier;
  final String address;
  final String apIdentifier;
  final String password;

  ChannelMetadata(this.channelIdentifier, this.address, this.apIdentifier, this.password);

  @override
  String toString() {
    return "$channelIdentifier;$address;$apIdentifier;$password";
  }

  @override
  bool operator ==(Object other) {
    return other is ChannelMetadata && channelIdentifier == other.channelIdentifier && address == other.address && apIdentifier == other.apIdentifier && password == other.password;
  }

  @override
  int get hashCode => Object.hash(channelIdentifier, address, apIdentifier, password);
}