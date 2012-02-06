//
//  Nios.h
//  nios
//
//  Created by Sebastian Waisbrot on 2/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebViewJavascriptBridge.h"

@interface Nios : NSObject <WebViewJavascriptBridgeDelegate> {
	UIWebView* webView;
	WebViewJavascriptBridge *javascriptBridge;
}

- (Nios*) initWithScriptName:(NSString*)fileName;
- (Nios*) initWithScriptPath:(NSString*)scriptPath;
- (void) sendMessage:(NSDictionary*)message;

@end
