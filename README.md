# Banked Flutter SDK Example - iOS Architecture Issue Example

This project is a fork of the original one created by Banked team as an example of how we can integrate Banked Android/iOS SDKs into a Flutter based app, the original example [can be found here](https://github.com/banked/banked_flutter_sdk_example).

The approach taked by the original project doesn't really follow the guideline documented by the Flutter framework for [how to create plugins](https://docs.flutter.dev/development/packages-and-plugins/developing-packages#plugin).

The main difference between this project and the original one is that it tries to add a basic [Banked Flutter plugin](packages/banked) which contains Android and iOS platform implementations so that it can be added to the project via the [`pubspec.yaml`](pubspec.yaml) file, however, when we use the new basic plugin, we start to face an issue building the iOS app because of the following errors:
```
ld: building for iOS Simulator, but linking in dylib built for iOS, file
'/Users/{user}/Workspace/banked_flutter_sdk_example/ios/Pods/Banked/Banked.framework/Banked'
for architecture arm64
clang: error: linker command failed with exit code 1 (use -v to see invocation)
```
or:
```
<unknown>:0: error: unable to load standard library for target 'arm64-apple-ios11.0'
/Users/{user}/Workspace/banked_flutter_sdk_example/packages/banked/ios/Classes/SwiftBankedPlugin.swift:3:8: error: module compiled with Swift 5.5.1 cannot be imported by the Swift 5.5.2 compiler: /Users/{user}/Workspace/banked_flutter_sdk_example/ios/Pods/Banked/Banked.framework/Modules/Banked.swiftmodule/arm64.swiftmodule
```
The versions of Xcode/Swift used are:
```
$ xcodebuild -version
Xcode 13.2.1
Build version 13C100

$ swift -version
swift-driver version: 1.26.21 Apple Swift version 5.5.2 (swiftlang-1300.0.47.5 clang-1300.0.29.30)
Target: x86_64-apple-macosx11.0
```

# Banked Flutter SDK Example

Here is an example project on how to integrate the existing native Android and iOS SDKs into a Flutter app.

## Android Integration

1. Add the latest gradle dependency into the Android app module build file

```
implementation "com.banked:checkout:2.0.1-beta12"
```

2. Add an intent filter into the application manin activity so that the SDK can receive events from the banking providers
```
</intent-filter>
    <intent-filter>
    <action android:name="android.intent.action.VIEW" />

    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />

    <data
        android:host="<host>"
        android:scheme="<scheme>" />
    </intent-filter>
```

3. Create a ```MethodChannel``` in the dart file to send and receive messages to and from the Android activity.
```
 static const methodChannel = const MethodChannel('com.example.banked_flutter_sdk_example/banked_sdk');

  _MyHomePageState() {
    methodChannel.setMethodCallHandler((call) => _processSdkCallback(call));
  }
```

4. Create a function to process incoming messages from the activity.
```
Future<dynamic> _processSdkCallback(MethodCall call) async {
    print("Call - " + call.method);

    String newStatus = "Unknown";

    if (call.method == "BankedSdkPaymentSuccess") {
      newStatus = "Payment Success";
    } else if (call.method == "BankedSdkPaymentSuccess") {
      newStatus = "Payment Failed";
    } else if (call.method == "BankedSdkPaymentAborted") {
      newStatus = "Payment Aborted";
    }

    setState(() {
      _sdkStatus = newStatus;
    });
  }
```

5. Start the SDK in the dart file as follows.
```
Future<void> _startBankedSdk() async {
    String sdkStatus;
    try {
      final Map params = <String, dynamic>{
        'payment id': "Add your payment ID here",
        'continue url': "Add your continue URL here",
      };

      await methodChannel.invokeMethod('startSdk', params);
      sdkStatus = "Waiting for SDK result";
    } on PlatformException catch (e) {
      sdkStatus = "Failed to get start Banked SDK: '${e.message}'.";
    }
    setState(() {
      _sdkStatus = sdkStatus;
    });
  }
```

6. Add the following code to your activity to setup the Banked SDK to initialise, send events to the common dart code and receive events from the dart code and SDK.
```
private const val CHANNEL = "com.example.banked_flutter_sdk_example/banked_sdk"
private const val BANKED_API_KEY = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"

class MainActivity : FlutterFragmentActivity(), OnPaymentSessionListener {

    private var methodChannel: MethodChannel? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Banked.setOnPaymentSessionListener(this)
        Banked.setApiKey(BANKED_API_KEY)
    }

    override fun onDestroy() {
        Banked.setOnPaymentSessionListener(null)
        super.onDestroy()
    }

    override fun onStart() {
        super.onStart()
        Banked.onStart(this)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        if (methodChannel == null) {
            methodChannel = MethodChannel(
                flutterEngine.dartExecutor.binaryMessenger,
                CHANNEL
            )

            methodChannel?.setMethodCallHandler { call, result ->
                if (call.method == "startSdk") {
                    val arguments = call.arguments as Map<String, Any>
                    val paymentId = arguments["payment id"]?.toString() ?: "XXXXXXXX"
                    val continueUrl = arguments["continue url"]?.toString() ?: "XXXXXXXX"

                    Banked.startPayment(
                        this,
                        paymentId,
                        continueUrl
                    )
                    result.success("SDK Started")
                } else {
                    result.notImplemented()
                }
            }
        }
    }

    override fun onPaymentFailed(paymentResult: PaymentResult) {
        methodChannel?.invokeMethod("BankedSdkPaymentFailed", toParameterMap(paymentResult))
    }

    override fun onPaymentSuccess(paymentResult: PaymentResult) {
        methodChannel?.invokeMethod("BankedSdkPaymentSuccess", toParameterMap(paymentResult))
    }
    
    override fun onPaymentAborted() {
        methodChannel?.invokeMethod("BankedSdkPaymentAborted", mapOf<String, String>())
    }

    private fun toParameterMap(paymentResult: PaymentResult): Map<String, String> {
        return mapOf(
            "paymentId" to paymentResult.paymentId,
            "amountFormatted" to paymentResult.amountFormatted,
            "providerName" to paymentResult.providerName,
            "payeeName" to paymentResult.payeeName
        )
    }
}
```

More information on how to integrate Android SDK in an application can be found at https://github.com/banked/banked-android-sdk-examples

## iOS Integration

1. Use [Cocoapods](https://cocoapods.org/) to install the Banked Checkout SDK

To integrate Banked Checkout SDK into your Xcode project using CocoaPods, specify it in your Podfile:

```swift
pod ‘Banked’
```

2.  Open the file AppDelegate.swift located under Runner > Runner in the Project navigator.

Add the following code to setup the Banked SDK to initialise, send events to the common dart code and receive events from the dart code and SDK.

```swift
import UIKit
import Flutter
import Banked

private let CHANNEL = "com.example.banked_flutter_sdk_example/banked_sdk"
private let BANKED_API_KEY = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let bankedSDKChannel = FlutterMethodChannel(name: CHANNEL,
                                              binaryMessenger: controller.binaryMessenger)
    bankedSDKChannel.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
      // Note: this method is invoked on the UI thread.
        guard call.method == "startSdk" else {
            result(FlutterMethodNotImplemented)
            return
        }
        
        guard let arguments = call.arguments as? [String : Any] else {
            result(FlutterError(code: "NO_ARGUMENTS", message: "Can't extract flutter arguments", details: nil))
            return
        }
        
        guard let paymentId = arguments["payment id"] as? String else {
            result(FlutterError(code: "NO_PAYMENT_ID", message: "PaymentId can't be nil", details: nil))
            return
        }
        guard let continueUrl = arguments["continue url"] as? String else {
            result(FlutterError(code: "NO_CONTINUE_URL", message: "Continue url can't be nil", details: nil))
            return
        }

        self?.presentBankedCheckout(result: result, paymetId: paymentId, continueURL: continueUrl)
    })

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    private func presentBankedCheckout(result: FlutterResult, paymetId: String, continueURL: String) {
        
        guard let viewController = self.window.rootViewController else {
            result(FlutterError(code: "NO_VIEWCONTROLLER", message: "ViewController can't be nil", details: nil))
            return
        }
                
        BankedCheckout.shared.setUp(BANKED_API_KEY)
        
        BankedCheckout.shared.presentCheckout(viewController, paymentId: paymetId, action: .pay, continueURL: continueURL) { (response) in
            switch response {
            case .success:
                // Handle Success
                print("success")
            case .failure(let error):
                // Handle Error
                print("error \(error)")
            }
        }
    }
}
```

