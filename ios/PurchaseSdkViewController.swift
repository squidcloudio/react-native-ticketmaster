//
//  PurchaseSdkViewController.swift
//  RNTicketmasterDemoIntegration
//
//  Created by Daniel Olugbade on 24/08/2023.
//

import TicketmasterAuthentication
import TicketmasterTickets
import TicketmasterPurchase

@objc(PurchaseSdkViewController)
public class PurchaseSdkViewController: UIViewController, SendEventIdDelegate {
  var eventId: String = "eventId"
  
  override public func viewDidLoad() {
    super.viewDidLoad()

    let customView = PurchaseView()
    customView.delegate = self
    self.view = customView
    
    let apiKey = Config.shared.get(for: "apiKey")
    let tmxServiceSettings = TMAuthentication.TMXSettings(apiKey: apiKey,
                                                          region: .US)
    
    let branding = TMAuthentication.Branding(displayName: Config.shared.get(for: "clientName"),
                                             backgroundColor: .init(hexString: "#000000"),
                                             theme: .light)
    
    let brandedServiceSettings = TMAuthentication.BrandedServiceSettings(tmxSettings: tmxServiceSettings,
                                                                         branding: branding)

    TMPurchase.shared.brandColor = UIColor(red: 0.00, green: 0.00, blue: 0.00, alpha: 1.00)
    TMPurchase.shared.configure(apiKey: apiKey, region: .US) {
    purchaseConfigured in

       print(" - Purchase Configured: \(purchaseConfigured)")

    
    // configure TMAuthentication with Settings and Branding
    print("Authentication SDK Configuring...")
    TMAuthentication.shared.configure(brandedServiceSettings: brandedServiceSettings) {
      backendsConfigured in
      
      // your API key may contain configurations for multiple backend services
      // the details are not needed for most common use-cases
      print(" - Authentication SDK Configured: \(backendsConfigured.count)")
      
      // TMTickets inherits it's configuration and branding from TMAuthentication
      print("Tickets SDK Configuring...")
      TMTickets.shared.configure {
        
        // Tickets is configured, now we are ready to present TMTicketsViewController or TMTicketsView
        print(" - Tickets SDK Configured")
        
        customView.getEventId()
        let edpNav = TMPurchaseNavigationController.eventDetailsNavigationController(eventIdentifier: self.eventId, marketDomain: .US)
        edpNav.modalPresentationStyle = .fullScreen
        self.present(edpNav, animated: true)
        
      } failure: { error in
        // something went wrong, probably TMAuthentication was not configured correctly
        print(" - Tickets SDK Configuration Error: \(error.localizedDescription)")
      }
    } failure: { error in
      // something went wrong, probably the wrong apiKey+region combination
      print(" - Authentication SDK Configuration Error: \(error.localizedDescription)")
    }
    }
    
  }
  
  func sendEventIdFromView(eventId: String) {
    print("Received data in UIViewController: \(eventId)")
    self.eventId = eventId
  }
  
  override public func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    print("PurchaseSdkViewController viewDidAppear")
  }
  
  @objc(setEventId:)
  public func setEventId(_ eventId: NSString) {
    self.eventId = eventId as String
  }
}
