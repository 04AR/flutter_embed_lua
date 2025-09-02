import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'lua_bindings.dart';

class Helpers {
  final LuaBindings bindings;

  Helpers(this.bindings);

  /// Extract arguments from Lua stack into a Dart List
  List<dynamic> getArgs(Pointer<lua_State> L) {
    final argc = bindings.lua_gettop(L);
    final args = <dynamic>[];

    for (var i = 1; i <= argc; i++) {
      if (bindings.lua_isstring(L, i) != 0) {
        final strPtr = bindings.lua_tolstring(L, i, nullptr);
        args.add(strPtr.cast<Utf8>().toDartString());
      } else if (bindings.lua_isinteger(L, i) != 0) {
        args.add(bindings.lua_tointegerx(L, i, nullptr));
      } else if (bindings.lua_isnumber(L, i) != 0) {
        args.add(bindings.lua_tonumberx(L, i, nullptr));
      } else {
        args.add(null); // unsupported type for now
      }
    }

    return args;
  }

  /// Push a Dart value onto Lua stack
  void pushValue(Pointer<lua_State> L, dynamic value) {
    if (value is String) {
      final cstr = value.toNativeUtf8();
      bindings.lua_pushstring(L, cstr.cast());
      malloc.free(cstr);
    } else if (value is int) {
      bindings.lua_pushinteger(L, value);
    } else if (value is double) {
      bindings.lua_pushnumber(L, value);
    } else if (value is bool) {
      bindings.lua_pushboolean(L, value ? 1 : 0);
    } else {
      bindings.lua_pushnil(L);
    }
  }
}
