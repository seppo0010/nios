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

@class WebView;
@class WebScriptCallFrame;
@class WebFrame;

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

- (Nios*) initWithScriptPath:(NSString*)_scriptPath {
	self = [self init];
	if (self) {
		scriptPath = [_scriptPath retain];
		webView = [[NiosWebView alloc] initWithDebugger:self];
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
		NSString* htmlString = [NSString stringWithFormat:@"<script>window.NIOS_BASEPATH = [\"%@\"];</script><script src=\"file://%@\"></script><script src=\"file://%@\"></script><script>document.addEventListener('WebViewJavascriptBridgeReady', function() { Nios_initialize('%@', '%@', '%@', %d, %d); onBridgeReady(); require_fullpath('%@'); });</script>",
								modulesPath,
								[[[[NSBundle mainBundle] pathForResource:@"Nios" ofType:@"js"]stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@" " withString:@"%20"],
								[[[[NSBundle mainBundle] pathForResource:@"json2" ofType:@"js"]stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@" " withString:@"%20"],
								architecture,
								[[UIDevice currentDevice] model],
								[[[NSProcessInfo processInfo] processName] stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"],
								[[NSProcessInfo processInfo] processIdentifier],
								webServer.port,
								scriptPath];
		[webView loadHTMLString:htmlString baseURL:nil];
	}
	return self;
}

+ (void)didFinishLoading:(NSArray*)args nios:(Nios*)_self {
	if ([_self.delegate respondsToSelector:@selector(niosDidFinishLoading:)]) {
		[_self.delegate performSelector:@selector(niosDidFinishLoading:) withObject:_self];
	}
}

#ifdef DEBUG
- (void) printStackForSourceId:(int)sid line:(int)lineno {
	@try {
		NSString* line = [[[sourcesBySid valueForKey:[NSString stringWithFormat:@"%d", sid]] componentsSeparatedByString:@"\n"] objectAtIndex:lineno];
		if (line.length > 100) {
			line = [line substringToIndex:100];
		}
		NSLog(@"%@", line);
	}
	@catch (NSException *exception) {
		NSLog(@"Unable to fetch line %d of sourceId %d", lineno, sid);
	}
}
- (void)webView:(WebView *)_webView   exceptionWasRaised:(WebScriptCallFrame *)frame
       sourceId:(int)sid
           line:(int)lineno
    forWebFrame:(WebFrame *)webFrame
{
	if ([@"require_fullpath" isEqualToString:[frame performSelector:@selector(functionName)]]) {
		NSLog(@"Probably uncaught exception; stopping javascript");
		[webView performSelector:@selector(release) withObject:nil afterDelay:0.0f];
		webView = nil;
		return;
	}
	NSString* exceptionText = [[frame performSelector:@selector(exception)] performSelector:@selector(callWebScriptMethod:withArguments:) withObject:@"toString" withObject:[NSArray array]];
	NSLog(@"NSDD: exception: sid=%d line=%d function=%@, caller=%@, exception=%@", sid, lineno, [frame performSelector:@selector(functionName)], [frame performSelector:@selector(caller)], exceptionText);

	[self printStackForSourceId:sid line:lineno-1];
#ifdef DEBUG_DESPERATE
	int pos = [frames indexOfObject:frame];
	while (pos < [frames count] - 2) {
		[frames removeObjectAtIndex:pos + 1];
		[lines removeObjectAtIndex:pos + 1];
		[sids removeObjectAtIndex:pos + 1];
	}

	for (int i = 0; i < [lines count]; i++) {
		int lineno = [[lines objectAtIndex:i] intValue];
		if (i == [lines count] - 1) lineno++;
		else lineno--; // lineno is 1-based
		[self printStackForSourceId:[[sids objectAtIndex:i] intValue] line:lineno];
	}
#endif
}

- (void)webView:(WebView *)webView       didParseSource:(NSString *)source
 baseLineNumber:(unsigned int)lineNumber
		fromURL:(NSURL *)url
	   sourceId:(int)sid
	forWebFrame:(WebFrame *)webFrame {
	if (sourcesBySid == nil) {
		sourcesBySid = [[NSMutableDictionary alloc] init];
	}
	[sourcesBySid setValue:source forKey:[NSString stringWithFormat:@"%d", sid]];
}


- (void)webView:(WebView *)webView  failedToParseSource:(NSString *)source
 baseLineNumber:(unsigned)lineNumber
        fromURL:(NSURL *)url
      withError:(NSError *)error
    forWebFrame:(WebFrame *)webFrame
{
    NSLog(@"NSDD: called failedToParseSource: url=%@ line=%d error=%@\nsource=%@", url, lineNumber, error, source);
}

#ifdef DEBUG_DESPERATE
- (void)webView:(WebView *)webView    didEnterCallFrame:(WebScriptCallFrame *)frame
	   sourceId:(int)sid
		   line:(int)lineno
	forWebFrame:(WebFrame *)webFrame {
	if (frames == nil) {
		frames = [[NSMutableArray alloc] init];
	}
	[frames addObject:frame];
}

- (void)webView:(WebView *)webView   willLeaveCallFrame:(WebScriptCallFrame *)frame
	   sourceId:(int)sid
		   line:(int)lineno
	forWebFrame:(WebFrame *)webFrame {
	int pos = -1;
	for (int i = [frames count] - 1; i >= 0; i--) {
		if (frame == [frames objectAtIndex:i]) {
			pos = i;
			break;
		}
	}
	if (pos >= 0 && pos < [frames count] - 1) {
		[frames removeObjectAtIndex:pos];
		[lines removeObjectAtIndex:pos];
		[sids removeObjectAtIndex:pos];
	}
}

- (void)webView:(WebView *)webView willExecuteStatement:(WebScriptCallFrame *)frame
	   sourceId:(int)sid
		   line:(int)lineno
	forWebFrame:(WebFrame *)webFrame {
	if (lines == nil) {
		lines = [[NSMutableArray alloc] init];
	}
	if (sids == nil) {
		sids = [[NSMutableArray alloc] init];
	}

	int pos = -1;
	for (int i = [frames count] - 1; i >= 0; i--) {
		if (frame == [frames objectAtIndex:i]) {
			pos = i;
			break;
		}
	}
	while (pos > [lines count]) {
		[lines addObject:[NSNumber numberWithInt:0]];
	}
	while (pos > [sids count]) {
		[sids addObject:[NSNumber numberWithInt:0]];
	}
	if (pos == [lines count]) {
		[lines addObject:[NSNumber numberWithInt:lineno]];
	} else {
		[lines replaceObjectAtIndex:pos withObject:[NSNumber numberWithInt:lineno]];
	}
	if (pos == [sids count]) {
		[sids addObject:[NSNumber numberWithInt:sid]];
	} else {
		[sids replaceObjectAtIndex:pos withObject:[NSNumber numberWithInt:sid]];
	}
}
#endif

#endif

- (void) dealloc {
	[scriptPath release];
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
		NSDictionary* reply = [NSDictionary dictionaryWithObjectsAndKeys:[call valueForKey:@"callback"], @"callback", ret ? ret : [NSArray array], @"parameters", nil];
		[self sendMessage:reply];
	}
}

- (void) writeDataToStdin:(NSData*)data {
	[self sendMessage:[NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObject:data], @"parameters", @"stdindata", @"callback", @"1", @"keepCallback", nil]];
}

- (void) writeStdin:(NSString*)string {
	[self writeDataToStdin:[string dataUsingEncoding:NSUTF8StringEncoding]];
}

+ (id) writeStdout:(NSArray*)parameters nios:(Nios*)nios {
	id<NiosDelegate> delegate = nios.delegate;
	if ([delegate respondsToSelector:@selector(nios:receivedStdout:)]) {
		[delegate performSelector:@selector(nios:receivedStdout:) withObject:nios withObject:[parameters objectAtIndex:0]];
	}
#ifdef DEBUG
	printf("%s", [[parameters objectAtIndex:0] UTF8String]);
#endif
	return nil;
}

+ (id) writeStderr:(NSArray*)parameters nios:(Nios*)nios {
	id<NiosDelegate> delegate = nios.delegate;
	if ([delegate respondsToSelector:@selector(nios:receivedStderr:)]) {
		[delegate performSelector:@selector(nios:receivedStderr:) withObject:nios withObject:[parameters objectAtIndex:0]];
	}
#ifdef DEBUG
	fprintf(stderr, "%s", [[parameters objectAtIndex:0] UTF8String]);
#endif
	return nil;
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

@implementation NiosWebView
- (NiosWebView*)initWithDebugger:(Nios*)_nios {
	nios = _nios;
	return [self init];
}

#ifdef DEBUG
- (void)webView:(id)webView didClearWindowObject:(id)windowObject forFrame:(WebFrame*)frame {
	[webView performSelector:@selector(setScriptDebugDelegate:) withObject:nios];
}
#endif

@end

