#import <React/RCTBridgeModule.h>
#import <React/RCTConvert.h>

#import "GCDWebServerDataResponse.h"
#import "GCDWebServer.h"

@interface FPStaticServer : NSObject <RCTBridgeModule>

@property (nonatomic) GCDWebServer* webServer;
@property (nonatomic) NSString* html;

@end

@implementation FPStaticServer

RCT_EXPORT_MODULE();

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _webServer = [GCDWebServer new];
        _html = @"";
    }
    
    return self;
}

- (void)dealloc {
    if (self.webServer.isRunning == YES) {
        [self.webServer stop];
    }
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_queue_create("com.futurepress.staticserver", DISPATCH_QUEUE_SERIAL);
}

RCT_EXPORT_METHOD(start:(NSDictionary *)options
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    if (self.webServer.isRunning) {
        [self.webServer stop];
        [self.webServer removeAllHandlers];
    }
    
    NSError *error;
    NSMutableDictionary* webServerOptions = [NSMutableDictionary dictionary];
    NSNumber *port = [RCTConvert NSNumber:options[@"port"]];
    
    [webServerOptions setObject:port forKey:GCDWebServerOption_Port];
    [webServerOptions setObject:@YES forKey:GCDWebServerOption_BindToLocalhost];
    
    __weak typeof(self) weakSelf = self;
    
    [self.webServer addDefaultHandlerForMethod:@"GET"
                                  requestClass:[GCDWebServerRequest class]
                                  processBlock:^GCDWebServerResponse *(GCDWebServerRequest* request) {
                                      return [GCDWebServerDataResponse responseWithHTML:weakSelf.html];
                                  }];
    
    if (![self.webServer startWithOptions:webServerOptions error:&error]) {
        reject(@"server_error", @"StaticServer could not start", error);
        
        return;
    }
    
    NSString *url = [NSString stringWithFormat: @"%@://%@:%@", [self.webServer.serverURL scheme], [self.webServer.serverURL host], [self.webServer.serverURL port]];
    
    resolve(url);
}

RCT_EXPORT_METHOD(setHtml:(NSString *)html) {
    _html = html;
}

RCT_EXPORT_METHOD(stop) {
    if(self.webServer.isRunning == YES) {
        [self.webServer stop];
    }
}


@end

