//
//  RNTTicketsSdkViewManager.m
//  RNTicketmasterDemoIntegration
//
//  Created by Daniel Olugbade on 24/08/2023.
//

#import <React/RCTViewManager.h>

#if __has_include(<react_native_ticketmaster/react_native_ticketmaster-Swift.h>)
// For cocoapods framework, the generated swift header will be inside react_native_ticketmaster module
#import <react_native_ticketmaster/react_native_ticketmaster-Swift.h>
#else
#import "react_native_ticketmaster-Swift.h"
#endif

@interface RNTTicketsSdkEmbeddedViewManager : RCTViewManager
@end

@implementation RNTTicketsSdkEmbeddedViewManager

- (dispatch_queue_t)methodQueue
{
  return dispatch_get_main_queue();
}

+ (BOOL)requiresMainQueueSetup {
  return true;
}

RCT_EXPORT_MODULE(RNTTicketsSdkEmbeddedView)


- (UIView *)view
{
  TicketsSdkEmbeddedViewController *vc = [[TicketsSdkEmbeddedViewController alloc] init];
  return vc.view;
}




@end

