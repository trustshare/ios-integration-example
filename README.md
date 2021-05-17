# ios-integration-example
An example showing how to integrate trustshare using iOS.

## How it works
This example shows how an iOS application can be integrated with the trustshare web sdk.

The app uses a `WebView` to load a page specifically developed for mobile integration. 


### Actions

The `mobile-sdk` route can handle a variety of `Actions` which can be implemented. The enum of `Actions` is below. 

```swift
Checkout
Topup
Dispute
Return
Release
```



### Query strings
The webview should use a query string to communicate to the webview which [Action](/ios-integration-example/Definitions.swift#L8-L14) is intended to carry out.
In this example, the query string is built up from the arguments passed to the component. [See here](ios-integration-example/TrustshareView.swift#L91) for an example. 

### Custom user agent
The webview needs to set a custom user agent of `"iOSTrustshareSDK"`, otherwise the page will not load.
This can be done with the following code

```swift
  webView.customUserAgent = "iOSTrustshareSDK"
```

[See here](/ios-integration-example/TrustshareView.swift#L149) for an example.

## Help and support

Please feel free to reach out to us on slack or [contact support](mailto:support@trustshare.co) if you need further guidance on integration with iOS, and we'll do our best to help.

## Improvements
We are always looking for feedback, so we can provide the best possible developer experience.
If you have any comments, suggestions, questions or feature requests, please [let us know](mailto:engineers@trustshare.co).
