#include "include/flutter_embed_lua/flutter_embed_lua_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "flutter_embed_lua_plugin.h"

void FlutterEmbedLuaPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  flutter_embed_lua::FlutterEmbedLuaPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
