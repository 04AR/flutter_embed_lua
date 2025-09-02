import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';

import 'package:flutter_embed_lua/lua_bindings.dart';
import 'package:flutter_embed_lua/lua_runtime.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  // ensure Initialized
  WidgetsFlutterBinding.ensureInitialized();
  runApp(LuaReplApp());
}

class LuaReplApp extends StatefulWidget {
  @override
  State<LuaReplApp> createState() => _LuaReplAppState();
}

class _LuaReplAppState extends State<LuaReplApp> {
  final LuaRuntime runtime = LuaRuntime();
  final TextEditingController controller = TextEditingController();
  final List<String> output = [];

  final showToastPtr = Pointer.fromFunction<Int32 Function(Pointer<lua_State>)>(
    _showToast,
    0,
  );

  static int _showToast(Pointer<lua_State> L) {
    final bindings = LuaRuntime.lua;

    final msgPtr = bindings.lua_tolstring(L, 1, nullptr);
    final msg = msgPtr.cast<Utf8>().toDartString();

    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 1,
      backgroundColor: const Color.fromARGB(255, 204, 204, 204),
      textColor: const Color.fromARGB(255, 0, 0, 0),
      fontSize: 16.0,
    );
    return 0; // number of return values
  }

  void runCode() {
    final code = controller.text;
    final result = runtime.run(code);
    setState(() {
      output.add("> $code\n$result");
    });
    controller.clear();
  }

  @override
  void dispose() {
    runtime.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    runtime.registerFunction("showToast", showToastPtr);

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Lua REPL")),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: output.length,
                itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text(
                    output[i],
                    style: TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    onSubmitted: (_) => runCode(),
                    decoration: InputDecoration(hintText: "Enter Lua code"),
                  ),
                ),
                IconButton(icon: Icon(Icons.send), onPressed: runCode),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
