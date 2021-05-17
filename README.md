# ios-integration-example
An example showing how to integrate trustshare using iOS.

## How it works
This example shows how an iOS application can be integrated with the trustshare web sdk.

The app uses a `WebView` to load a page specifically developed for mobile integration. 

Please refer to the [web sdk documentation](https://docs.trustshare.co/sdk/web-sdk) for further information and definitions for the various actions that can be carried out.

### Getting started

Look at the [ContentView.swift](/ios-integration-example/ContentView.swift) to see how we implement a view with the necessary parameters.

### The WebView
The webview loads a route at `https://${YOUR_SUBDOMAIN}.trustshare.co/mobile-sdk`.

The url requires a query parameter of at least `type` and `handlerName`.

The `type` parameter tells us what sort of `Action` you would like to do and the `handlerName` tells us where to post the state updates to.

The resulting url should look similar to this: 

`https://demo.trustshare.co/mobile-sdk?type=checkout&handlerName=myHandlerName`.

### Actions

The `mobile-sdk` route can handle a variety of [Actions](/ios-integration-example/Definitions.swift#L8-L14) which can be implemented. The enum of `Actions` is below. 

```swift
Checkout
Topup
Dispute
Return
Release
```

Each action has its own required parameters defined in their respective structs. See [Definitions](/ios-integration-example/Definitions.swift) for types.

### State updates
The example iOS app receives state updates from the webview using the [ContentController](/ios-integration-example/TrustshareView.swift#L9) class. 
If the message name is the same as the provided handler, which defaults to `"trustshareHandler"`, the message is passed on to the provided callback.

From here, we can use a `JSONDecoder` to decode the json messages and pass them into structs.

### Query strings
The webview should use a query string to communicate to the webview which [Action](/ios-integration-example/Definitions.swift#L8-L14) is intended to carry out.
In this example, the query string is built up from the arguments passed to the component. [See here](ios-integration-example/TrustshareView.swift#L91) for an example. 

### Custom user agent
The webview needs to set a custom user agent of `"iOSTrustshareSDK"`, otherwise the page will not load.

This can be done with the following code: 

```swift
webView.customUserAgent = "iOSTrustshareSDK"
```

[See here](/ios-integration-example/TrustshareView.swift#L149) for an example.

## Help and support

Please feel free to reach out to us on slack or [contact support](mailto:support@trustshare.co) if you need further guidance on integration with iOS, and we'll do our best to help.

## Improvements
We are always looking for feedback, so we can provide the best possible developer experience.
If you have any comments, suggestions, questions or feature requests, please [let us know](mailto:engineers@trustshare.co).
