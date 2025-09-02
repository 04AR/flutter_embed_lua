#ifndef FLUTTER_PLUGIN_FLUTTER_EMBED_LUA_PLUGIN_H_
#define FLUTTER_PLUGIN_FLUTTER_EMBED_LUA_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace flutter_embed_lua {

class FlutterEmbedLuaPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  FlutterEmbedLuaPlugin();

  virtual ~FlutterEmbedLuaPlugin();

  // Disallow copy and assign.
  FlutterEmbedLuaPlugin(const FlutterEmbedLuaPlugin&) = delete;
  FlutterEmbedLuaPlugin& operator=(const FlutterEmbedLuaPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace flutter_embed_lua

#endif  // FLUTTER_PLUGIN_FLUTTER_EMBED_LUA_PLUGIN_H_
