//
//  Nios.h
//  nios
//
//  Created by Sebastian Waisbrot on 2/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebViewJavascriptBridge.h"
#import "HTTPConnection.h"
#import "HTTPServer.h"

#ifdef DEBUG_PRINT
#define NiosLog(format, ...) NSLog(@"%s: " format, __FUNCTION__, ##__VA_ARGS__)
#else
#define NiosLog(format, ...) do {} while(0)
#endif

@class NiosHTTPServer;
@interface Nios : NSObject <WebViewJavascriptBridgeDelegate> {
	UIWebView* webView;
	WebViewJavascriptBridge *javascriptBridge;

	NiosHTTPServer* webServer;
}

- (Nios*) initWithScriptName:(NSString*)fileName;
- (Nios*) initWithScriptPath:(NSString*)scriptPath;
- (void) sendMessage:(NSDictionary*)message;

@end

@interface NiosHTTPServer : HTTPServer {
	Nios* nios;
}
@property (assign) Nios* nios;
@end

@interface NiosHTTPConnection : HTTPConnection {

}

@end