#import <React/RCTBridgeModule.h>
#import <React/RCTConvert.h>

#import "GCDWebServerDataResponse.h"
#import "GCDWebServer.h"

@interface FPStaticServer : NSObject <RCTBridgeModule>

@property (nonatomic) GCDWebServer* webServer;
@property (nonatomic) NSString* rootHTML;

@end

@implementation FPStaticServer

RCT_EXPORT_MODULE();

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _webServer = [GCDWebServer new];
        _rootHTML = @"";
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
    
    __weak typeof(self) weakSelf = self;
    
    [self.webServer addDefaultHandlerForMethod:@"GET"
                                  requestClass:[GCDWebServerRequest class]
                                  processBlock:^GCDWebServerResponse *(GCDWebServerRequest* request) {
                                      return [GCDWebServerDataResponse responseWithHTML:weakSelf.rootHTML];
                                  }];
    
    if (self.webServer.isRunning != NO) {
        NSError *error = nil;
        reject(@"server_error", @"StaticServer is already up", error);
        return;
    }

    if ([self.webServer startWithOptions:webServerOptions error:&error]) {
        NSString *url = [NSString stringWithFormat: @"%@://%@:%@", [self.webServer.serverURL scheme], [self.webServer.serverURL host], [self.webServer.serverURL port]];
        
        NSLog(@"Started StaticServer at URL %@", url);

        resolve(url);
    } else {
        NSLog(@"Error starting StaticServer: %@", error);
        
        reject(@"server_error", @"StaticServer could not start", error);
    }
}

RCT_EXPORT_METHOD(setRootHTML:(NSString *)html)
{
    _rootHTML = html;
}

RCT_EXPORT_METHOD(stop) {
    if(self.webServer.isRunning == YES) {
        [self.webServer stop];

        NSLog(@"StaticServer stopped");
    }
}


@end

