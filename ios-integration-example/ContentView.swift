//
//  ContentView.swift
//  ios-integration-example
//
//  Created by Simon Holmes on 14/05/2021.
//
//

import SwiftUI
import WebKit

// Example arguments to the SDK view.
let checkoutArgs = CheckoutArgs(
    to: "example+buyer@trustshare.co",
    amount: "1000",
    description: "Here is a description for the checkout"
);

//let topupArgs = TopupArgs(
//    token: "D9SyFaZThQ2mdJnK",
//    amount: "10000"
//)

//let releaseArgs = ReleaseArgs(
//    token: "D9SyFaZThQ2mdJnK",
//    amount: "100"
//)

//let disputeArgs = DisputeArgs(
//    token: "D9SyFaZThQ2mdJnK"
//)

//let returnArgs = ReturnArgs(
//    token: "D9SyFaZThQ2mdJnK",
//    amount: "100"
//)

struct ContentView: View {
  // This function is called each time the state of the Action is updated.
  func callbackFunction(message: WKScriptMessage) {
    print(message)
    guard let bodyString = message.body as? String, let bodyData = bodyString.data(using: .utf8) else {
      fatalError()
    }

    // Use the appropriate struct for decoding the data. e.g For a checkout action, use the Checkout state struct,
    let bodyStruct = try? JSONDecoder().decode(DisputeState.self, from: bodyData)
    print("Converted response from message....")
    print(bodyStruct)
  }

  var body: some View {
    TrustshareSDKView(
        action: Action.Checkout(checkoutArgs),
        subdomain: "demo", // This is your subdomain.
        handlerName: "trustshareHandler", // Custom handler name, defaulted to "trustshareHandler"
        cb: callbackFunction // Will be called on state updates.
    )
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
