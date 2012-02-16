//
//  Nios.m
//  nios
//
//  Created by Sebastian Waisbrot on 2/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Nios.h"
#import "NSObject+SBJson.h"
#import "HTTPServer.h"
#import "HTTPMessage.h"
#import "HTTPDataResponse.h"

@implementation Nios

@synthesize delegate;

static UInt16 nios_webport = 8889;

- (Nios*) init {
	self = [super init];
	if (self) {
		webServer = [[NiosHTTPServer alloc] init];
		[webServer setType:@"_http._tcp."];
		[webServer setPort:nios_webport++];
		[webServer setConnectionClass:[NiosHTTPConnection class]];
		NSError *error = nil;
		if(![webServer start:&error]) {
			NSLog(@"Failed to start web server");
		}
	}
	return self;
}

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

- (Nios*) initWithScriptName:(NSString*)fileName delegate:(id<NiosDelegate>)_delegate {
	delegate = _delegate;
	return [self initWithScriptName:fileName];
}

- (Nios*) initWithScriptPath:(NSString*)scriptPath {
	self = [self init];
	if (self) {
		webView = [[UIWebView alloc] initWithFrame:CGRectZero];
		javascriptBridge = [[WebViewJavascriptBridge javascriptBridgeWithDelegate:self] retain];
		webView.delegate = javascriptBridge;

		NSString* architecture = @"unknown";
#ifdef __i386__
		architecture = @"i386";
#endif
#ifdef __ARM_ARCH_7A__
		architecture = @"armv7";
#endif
#ifdef __arm__
		architecture = @"arm";
#endif

		NSString* modulesPath = [[[NSBundle mainBundle] pathForResource:@"Nios" ofType:@"js"] stringByDeletingLastPathComponent];
		NSString* htmlString = [NSString stringWithFormat:@"<script>window.NIOS_BASEPATH = [\"%@\"];</script><script src=\"file://%@\"></script><script src=\"file://%@\"></script><script>document.addEventListener('WebViewJavascriptBridgeReady', function() { Nios_initialize('%@', '%@', %d); require_fullpath(\"%@\"); });</script>", modulesPath, [[[[NSBundle mainBundle] pathForResource:@"Nios" ofType:@"js"]stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@" " withString:@"%20"], [[[[NSBundle mainBundle] pathForResource:@"json2" ofType:@"js"]stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@" " withString:@"%20"], architecture, [[UIDevice currentDevice] model], webServer.port, scriptPath];
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

- (void) sendMessage:(NSDictionary*)message {
	if ([delegate respondsToSelector:@selector(nios:shouldSendMessage:)]) {
		if (![delegate performSelector:@selector(nios:shouldSendMessage:) withObject:self withObject:message]) {
			return;
		}
	}
	NSString* jsonMessage = [message JSONRepresentation];
	NiosLog(@"sendMessage: \n%@", jsonMessage);
	[javascriptBridge sendMessage:jsonMessage toWebView:webView];
	if ([delegate respondsToSelector:@selector(nios:didSendMessage:)]) {
		[delegate performSelector:@selector(nios:didSendMessage:) withObject:self withObject:message];
	}
}

- (void)javascriptBridge:(WebViewJavascriptBridge *)bridge receivedMessage:(NSString *)message fromWebView:(UIWebView *)_webView {
	NiosLog(@"receivedMessage: \n%@", message);
	NSDictionary* call = [message JSONValue];

	if ([delegate respondsToSelector:@selector(nios:shouldProcessReceivedMessage:)]) {
		if (![delegate performSelector:@selector(nios:shouldProcessReceivedMessage:) withObject:self withObject:message]) {
			return;
		}
	}

	Class class = NSClassFromString([call valueForKey:@"class"]);
	id ret = [class performSelector:sel_getUid([[NSString stringWithFormat:@"%@:nios:", [call valueForKey:@"method"]] UTF8String]) withObject:[call valueForKey:@"parameters"] withObject:self];
	
	if ([delegate respondsToSelector:@selector(nios:didProcessReceivedMessage:)]) {
		if (![delegate performSelector:@selector(nios:didProcessReceivedMessage:) withObject:self withObject:message]) {
			return;
		}
	}
	if (![[call valueForKey:@"callback"] isKindOfClass:[NSNull class]]) {
		NSDictionary* reply = [NSDictionary dictionaryWithObjectsAndKeys:ret, @"parameters", [call valueForKey:@"callback"], @"callback", nil];
		[self sendMessage:reply];
	}
}

+ (id) ping:(NSArray*)params nios:(Nios*)nios {
	return [NSArray arrayWithObject:@"PONG!"];
}

@end

@implementation NiosHTTPServer

@synthesize nios;

@end

@implementation NiosHTTPConnection

- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path
{
	if ([method isEqualToString:@"POST"] && [path isEqualToString:@"/"]) {
		return YES;
	}
	return NO;
}

- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)path
{
	if([method isEqualToString:@"POST"])
		return YES;
	
	return [super expectsRequestBodyFromMethod:method atPath:path];
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
	
	if ([method isEqualToString:@"POST"] && [path isEqualToString:@"/"])
	{
		
		NSString *postStr = nil;
		
		NSData *postData = [request body];
		NSData *response = nil;		
		if (postData)
		{
			postStr = [[[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding] autorelease];
			NSDictionary* call = [postStr JSONValue];
			Class class = NSClassFromString([call valueForKey:@"class"]);
			id ret = [class performSelector:sel_getUid([[NSString stringWithFormat:@"%@:nios:", [call valueForKey:@"method"]] UTF8String]) withObject:[call valueForKey:@"parameters"] withObject:[(NiosHTTPServer*)config.server nios]];

			response = [[[NSDictionary dictionaryWithObjectsAndKeys:ret, @"parameters", [call valueForKey:@"callback"], @"callback", nil] JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
		}
		
		return [[[HTTPDataResponse alloc] initWithData:response] autorelease];
	}
	
	return [super httpResponseForMethod:method URI:path];
}

- (void)prepareForBodyWithSize:(UInt64)contentLength { }

- (void)processBodyData:(NSData *)postDataChunk
{
	[request appendData:postDataChunk];
}

@end
