# flutter_embed_lua

<div>
  <a href=https://pub.dev/packages/flutter_embed_lua target="_blank"><img src=https://img.shields.io/badge/Pub%20Package-blue.svg?logo=flutter height=22px></a>
</div>

🚀 **flutter_embed_lua** is a Flutter plugin that embeds a full **Lua runtime** inside your Flutter application. It allows you to **extend your app functionality at runtime** by running Lua scripts, defining custom functions, and bridging Lua with Dart.

---

## ✨ Features

- 🌀 **Run Lua scripts** directly inside your Flutter app.
- 📡 **Call Lua functions from Dart** and vice versa.
- 🔌 **Register custom Dart functions** and expose them to Lua.
- 📦 **Extend runtime behavior** with user-provided scripts.
- 🧩 Optional **extension layer (`LuaExtension`)** for organizing reusable Lua helpers.

---

## 📦 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_embed_lua: latest
```

Then run:

```bash
flutter pub get
```

---

## 📃 Usage

```dart
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
```

---

## 📚 Classes Overview

**LuaRuntime**

**-run(String code)** → Runs Lua code.

**-registerFunction(String name, Function function)** → Exposes a Dart function to Lua.

---

# 🤝 Contributing

Contributions are welcome!

If you’d like to improve this plugin, feel free to open an issue or a pull request
