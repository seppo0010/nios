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

//#ifdef DEBUG
//#define NiosLog(format, ...) NSLog(@"%s: " format, __FUNCTION__, ##__VA_ARGS__)
//#else
#define NiosLog(format, ...) do {} while(0)
//#endif

@protocol NiosDelegate;
@class NiosHTTPServer;
@interface Nios : NSObject <WebViewJavascriptBridgeDelegate> {
	NSString* scriptPath;
	UIWebView* webView;
	WebViewJavascriptBridge *javascriptBridge;

	NiosHTTPServer* webServer;

	id<NiosDelegate> delegate;

	NSMutableData* stdout;
	NSMutableData* stderr;

	NSMutableArray* sids;
	NSMutableArray* lines;
	NSMutableArray* frames;
	NSMutableDictionary* sourcesBySid;
}

- (Nios*) initWithScriptName:(NSString*)fileName;
- (Nios*) initWithScriptName:(NSString*)fileName delegate:(id<NiosDelegate>)_delegate;
- (Nios*) initWithScriptPath:(NSString*)scriptPath;
- (void) sendMessage:(NSDictionary*)message;
- (void) writeDataToStdin:(NSData*)data;
- (void) writeStdin:(NSString*)string;

@property (assign) id<NiosDelegate> delegate;

@end

@protocol NiosDelegate <NSObject>

@optional
- (BOOL) nios:(Nios*)nios shouldSendMessage:(NSDictionary*)dictionary;
- (void) nios:(Nios*)nios didSendMessage:(NSDictionary*)dictionary;
- (BOOL) nios:(Nios*)nios shouldProcessReceivedMessage:(NSDictionary*)dictionary;
- (void) nios:(Nios*)nios didProcessReceivedMessage:(NSDictionary*)dictionary;
- (void) niosDidFinishLoading:(Nios*)nios;

@end

@interface NiosHTTPServer : HTTPServer {
	Nios* nios;
}
@property (assign) Nios* nios;
@end

@interface NiosHTTPConnection : HTTPConnection {

}

@end

@interface NiosWebView : UIWebView {
	Nios* nios;
	id windowScriptObject;
	id privateWebView;
}

- (NiosWebView*)initWithDebugger:(Nios*)_nios;

@end