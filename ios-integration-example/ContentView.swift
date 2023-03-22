import SwiftUI
import WebKit
struct ContentView: View {
  @State private var showTrustshareWebView = false
  @State private var clientSecret: String?

  // This function is called each time the state of the Action is updated.
  // Handle the message from the Trustshare iFrame.
  func callbackFunction(message: WKScriptMessage) {
    // Types are defined at the top of this file.
    // Decode the message body into a string.
    guard let bodyString = message.body as? String, let bodyData = bodyString.data(using: .utf8) else {
        fatalError()  
    }

    // Convert the data into a CheckoutState struct.
    let bodyStruct = try? JSONDecoder().decode(CheckoutState.self, from: bodyData)
    
    // Print the decoded response from Trustshare.
    print("Converted response from message....")
    print(bodyStruct)

    // If the response is a "complete" message, then hide the Trustshare iFrame and fetch the client secret.
    if (bodyStruct?.type == "complete") {
        self.showTrustshareWebView = false;
        fetchClientSecret()
    }
}

  // When the view is loaded, fetch the client secret from the server.
  func fetchClientSecret() {
    guard let url = URL(string: "http://localhost:9987/createPaymentIntent") else {
      fatalError("Invalid URL")
    }

    URLSession.shared.dataTask(with: url) { data, response, error in
      guard let data = data, error == nil else {
        fatalError("Error fetching client secret: \(error?.localizedDescription ?? "Unknown error")")
      }

      if let response = try? JSONDecoder().decode(CreatePaymentIntentResponse.self, from: data) {
        self.clientSecret = response.client_secret
      } else {
        fatalError("Error decoding response")
      }
    }.resume()
  }

    var body: some View {
    if (showTrustshareWebView) {
      if let clientSecret = self.clientSecret {
        TrustshareSDKView(
            clientSecret: clientSecret,
            handlerName: "trustshareHandler", // Custom handler name, defaulted to "trustshareHandler"
            cb: callbackFunction // Will be called on state updates.
        )
      } else {
        Text("Loading...")
          .onAppear(perform: fetchClientSecret)
      }
    } else {
      Button(action: {
        self.showTrustshareWebView = true
      }) {
        Text("trustshare iOS example")
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}

struct CreatePaymentIntentResponse: Codable {
  let client_secret: String
}
