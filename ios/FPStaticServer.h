#import <React/RCTBridgeModule.h>

#import "GCDWebServer.h"

@interface FPStaticServer : NSObject <RCTBridgeModule> {
    GCDWebServer* _webServer;
}

@end
  
