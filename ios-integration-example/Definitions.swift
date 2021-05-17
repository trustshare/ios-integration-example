//
// Created by Simon Holmes on 12/05/2021.
//

import Foundation

// The actions the SDK exposes.
enum Action {
  case Checkout(CheckoutArgs)
  case Topup(TopupArgs)
  case Dispute(DisputeArgs)
  case Return(ReturnArgs)
  case Release(ReleaseArgs)
}

enum Currency: String {
  case gbp, usd, eur // For usd payments please contact support (support@trustshare.co)
}

struct CheckoutArgs {
  var to: String?
  let from: String?
  let amount: String?
  let depositAmount: String?
  let description: String?
  let currency: Currency?
  subscript(dynamicMember member: String) -> String? {
    let props = [
      "amount": self.amount,
      "to": self.to,
      "depositAmount": self.depositAmount,
      "description": self.description,
    ]
    return props[member, default: nil];
  }

  init(
      to: String? = nil,
      from: String? = nil,
      amount: String? = nil,
      depositAmount: String? = nil,
      description: String? = nil,
      currency: Currency? = Currency.gbp
  ) {
    self.to = to
    self.from = from
    self.amount = amount
    self.depositAmount = depositAmount
    self.description = description
    self.currency = currency
  }
}

struct TopupArgs {
  var token: String
  var amount: String?
}

struct ReturnArgs {
  var token: String
  var amount: String?
}

struct ReleaseArgs {
  var token: String
  var amount: String?
}

struct DisputeArgs {
  var token: String
}

struct CheckoutState: Codable {
  let token: String?
  let paymentToken: String?
  let status: String
}


