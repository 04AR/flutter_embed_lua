import 'dart:ffi';
import 'dart:ffi' as ffi;
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'lua_bindings.dart';

typedef LuaCFunction = Int32 Function(Pointer<lua_State>);
typedef LuaCFunctionDart = int Function(Pointer<lua_State>);

// Custom print function to capture Lua print() output
int luaPrint(Pointer<lua_State> L) {
  final bindings = LuaRuntime.lua; // static reference
  final buffer = StringBuffer();

  final n = bindings.lua_gettop(L);

  final namePtr = "tostring".toNativeUtf8().cast<Char>();
  for (var i = 1; i <= n; i++) {
    bindings.lua_getglobal(L, namePtr);
    bindings.lua_pushvalue(L, i);
    bindings.lua_pcallk(L, 1, 1, 0, 0, nullptr);

    final s = bindings.lua_tolstring(L, -1, nullptr);
    if (s.address != 0) {
      buffer.write(s.cast<Utf8>().toDartString());
    } else {
      buffer.write("[nil]");
    }
    bindings.lua_settop(L, -2);

    if (i < n) buffer.write("\t");
  }
  malloc.free(namePtr); // free after use

  LuaRuntime.lastPrintOutput = buffer.toString();
  return 0;
}

class LuaRuntime {
  static late LuaBindings lua;
  static String lastPrintOutput = "";
  late final Pointer<lua_State> L;

  ffi.DynamicLibrary _openDynamicLibrary() {
    if (Platform.isAndroid) {
      return ffi.DynamicLibrary.open('liblua.so');
    } else if (Platform.isWindows) {
      return ffi.DynamicLibrary.open("lua54.dll");
    }

    return ffi.DynamicLibrary.process();
  }

  LuaRuntime() {
    // Load the Lua shared library
    final dylib = _openDynamicLibrary();
    lua = LuaBindings(dylib);

    L = lua.luaL_newstate();
    lua.luaL_openlibs(L);

    // register custom print() as lua print() outsput to stdout which flutter doesn't capture
    final printFunc = Pointer.fromFunction<Int32 Function(Pointer<lua_State>)>(
      luaPrint,
      0,
    );

    registerFunction("print", printFunc);
  }

  void registerFunction(
    String name,
    Pointer<NativeFunction<Int32 Function(Pointer<lua_State>)>> fn,
  ) {
    // cast the function pointer to lua_CFunction
    lua.lua_pushcclosure(L, fn as lua_CFunction, 0);
    lua.lua_setglobal(L, name.toNativeUtf8().cast());
  }

  String run(String code) {
    lastPrintOutput = "";

    final codePtr = code.toNativeUtf8();

    // luaL_loadstring compiles the Lua code
    final loadStatus = lua.luaL_loadstring(L, codePtr.cast());
    malloc.free(codePtr);

    if (loadStatus != 0) {
      final err = lua.lua_tolstring(L, -1, nullptr).cast<Utf8>().toDartString();
      lua.lua_settop(L, -2); // lua_pop(L,1)
      return "Error: $err";
    }

    // Execute
    final callStatus = lua.lua_pcallk(L, 0, LUA_MULTRET, 0, 0, nullptr);
    if (callStatus != 0) {
      final err = lua.lua_tolstring(L, -1, nullptr).cast<Utf8>().toDartString();
      lua.lua_settop(L, -2); // pop
      return "Error: $err";
    }

    if (lastPrintOutput.isNotEmpty) {
      return lastPrintOutput; // captured print()
    }

    // Get top of stack
    if (lua.lua_gettop(L) > 0) {
      final resPtr = lua.lua_tolstring(L, -1, nullptr);
      if (resPtr.address != 0) {
        final result = resPtr.cast<Utf8>().toDartString();
        lua.lua_settop(L, -2); // pop
        return result;
      }
    }

    return "";
  }

  void dispose() {
    lua.lua_close(L);
  }
}
