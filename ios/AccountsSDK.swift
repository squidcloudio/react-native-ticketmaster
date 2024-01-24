//
//  AccountsSDK.swift
//  RNTicketmasterDemoIntegration
//
//  Created by Daniel Olugbade on 24/08/2023.
//

import TicketmasterAuthentication
import TicketmasterTickets


@objc(AccountsSDK)
class AccountsSDK: RCTEventEmitter, TMAuthenticationDelegate  {
  
  @objc public func configureAccountsSDK(_ resolve: @escaping (String) -> Void, reject: @escaping (_ code: String, _ message: String, _ error: NSError) -> Void) {
    
    TMAuthentication.shared.delegate = self
    
    
    // build a combination of Settings and Branding
    let apiKey = Config.shared.get(for: "apiKey")
    let tmxServiceSettings = TMAuthentication.TMXSettings(apiKey: apiKey,
                                                          region: .US)
    
    let branding = TMAuthentication.Branding(displayName: Config.shared.get(for: "clientName"),
                                             backgroundColor: .red,
                                             theme: .light)
    
    let brandedServiceSettings = TMAuthentication.BrandedServiceSettings(tmxSettings: tmxServiceSettings,
                                                                         branding: branding)

    // configure TMAuthentication with Settings and Branding
    print("Authentication SDK Configuring...")
    
    TMAuthentication.shared.configure(brandedServiceSettings: brandedServiceSettings) { backendsConfigured in
      // your API key may contain configurations for multiple backend services
      // the details are not needed for most common use-cases
      print(" - Authentication SDK Configured: \(backendsConfigured.count)")
      resolve("Authentication SDK configuration successful")
    } failure: { error in
      // something went wrong, probably the wrong apiKey+region combination
      print(" - Authentication SDK Configuration Error: \(error.localizedDescription)")
      reject( "Authentication SDK Configuration Error:", error.localizedDescription, error as NSError)
    }
  }
  
  override func supportedEvents() -> [String]! {
    // replace return [""]; with below to send Native Event to React Native side
    // return ["loginStarted"];
    return ["onStateChanged"];
  }
  
  
  @objc public func login(_ resolve: @escaping ([String: Any]) -> Void, reject: @escaping (_ code: String, _ message: String, _ error: NSError) -> Void) {
    
    TMAuthentication.shared.login { authToken in
      print("Login Completed")
      print(" - AuthToken: \(authToken.accessToken.prefix(20))...")
      let data = ["accessToken": authToken.accessToken]
      resolve(data)
    } aborted: { oldAuthToken, backend in
      let data = ["accessToken": ""]
      resolve(data)
      print("Login Aborted by User")
    } failure: { oldAuthToken, error, backend in
      print("Login Error: \(error.localizedDescription)")
      reject( "Accounts SDK Login Error", error.localizedDescription, error as NSError)
    }
  }
  
  
  @objc public func logout(_ resolve: @escaping (String) -> Void, reject: @escaping (_ code: String, _ message: String, _ error: NSError) -> Void) {
    
    TMAuthentication.shared.logout { backends in
      resolve("Logout Successful")
      print("Logout Completed")
      print(" - Backends Count: \(backends?.count ?? 0)")
    }
  }
  
  @objc public func refreshToken(_ resolve: @escaping ([String: Any]) -> Void, reject: @escaping (_ code: String, _ message: String, _ error: NSError) -> Void) {
    
    TMAuthentication.shared.validToken { authToken in
      print("Token Refreshed (if needed)")
      print(" - AuthToken: \(authToken.accessToken.prefix(20))...")
      let data = ["accessToken": authToken.accessToken]
      resolve(data)
    } aborted: { oldAuthToken, backend in
      print("Refresh Login Aborted by User")
      let data = ["accessToken": ""]
      resolve(data)
    } failure: { oldAuthToken, error, backend in
      print("Refresh Error: \(error.localizedDescription)")
      reject( "Accounts SDK Refresh Token Error", error.localizedDescription, error as NSError)
    }
  }
  
  @objc public func getMemberInfo(_ resolve: @escaping ([String: Any]) -> Void, reject: @escaping (_ code: String, _ message: String, _ error: NSError) -> Void) {
    
    TMAuthentication.shared.memberInfo { memberInfo in
      print("MemberInfo Completed")
      print(" - UserID: \(memberInfo.localID ?? "<nil>")")
      print(" - Email: \(memberInfo.email ?? "<nil>")")
      let data = ["memberInfoId": memberInfo.localID, "memberInfoEmail": memberInfo.email]
      resolve(data as [String : Any])
    } failure: { oldMemberInfo, error, backend in
      print("MemberInfo Error: \(error.localizedDescription)")
      reject( "Accounts SDK Member Info Error", error.localizedDescription, error as NSError)
    }
  }
  
  @objc public func getToken(_ resolve: @escaping ([String: Any]) -> Void, reject: @escaping (_ code: String, _ message: String, _ error: NSError) -> Void) {
    TMAuthentication.shared.validToken(showLoginIfNeeded: false) { authToken in
      print("Token Retrieved")
      let data = ["accessToken": authToken.accessToken]
      resolve(data)
    } aborted: { oldAuthToken, backend in
      print("Token Retrieval Aborted ")
      let data = ["accessToken": ""]
      resolve(data)
    } failure: { oldAuthToken, error, backend in
      print("Token Retrieval Error: \(error.localizedDescription)")
      reject( "Accounts SDK Token Retrieval Error", error.localizedDescription, error as NSError)
    }
  }
  
  @objc public func isLoggedIn(_ resolve: @escaping ([String: Bool]) -> Void, reject: @escaping (_ code: String, _ message: String, _ error: NSError) -> Void) {
    
    TMAuthentication.shared.memberInfo { memberInfo in
      guard let id = memberInfo.globalID else {
        resolve(["result": false])
        return
      }
      
      let hasToken = TMAuthentication.shared.hasToken()
      resolve(["result": hasToken])
      
    } failure: { oldMemberInfo, error, backend in
      reject("Accounts SDK Is Logged In Error", error.localizedDescription, error as NSError)
    }
  }
  
  func onStateChanged(backend: TicketmasterAuthentication.TMAuthentication.BackendService?, state: TicketmasterAuthentication.TMAuthentication.ServiceState, error: (Error)?) {

    print("Backend TicketmasterAuthentication \(state.rawValue)")
    self.sendEvent(withName: "onStateChanged", body: state.rawValue)
  }
}



