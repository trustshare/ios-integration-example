//
// Created by Simon Holmes on 07/05/2021.
//

import SwiftUI
import WebKit

// A class to handle messages from trustshare to receive data back into the iOS app.
class ContentController: NSObject, WKScriptMessageHandler {
  let cb: (_ args: WKScriptMessage) -> ()
  let handler: String
  var webView: WKWebView?

  init(cb: @escaping (_ message: WKScriptMessage) -> (), webView: WKWebView, handler: String) {
    self.cb = cb
    self.webView = webView
    self.handler = handler
  }

  // This is where the received messages from the webview are handled.
  func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    if (message.name == handler) {
      cb(message)
    }
  }
}

// This is needed to handle the open banking flow as it pops up a new window.
class WVUiDelegate: NSObject, WKNavigationDelegate, WKUIDelegate {
  func webView(
      _ webView: WKWebView,
      createWebViewWith configuration: WKWebViewConfiguration,
      for navigationAction: WKNavigationAction,
      windowFeatures: WKWindowFeatures
  ) -> WKWebView? {
    // If there is a popup add it as a subView, otherwise return normal webview.
    if navigationAction.targetFrame == nil {
      let newView = WKWebView(frame: webView.frame, configuration: configuration)
      newView.customUserAgent = webView.customUserAgent
      newView.navigationDelegate = self
      newView.uiDelegate = self
      webView.addSubview(newView)
      newView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
      newView.configuration.preferences.javaScriptEnabled = true
      newView.load(navigationAction.request)
      return newView
    }
    return webView;
  }

  func webViewDidClose(_ webView: WKWebView) {
    webView.removeFromSuperview();
  }
}

struct TrustshareSDKView: UIViewRepresentable {
  private let cb: (_ args: WKScriptMessage) -> ()
  private let handlerName: String
  private let webView = WKWebView();
  private let uiDelegate = WVUiDelegate();
    private let clientSecret: String;

  init(clientSecret: String, handlerName: String = "trustshareHandler", cb: @escaping (_ args: WKScriptMessage) -> ()) {
    self.cb = cb
    self.handlerName = handlerName
    self.clientSecret = clientSecret
  }

  // Construct a url for the webview to show.
  func makeURL() -> URL {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "checkout.trustshare.io"
    components.path = "/process"
    components.queryItems = [
      URLQueryItem(name: "s", value: clientSecret),
      URLQueryItem(name: "handler", value: handlerName)
    ]
    components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
    let url = components.url!
    return url;
  }

  // Make a webview to show trustshare.
  func makeUIView(context: Context) -> WKWebView {
    let config = WKWebViewConfiguration()
    let customUserAgent: String = "trustshare-sdk/ios/1.0"
    webView.customUserAgent = customUserAgent;
    webView.uiDelegate = uiDelegate;
    webView.configuration.userContentController.add(ContentController(cb: cb, webView: webView, handler: handlerName), name: handlerName)
    webView.configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
    webView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
    webView.configuration.preferences.javaScriptEnabled = true
    let url = makeURL()
    print(url)
    webView.load(URLRequest(url: url))
    return webView;
  }


  func updateUIView(_ uiView: WKWebView, context: Context) {

  }
}
