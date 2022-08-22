# channel_multiplexed_scheduler

A new Flutter plugin project.

## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter development, view the
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

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