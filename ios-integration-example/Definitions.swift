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

struct CheckoutArgs {
  var to: String?
  let from: String?
  let amount: String?
  let depositAmount: String?
  let description: String?
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
      description: String? = nil
  ) {
    self.to = to
    self.from = from
    self.amount = amount
    self.depositAmount = depositAmount
    self.description = description
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


