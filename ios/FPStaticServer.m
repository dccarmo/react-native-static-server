#import <React/RCTConvert.h>

#import "FPStaticServer.h"
#import "GCDWebServerDataResponse.h"


@implementation FPStaticServer

RCT_EXPORT_MODULE();

- (instancetype)init {
    if (self = [super init]) {
        _webServer = [GCDWebServer new];
    }
    
    return self;
}

- (void)dealloc {
    if (_webServer.isRunning == YES) {
        [_webServer stop];
    }
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_queue_create("com.futurepress.staticserver", DISPATCH_QUEUE_SERIAL);
}

RCT_EXPORT_METHOD(start:(NSDictionary *)options
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    NSError *error;
    NSMutableDictionary* webServerOptions = [NSMutableDictionary dictionary];
    NSNumber *port = [RCTConvert NSNumber:options[@"port"]];
    
    if (![port isEqualToNumber:[NSNumber numberWithInt:-1]]) {
        [webServerOptions setObject:port forKey:GCDWebServerOption_Port];
    } else {
        [webServerOptions setObject:[NSNumber numberWithInteger:8080] forKey:GCDWebServerOption_Port];
    }

    [webServerOptions setObject:[RCTConvert NSNumber:options[@"localhostOnly"]] forKey:GCDWebServerOption_BindToLocalhost];
    [webServerOptions setObject:[RCTConvert NSNumber:options[@"keepAlive"]] forKey:GCDWebServerOption_AutomaticallySuspendInBackground];
    
    if (_webServer.isRunning != NO) {
        NSError *error = nil;
        reject(@"server_error", @"StaticServer is already up", error);
        return;
    }

    if ([_webServer startWithOptions:webServerOptions error:&error]) {
        NSString *url = [NSString stringWithFormat: @"%@://%@:%@", [_webServer.serverURL scheme], [_webServer.serverURL host], [_webServer.serverURL port]];
        
        NSLog(@"Started StaticServer at URL %@", url);

        resolve(url);
    } else {
        NSLog(@"Error starting StaticServer: %@", error);
        
        reject(@"server_error", @"StaticServer could not start", error);
    }
}

RCT_EXPORT_METHOD(setRootHTML:(NSString *)html)
{
    [_webServer removeAllHandlers];
    
    [_webServer addDefaultHandlerForMethod:@"GET"
                              requestClass:[GCDWebServerRequest class]
                              processBlock:^GCDWebServerResponse *(GCDWebServerRequest* request) {
                                  return [GCDWebServerDataResponse responseWithHTML:html];
                              }];
}

RCT_EXPORT_METHOD(stop) {
    if(_webServer.isRunning == YES) {
        [_webServer stop];

        NSLog(@"StaticServer stopped");
    }
}


@end

