//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <channel_multiplexed_scheduler/channel_multiplexed_scheduler_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) channel_multiplexed_scheduler_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "ChannelMultiplexedSchedulerPlugin");
  channel_multiplexed_scheduler_plugin_register_with_registrar(channel_multiplexed_scheduler_registrar);
}
