//
//  PrePurchaseSdkViewController.swift
//  RNTicketmasterDemoIntegration
//
//  Created by Daniel Olugbade on 24/08/2023.
//

import TicketmasterAuthentication
import TicketmasterTickets
import TicketmasterPrePurchase

@objc(PrePurchaseSdkViewController)
public class PrePurchaseSdkViewController: UIViewController, SendAttractionIdDelegate {
  var attractionId: String = "attractionId"

  override public func viewDidLoad() {
    super.viewDidLoad()
    
    let customView = PrePurchaseView()
    customView.delegate = self
    self.view = customView
    
    print("PrePurchaseSdkViewController viewDidLoad")
    let apiKey = Config.shared.get(for: "apiKey")
    let tmxServiceSettings = TMAuthentication.TMXSettings(apiKey: apiKey,
                                                          region: .US)
    
    let branding = TMAuthentication.Branding(displayName: Config.shared.get(for: "clientName"),
                                             backgroundColor: .init(hexString: "#000000"),
                                             theme: .light)
    
    let brandedServiceSettings = TMAuthentication.BrandedServiceSettings(tmxSettings: tmxServiceSettings,
                                                                         branding: branding)

    TMPrePurchase.shared.brandColor = UIColor(red: 0.00, green: 0.00, blue: 0.00, alpha: 1.00)
    TMPrePurchase.shared.configure(apiKey: apiKey, region: .US) {
    prepurchaseConfigured in

          print(" - PrePurchase Configured: \(prepurchaseConfigured)")

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
        
        customView.getAttractionId()
        let viewController = TMPrePurchaseViewController.attractionDetailsViewController(attractionIdentifier: self.attractionId, enclosingEnvironment: .modalPresentation)
        viewController.modalPresentationStyle = .fullScreen
        self.present(viewController, animated: true)
        
        
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
  
  func sendAttractionIdFromView(attractionId: String) {
    print("Received data in UIViewController: \(attractionId)")
    self.attractionId = attractionId
  }
  
  override public func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    print("PrePurchaseSdkViewController viewDidAppear")
   
  }

}
