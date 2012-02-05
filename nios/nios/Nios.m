//
//  Nios.m
//  nios
//
//  Created by Sebastian Waisbrot on 2/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Nios.h"
#import "NSObject+SBJson.h"

@implementation Nios

- (Nios*) initWithScriptName:(NSString*)fileName {
	NSArray* components = [fileName componentsSeparatedByString:@"."];
	if ([components count] > 2) {
		NSRange range;range.location=0;range.length = [components count] - 1;
		NSArray* _components = [components subarrayWithRange:range];
		components = [NSArray arrayWithObjects:[_components componentsJoinedByString:@"."], [components lastObject], nil];
	}
	else if ([components count] == 1) {
		// XXX: will this work?
		components = [NSArray arrayWithObjects:[components objectAtIndex:0], @"", nil];
	}
	return [self initWithScriptPath:[[NSBundle mainBundle] pathForResource:[components objectAtIndex:0] ofType:[components objectAtIndex:1]]];
}

- (Nios*) initWithScriptPath:(NSString*)scriptPath {
	self = [super init];
	if (self) {
		webView = [[UIWebView alloc] initWithFrame:CGRectZero];
		javascriptBridge = [[WebViewJavascriptBridge javascriptBridgeWithDelegate:self] retain];
		webView.delegate = javascriptBridge;

		NSString* modulesPath = [[[NSBundle mainBundle] pathForResource:@"Nios" ofType:@"js"] stringByDeletingLastPathComponent];
		NSString* htmlString = [NSString stringWithFormat:@"<script>window.NIOS_BASEPATH = [\"%@\"];</script><script src=\"file://%@\"></script><script src=\"file://%@\"></script><script>document.addEventListener('WebViewJavascriptBridgeReady', function() { require_fullpath(\"%@\"); });</script>", modulesPath, [[[[NSBundle mainBundle] pathForResource:@"Nios" ofType:@"js"]stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@" " withString:@"%20"], [[[[NSBundle mainBundle] pathForResource:@"json2" ofType:@"js"]stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@" " withString:@"%20"], scriptPath];
		[webView loadHTMLString:htmlString baseURL:nil];
	}
	return self;
}

- (void) dealloc {
	[javascriptBridge setDelegate:nil];
	[javascriptBridge release];
	[webView release];
	[super dealloc];
}

- (void)javascriptBridge:(WebViewJavascriptBridge *)bridge receivedMessage:(NSString *)message fromWebView:(UIWebView *)_webView {
	NSDictionary* call = [message JSONValue];
	Class class = NSClassFromString([call valueForKey:@"class"]);
	id ret = [class performSelector:sel_getUid([[NSString stringWithFormat:@"%@:", [call valueForKey:@"method"]] UTF8String]) withObject:[call valueForKey:@"parameters"]];
	if (![[call valueForKey:@"callback"] isKindOfClass:[NSNull class]]) {
		[javascriptBridge sendMessage:[[NSDictionary dictionaryWithObjectsAndKeys:ret, @"returnValue", [call valueForKey:@"callback"], @"callback", nil] JSONRepresentation] toWebView:_webView];
	}
}

@end
