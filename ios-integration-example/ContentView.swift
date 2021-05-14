//
//  ContentView.swift
//  ios-integration-example
//
//  Created by Simon Holmes on 14/05/2021.
//
//

import SwiftUI

// Example arguments to the SDK view.
let checkoutArgs = CheckoutArgs(
    to: "example+buyer@trustshare.co",
    amount: "1000",
    description: "Here is a description for the checkout"
);

let topupArgs = TopupArgs(
    token: "D9SyFaZThQ2mdJnK",
    amount: "10000"
)

let releaseArgs = ReleaseArgs(
    token: "D9SyFaZThQ2mdJnK",
    amount: "100"
)

let disputeArgs = DisputeArgs(
    token: "D9SyFaZThQ2mdJnK"
)

let returnArgs = ReturnArgs(
    token: "D9SyFaZThQ2mdJnK",
    amount: "100"
)

struct ContentView: View {
  // This function is called each time the state of the Action is updated.
  func callbackFunction(args: Any) {
    print(args)
  }

  var body: some View {
    TrustshareSDKView(
        action: Action.Checkout(checkoutArgs),
        subdomain: "demo", // This is your subdomain.
        cb: callbackFunction // Will be called on state updates.
    )
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}