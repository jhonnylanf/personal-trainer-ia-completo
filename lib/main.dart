import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() => runApp(const PersonalTrainerIaApp());

class PersonalTrainerIaApp extends StatelessWidget {
  const PersonalTrainerIaApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Personal Trainer IA',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(useMaterial3: true).copyWith(
          scaffoldBackgroundColor: const Color(0xFF071117),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF23C7A7),
            brightness: Brightness.dark,
          ),
        ),
        home: const LegacyAppHost(),
      );
}

class LegacyAppHost extends StatefulWidget {
  const LegacyAppHost({super.key});
  @override
  State<LegacyAppHost> createState() => _LegacyAppHostState();
}

class _LegacyAppHostState extends State<LegacyAppHost> {
  static const native = MethodChannel('com.personaltrainer.ia/native');
  late final WebViewController controller;
  int progress = 0;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF071117))
      ..setNavigationDelegate(NavigationDelegate(
        onProgress: (value) => setState(() => progress = value),
        onPageFinished: (_) async {
          await _installCompatibilityBridge();
          await native.invokeMethod<void>('consumeFinishedRest');
        },
        onNavigationRequest: (request) async {
          if (request.url.startsWith('http')) {
            await launchUrl(Uri.parse(request.url), mode: LaunchMode.externalApplication);
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ))
      ..addJavaScriptChannel('AndroidBridge', onMessageReceived: _handleBridge)
      ..loadFlutterAsset('assets/web/personal_ia.html');
    native.setMethodCallHandler((call) async {
      if (call.method == 'restFinished') {
        await controller.runJavaScript('''
          try {
            localStorage.setItem('rest_native_finished','1');
            window.dispatchEvent(new CustomEvent('personalia-rest-finished'));
            if (typeof onNativeRestFinished === 'function') onNativeRestFinished();
          } catch(e) { console.error(e); }
        ''');
      }
    });
  }

  Future<void> _installCompatibilityBridge() async {
    await controller.runJavaScript('''
      (function(){
        window.AndroidRestTimer = window.AndroidRestTimer || {
          scheduleAt: function(endAt){ AndroidBridge.postMessage(JSON.stringify({type:'scheduleRest',endAt:Number(endAt)})); },
          schedule: function(seconds){ AndroidBridge.postMessage(JSON.stringify({type:'scheduleRest',endAt:Date.now()+Number(seconds)*1000})); },
          cancel: function(){ AndroidBridge.postMessage(JSON.stringify({type:'cancelRest'})); }
        };
        window.PersonalIaNative = {
          vibrate: function(ms){ AndroidBridge.postMessage(JSON.stringify({type:'vibrate',ms:Number(ms)||400})); },
          beep: function(){ AndroidBridge.postMessage(JSON.stringify({type:'beep'})); },
          share: function(name,content){ AndroidBridge.postMessage(JSON.stringify({type:'share',name:name,content:content})); },
          openUrl: function(url){ AndroidBridge.postMessage(JSON.stringify({type:'openUrl',url:url})); }
        };
      })();
    ''');
  }

  Future<void> _handleBridge(JavaScriptMessage message) async {
    try {
      final data = jsonDecode(message.message) as Map<String, dynamic>;
      switch (data['type']) {
        case 'scheduleRest':
          await native.invokeMethod('scheduleRest', {'endAt': (data['endAt'] as num).toInt()});
        case 'cancelRest':
          await native.invokeMethod('cancelRest');
        case 'vibrate':
          await native.invokeMethod('vibrate', {'ms': (data['ms'] as num?)?.toInt() ?? 400});
        case 'beep':
          await native.invokeMethod('beep');
        case 'openUrl':
          final uri = Uri.tryParse(data['url'] as String? ?? '');
          if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
        case 'share':
          final directory = await getTemporaryDirectory();
          final file = File('${directory.path}/${data['name'] ?? 'personal_ia_backup.json'}');
          await file.writeAsString(data['content'] as String? ?? '{}');
          await Share.shareXFiles([XFile(file.path)], text: 'Backup Personal Trainer IA');
      }
    } catch (error) {
      debugPrint('Bridge error: $error');
    }
  }

  Future<bool> _back() async {
    if (await controller.canGoBack()) {
      await controller.goBack();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (_, __) async {
          if (await _back() && context.mounted) Navigator.of(context).pop();
        },
        child: Scaffold(
          body: SafeArea(
            child: Stack(children: [
              WebViewWidget(controller: controller),
              if (progress < 100)
                LinearProgressIndicator(value: progress / 100, minHeight: 2),
            ]),
          ),
        ),
      );
}
