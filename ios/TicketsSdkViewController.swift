//
//  TicketsSdkViewController.swift
//  RNTicketmasterDemoIntegration
//
//  Created by Daniel Olugbade on 30/08/2023.
//

import TicketmasterAuthentication
import TicketmasterTickets

@objc(TicketsSdkViewController)
public class TicketsSdkViewController: UIViewController {
  var ticketsView: TMTicketsView!
  
  
  override public func viewDidLoad() {
    super.viewDidLoad()
    
    let apiKey = Config.shared.get(for: "apiKey")
    let tmxServiceSettings = TMAuthentication.TMXSettings(apiKey: apiKey,
                                                          region: .US)
    
    let branding = TMAuthentication.Branding(displayName: Config.shared.get(for: "clientName"),
                                             backgroundColor: .init(hexString: "#000000"),
                                             theme: .light)
    
    let brandedServiceSettings = TMAuthentication.BrandedServiceSettings(tmxSettings: tmxServiceSettings,
                                                                         branding: branding)
    
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
        
        let ticketsVC = TMTicketsViewController()
        ticketsVC.modalPresentationStyle = .fullScreen
        self.present(ticketsVC, animated: true, completion: nil)
        
      } failure: { error in
        // something went wrong, probably TMAuthentication was not configured correctly
        print(" - Tickets SDK Configuration Error: \(error.localizedDescription)")
      }
      
    } failure: { error in
      // something went wrong, probably the wrong apiKey+region combination
      print(" - Authentication SDK Configuration Error: \(error.localizedDescription)")
    }
    
  }
  
  override public func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    print("TicketsSdkViewController viewDidAppear")
  }
}


