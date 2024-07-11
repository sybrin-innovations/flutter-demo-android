import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const platform = MethodChannel('com.example.flutter_sybrin_demo/channel');
  String _scanResult = 'Unknown';

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isDenied) {
      final result = await Permission.camera.request();
      if (result.isGranted) {
        print("Camera permission granted");
      } else {
        print("Camera permission denied");
      }
    } else if (status.isGranted) {
      print("Camera permission already granted");
    }
  }

  Future<void> _startScan() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      String result;
      try {
        final String scanResult = await platform.invokeMethod('scanDocument', {
          'license': 'YOUR_IDENTITY_LICENSE'
        });
        result = 'Scan result: $scanResult';
      } on PlatformException catch (e) {
        result = "Failed to scan document: '${e.message}'.";
      }

      setState(() {
        _scanResult = result;
      });
    } else {
      final result = await Permission.camera.request();
      if (result.isGranted) {
        _startScan();
      } else {
        setState(() {
          _scanResult = 'Camera permission denied';
        });
      }
    }
  }

  Future<void> _startLiveness() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      String result;
      try {
        final String livenessResult = await platform.invokeMethod('liveness', {
          'license': 'YOUR_BIOMETRICS_LICENSE'
        });
        result = 'Liveness result: $livenessResult';
      } on PlatformException catch (e) {
        result = "Failed liveness: '${e.message}'.";
      }

      setState(() {
        _scanResult = result;
      });
    } else {
      final result = await Permission.camera.request();
      if (result.isGranted) {
        _startLiveness();
      } else {
        setState(() {
          _scanResult = 'Camera permission denied';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Native Code Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('$_scanResult\n'),
            ElevatedButton(
              onPressed: _startScan,
              child: Text('Start Scan'),
            ),
            ElevatedButton(
              onPressed: _startLiveness,
              child: Text('Start Liveness'),
            ),
          ],
        ),
      ),
    );
  }
}
