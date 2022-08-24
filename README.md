# channel_multiplexed_scheduler

This project aims at providing a unified abstract interface to exchange data between devices using
different technologies.

Data exchanges do work as follow:
* File exchange is done between a sender and a receiver;
* Multiple (one or several) channels link sender and receiver;
* Sender-side, a scheduler sends file chunks on channels as it sees fit;
* Receiver-side, an aggregator reconstructs file from received file chunks.

## General architecture

<p align="center">
  <img src="assets/img/Theory.drawio.png"/>
</p>

#### Scheduler

**A scheduler sends a file as chunks going through multiple channels.**

It uses the [selective repeat ARQ](https://www.tutorialspoint.com/what-is-selective-repeat-arq-in-computer-networks)
technique by sending file chunks in different channels, and retrying if a chunk isn't acknowledged
by sending channel in a given time.

This package provides a `Scheduler` abstract class that must be implemented with the 
channel-selection policy of your choice.

#### Channels

**A channel is charged with transmitting data from sender to receiver. That's it!**

This package provides a arbitrary-abstract `Channel` interface for other packages to implement, the 
idea being that you can implement a channel with whatever you want: Wi-Fi, Bluetooth... 

Any technology able to carry data can be implemented into a channel!
Yeah, [even sound](https://developers.google.com/android/reference/com/google/android/gms/nearby/messages/audio/AudioBytes)!
(don't try this at home)

#### Receiver

Receiver is plugged to the same channels as the scheduler, and after collecting all file chunks, it 
rebuilds the file.


## Implementation

### Scheduler implementation

TODO (with code sample)

### Channel implementation

TODO explain code sample

As said previously, the `Channel` interface provided by this package is as abstract as possible to
let people implement it the way they want.

It is written in Dart, and thus can be used on a variety of platforms: Android, iOS, Linux, Windows
and macOS.

There are two ways to implement a channel: you must create either [a package or a plugin](https://docs.flutter.dev/development/packages-and-plugins/developing-packages).

#### Package implementation

If you can use Dart or Flutter packages to create your implementation, then *package* is the way to
go. It only requires you to implement `Channel` interface using third-party packages.

<p align="center">
  <img src="assets/img/Channel%20implementation%20(package).drawio.png"/>
</p>

#### Plugin implementation

However, if you need to write channel implementation for each platforms, you'll have to create a 
*Flutter plugin*, which invokes native code through a [method channel](https://docs.flutter.dev/development/platform-integration/platform-channels).

<p align="center">
  <img src="assets/img/Channel%20implementation%20(plugin).drawio.png"/>
</p>

## Getting Started

```shell
# Install dependencies.
flutter pub get

# Run tests.
flutter test
```

### File sending log example

Here is a file sending log using one channel:

```text
# File chunks are sent sequentially.
[Scheduler] Sending chunk n°0.
[Scheduler] Sending chunk n°1.
[Scheduler] Sending chunk n°2.
[Scheduler] Sending chunk n°3.
[Scheduler] Sending chunk n°4.
[Scheduler] Sending chunk n°5.
[Scheduler] Sending chunk n°6.
[Scheduler] Sending chunk n°7.
[Scheduler] Sending chunk n°8.

# Some are acknowledged.
[Scheduler] Chunk n°7 was acknowledged.
[Scheduler] Chunk n°8 was acknowledged.
[Scheduler] Chunk n°5 was acknowledged.

# Some time out.
[Scheduler] Chunk n°0 was not acknowledged in time, resending.
[Scheduler] Chunk n°4 was acknowledged.
[Scheduler] Chunk n°1 was not acknowledged in time, resending.
[Scheduler] Chunk n°2 was not acknowledged in time, resending.
[Scheduler] Chunk n°3 was not acknowledged in time, resending.
[Scheduler] Chunk n°6 was not acknowledged in time, resending.

# Chunks which timed out are sent anew.
[Scheduler] Sending chunk n°6.
[Scheduler] Sending chunk n°3.
[Scheduler] Sending chunk n°2.
[Scheduler] Sending chunk n°1.
[Scheduler] Sending chunk n°0.
[Scheduler] Chunk n°2 was acknowledged.
[Scheduler] Chunk n°0 was acknowledged.
[Scheduler] Chunk n°1 was acknowledged.
[Scheduler] Chunk n°6 was acknowledged.
[Scheduler] Chunk n°3 was acknowledged.

# File sending ends when all chunks have been acknowledged.
[Scheduler] Finished dispatching all chunks to channels.
```