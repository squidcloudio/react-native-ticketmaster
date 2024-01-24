//
//  PrePurchaseView.swift
//  RNTicketmasterDemoIntegration
//
//  Created by Taka Goto on 9/25/23.
//

import Foundation
import UIKit

class PrePurchaseView: UIView {
  weak var delegate: SendAttractionIdDelegate?
  var attractionId: String = "attractionId"

  @objc(setAttractionId:)
  public func setAttractionId(_ attractionId: NSString) {
    self.attractionId = attractionId as String
  }
  
  public func getAttractionId() {
    delegate?.sendAttractionIdFromView(attractionId: attractionId)
  }
}

protocol SendAttractionIdDelegate: AnyObject {
  func sendAttractionIdFromView(attractionId: String)
}
