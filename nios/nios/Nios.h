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

#define NiosLog NSLog

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