//
//  PurchaseView.swift
//  RNTicketmasterDemoIntegration
//
//  Created by Taka Goto on 9/25/23.
//

import Foundation
import UIKit

class PurchaseView: UIView {
  weak var delegate: SendEventIdDelegate?
  var eventId: String = "eventId"

  @objc(setEventId:)
  public func setEventId(_ eventId: NSString) {
    self.eventId = eventId as String
  }
  
  public func getEventId() {
    delegate?.sendEventIdFromView(eventId: eventId)
  }
}

protocol SendEventIdDelegate: AnyObject {
  func sendEventIdFromView(eventId: String)
}
