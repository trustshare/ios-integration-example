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
  private let action: Action
  private let subdomain: String
  private let handlerName: String
  private let webView = WKWebView();
  private let uiDelegate = WVUiDelegate();

  init(action: Action, subdomain: String, handlerName: String = "trustshareHandler", cb: @escaping (_ args: WKScriptMessage) -> ()) {
    self.cb = cb
    self.subdomain = subdomain
    self.handlerName = handlerName
    self.action = action
  }

  // Construct a url for the webview to show.
  func makeURL() -> URL {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "\(subdomain).lvh.me"
    components.path = "/mobile-sdk"
    components.queryItems = [
      URLQueryItem(name: "handlerName", value: handlerName)
    ]
    addQueryParams(components: &components)
    components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
    let url = components.url!
    return url;
  }

  // Add the query params to allow trustshare to process the intended action correctly.
  private func addQueryParams(components: inout URLComponents) {
    if case .Checkout(let checkout) = action {
      components.queryItems! += [
        URLQueryItem(name: "type", value: "checkout")
      ]

      if ((checkout.amount) != nil) {
        components.queryItems?.append(
            URLQueryItem(name: "currency", value: checkout.currency.map {
              $0.rawValue
            })
        )
      }

      ["amount", "to", "depositAmount", "from", "description"].forEach { lookup in
        let value = checkout[dynamicMember: lookup]
        if ((value) != nil) {
          components.queryItems! += [
            URLQueryItem(name: lookup, value: value)
          ]
        }
      }
    }

    if case .Topup(let topup) = action {
      components.queryItems! += [
        URLQueryItem(name: "type", value: "topup"),
        URLQueryItem(name: "token", value: topup.token)
      ]
      if ((topup.amount) != nil) {
        components.queryItems?.append(
            URLQueryItem(name: "amount", value: topup.amount)
        )
      }
    }

    if case .Release(let release) = action {
      components.queryItems! += [
        URLQueryItem(name: "type", value: "release"),
        URLQueryItem(name: "token", value: release.token)
      ]
      if ((release.amount) != nil) {
        components.queryItems?.append(
            URLQueryItem(name: "amount", value: release.amount)
        )
      }
    }

    if case .Return(let ret) = action {
      components.queryItems! += [
        URLQueryItem(name: "type", value: "return"),
        URLQueryItem(name: "token", value: ret.token)
      ]
    }

    if case .Dispute(let dispute) = action {
      components.queryItems! += [
        URLQueryItem(name: "type", value: "dispute"),
        URLQueryItem(name: "token", value: dispute.token)
      ]
    }
  }

  // Make a webview to show the relevant trustshare action.
  func makeUIView(context: Context) -> WKWebView {
    let config = WKWebViewConfiguration()
    let customUserAgent: String = config.applicationNameForUserAgent != nil
        ? config.applicationNameForUserAgent! + "-trustshare-sdk"
        : "-trustshare-sdk"
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
