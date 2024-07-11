import Flutter
import UIKit
import Sybrin_iOS_Identity
import Sybrin_iOS_Biometrics

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    private let CHANNEL = "com.example.flutter_sybrin_demo/channel"

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        let methodChannel = FlutterMethodChannel(name: CHANNEL, binaryMessenger: controller.binaryMessenger)

       methodChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
        switch call.method {
          case "scanDocument":
              guard let args = call.arguments as? [String: Any],
                    let license = args["license"] as? String else {
                  result(FlutterError(code: "INVALID_ARGUMENTS", message: "License and Environment Key required", details: nil))
                  return
              }
              self.scanDocument(license: license, result: result)
              
          case "liveness":
              guard let args = call.arguments as? [String: Any],
                    let license = args["license"] as? String else {
                  result(FlutterError(code: "INVALID_ARGUMENTS", message: "License and Environment Key required", details: nil))
                  return
              }
              self.liveness(license: license, result: result)
              
          default:
              result(FlutterMethodNotImplemented)
          }
}

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func scanDocument(license: String, result: @escaping FlutterResult) {
        let license2 = "LtoViijm8bMShYiNnwYhGIG5ZQSzI8LTYkyVO0BFslXYdq/G4jdsfZTFke+b01vuWNMYeqtP0fXJZqFv4kOxewdUCKlK6dOYkURwYQwTiltuXXRAm3TrJfiK1lROq02YScSaCooOenspQt9SPHncmGvAK4FtgQf7xrq5VZWnWMhcBcASRudMY4pzZsgdyzHBKyxTlRBNXmGap5TD6BPlNu9C7YEK+GeqP07Wemaf8MN0R084VBPMFidP2Zrf2jDbvrpDpv7OoGC5IElqdjUDkAoxDEJKaCkE37jPmBHiwHdAvWIte3z/4WGLuLf18VR7yYzyf8xr+u3oHLOTw6P2Jn7Eygcbbr8i5XbzD2TmykqhUwTjVWu3n+hN/lsCigE4nnUPoWmY2WgAf9wKVqScOUSFd6zET3Quxmb0OErneOZN/Wot5nQEuTIUnkyauDwtTP6zdOtGuhFz5umEZe4BZFfxiigom+Hs+fUwuq2Svzpyf182BsXPmXcAIJepuDjt"
        let sybrinConfig = SybrinIdentityConfiguration(license: license2)
        sybrinConfig.language = .ENGLISH
        // sybrinConfig.environmentKey = environmentKey
        SybrinIdentity.shared.configuration = sybrinConfig
        
        guard let rootViewController = self.window?.rootViewController else {
                result(FlutterError(code: "NO_ROOT_VIEW_CONTROLLER", message: "Root view controller is not available", details: nil))
                return
        }

        SybrinIdentity.shared.scanDocument(on:rootViewController, for: .SouthAfricaPassport, doneLaunching: { _,_  in
            // Do something after launching if needed
        }, success: { model in
            result(model) // You may need to convert model to a suitable format for Flutter
        }, failure: { error in
            result(FlutterError(code: "SCAN_FAILED", message: error, details: nil))
        }, cancel: {
            result(FlutterError(code: "SCAN_CANCELLED", message: "Scan was cancelled", details: nil))
        })
    }

    private func liveness(license: String, result: @escaping FlutterResult) {
        let license2 = "LtoViijm8bMShYiNnwYhGIG5ZQSzI8LTYkyVO0BFslXYdq/G4jdsfZTFke+b01vudpl2vGCX+D2yPTbRagBAvumJ3ktTfiPvcslMSR2CJBOzJyBGl6+Jt23nqTjRcI4fhwzdkuTAS+NerNkYZsMhsQc3mPhwTGfJofYZB4Di4cB0g2b8qRp5aNj6+U9cJdZe35381a+tsrmSfyI5Hd/F7tDwrdcEZTCx+o5w1aAX+l8uj2jQharjiN796Fezw1IvnPJHAz+O2oetp1src8n5qQjpDy5zKKqlmqW2UNNxkiMDtX5lcGWTfTw0N3W4SsK99ygIEN6E9O+mJZcCKHGdel+7b7pZW8yEOyegb+nruJruoGxrg4M5VKamftebkD6dp6Ms/c6WdCF9PJGaEcTCIlrZtNdxqN98hW71YwbcFPL3r+pZLBQcfY//md8BC5mZEAfmojswv8XvT8dcZnJ0RoS8CNErBfxFBOEOCsppuPCT5IfDMjnVrFPwP1loGks3"
        let sybrinConfigb = SybrinBiometricsConfiguration(license: license2)
        // Set any further configuration options here
        sybrinConfigb.language =  .ENGLISH
        // sybrinConfig.environmentKey = environmentKey
        SybrinBiometrics.shared.configuration = sybrinConfigb

        guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
            print("Root view controller is not available")
            return
        }

        SybrinBiometrics.shared.openPassiveLivenessDetection(on: rootViewController, doneLaunching: {_,_ in
            // Do something after launching if needed
        }, success: { model in
            SybrinBiometrics.shared.compareFaces(model.selfieImage!, [model.croppedSelfieImage!]) { (comparisonModel) in
                print("Facial comparison finished. We are \(comparisonModel.averageConfidence * 100)% sure the faces match the target")
            } failure: { (message) in
                print("Facial comparison failed because \(message)")
            }
        }, failure: { _ in
            print("not lekker")
        }, cancel: {
            print("ewww")
        })
    }


   
}
