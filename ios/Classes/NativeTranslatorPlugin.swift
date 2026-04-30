import Flutter
import UIKit
import SwiftUI

#if canImport(Translation)
  import Translation
#endif

public class NativeTranslatorPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "native_translator", binaryMessenger: registrar.messenger())
    let instance = NativeTranslatorPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "translateText":
      translateText(call: call, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func topViewController() -> UIViewController? {
    var window: UIWindow? = nil
    if #available(iOS 13.0, *) {
      let windowScene = UIApplication.shared.connectedScenes
        .filter { $0.activationState == .foregroundActive }
        .first as? UIWindowScene
      window = windowScene?.windows.first { $0.isKeyWindow }
    }
    
    if window == nil {
      window = UIApplication.shared.windows.first { $0.isKeyWindow }
    }
    
    if window == nil {
      window = UIApplication.shared.delegate?.window as? UIWindow
    }
    
    var topController = window?.rootViewController
    while let presentedViewController = topController?.presentedViewController {
      topController = presentedViewController
    }
    return topController
  }

  private func translateText(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
      let text = args["text"] as? String
    else {
      result(
        FlutterError(
          code: "INVALID_ARGUMENTS",
          message: "Text argument is required",
          details: nil))
      return
    }

    guard let controller = topViewController() else {
      result(
        FlutterError(
          code: "UNAVAILABLE",
          message: "Could not find root view controller",
          details: nil))
      return
    }

    // Parse background color from Flutter
    var bgColor: UIColor = .white
    if let red = args["backgroundColorRed"] as? Int,
      let green = args["backgroundColorGreen"] as? Int,
      let blue = args["backgroundColorBlue"] as? Int,
      let alpha = args["backgroundColorAlpha"] as? Int
    {
      bgColor = UIColor(
        red: CGFloat(red) / 255.0,
        green: CGFloat(green) / 255.0,
        blue: CGFloat(blue) / 255.0,
        alpha: CGFloat(alpha) / 255.0
      )
    } else {
      // Default to system background
      if #available(iOS 13.0, *) {
        bgColor = .systemBackground
      }
    }

    #if canImport(Translation)
      if #available(iOS 17.4, *) {
        // Use translationPresentation directly via invisible SwiftUI view
        Task { @MainActor in
          let translationView = TranslationHostView(
            text: text,
            backgroundColor: bgColor
          )
          let hostingController = UIHostingController(rootView: translationView)

          // Make background transparent for invisible view
          hostingController.view.backgroundColor = .clear
          hostingController.modalPresentationStyle = .overFullScreen
          hostingController.modalTransitionStyle = .crossDissolve

          controller.present(hostingController, animated: true)
          result(nil)
        }
      } else {
        // Fallback for iOS < 17.4 - use activity controller
        Task { @MainActor in
          let activityVC = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
          )

          // For iPad support
          if let popover = activityVC.popoverPresentationController {
            popover.sourceView = controller.view
            popover.sourceRect = CGRect(
              x: controller.view.bounds.midX,
              y: controller.view.bounds.midY,
              width: 0,
              height: 0
            )
            popover.permittedArrowDirections = []
          }

          controller.present(activityVC, animated: true)
          result(nil)
        }
      }
    #else
      // Fallback when Translation framework is not available
      Task { @MainActor in
        let activityVC = UIActivityViewController(
          activityItems: [text],
          applicationActivities: nil
        )

        // For iPad support
        if let popover = activityVC.popoverPresentationController {
          popover.sourceView = controller.view
          popover.sourceRect = CGRect(
            x: controller.view.bounds.midX,
            y: controller.view.bounds.midY,
            width: 0,
            height: 0
          )
          popover.permittedArrowDirections = []
        }

        controller.present(activityVC, animated: true)
        result(nil)
      }
    #endif
  }
}

// MARK: - Translation SwiftUI View
#if canImport(Translation)
  @available(iOS 17.4, *)
  struct TranslationHostView: View {
    let text: String
    let backgroundColor: UIColor
    @State private var showTranslation = true
    @Environment(\.dismiss) var dismiss

    var body: some View {
      // Invisible view - only used to trigger translationPresentation
      Color(backgroundColor)
        .opacity(0.01)  // Nearly transparent to maintain invisible behavior
        .translationPresentation(isPresented: $showTranslation, text: text)
        .onChange(of: showTranslation) { _, newValue in
          if !newValue {
            // User dismissed translation, close the hosting controller
            dismiss()
          }
        }
    }
  }
#endif
