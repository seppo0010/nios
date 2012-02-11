//
//  Nios_net.m
//  nios
//
//  Created by Sebastian Waisbrot on 2/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Nios_net.h"
#import "Nios.h"

static NSMutableDictionary* dict = nil;
static int lastId = 1;
static NSMutableDictionary* sDict = nil;
static int sLastId = 1;

@implementation Nios_net

@synthesize socket;
@synthesize listener;
@synthesize host;
@synthesize nios;
@synthesize socketId;
@synthesize timeout;

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
	NSLog(@"socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket %d", [newSocket isIPv4]);
//	if (host && [[newSocket connectedHost] isEqualToString:host] == FALSE) {
//		[newSocket disconnect];
//	}
	Nios_socket* nios_socket = [[[Nios_socket alloc] initWithSocket:newSocket nios:nios] autorelease];
	nios_socket.server = self;
	[nios sendMessage:[NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:@"connection", [NSNumber numberWithInt:nios_socket.socketId], nil], @"parameters", listener, @"callback", @"1", @"keepCallback", nil]];

}

+ (id)create:(NSArray*)params nios:(Nios*)nios {
	if (dict == nil) {
		dict = [[NSMutableDictionary alloc] initWithCapacity:1024];
	}
	GCDAsyncSocket* socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
	Nios_net* delegate = [[self alloc] init];
	socket.delegate = delegate;
	delegate.listener = [params lastObject];
	delegate.socket = socket;
	delegate.nios = nios;
	delegate.socketId = lastId;
	delegate.timeout = -1;
	[dict setValue:delegate forKey:[NSString stringWithFormat:@"%d", lastId++]];
	return [NSArray arrayWithObjects:[NSNull null], [NSNumber numberWithInt:delegate.socketId], [delegate.socket localHost], nil];
}

+ (id) listen:(NSArray*)params nios:(Nios*)nios {
	int socketId = [[[self create:[NSArray arrayWithObject:[params lastObject]] nios:nios] objectAtIndex:1] intValue];
	NSString* key = [NSString stringWithFormat:@"%d", socketId];
	Nios_net* delegate = [dict valueForKey:key];
	
	NSError* error;
	int port;
	if ([[params objectAtIndex:0] isKindOfClass:[NSNull class]]) {
		port = 12345;
		// TODO: random port
	} else {
		port = [[params objectAtIndex:0] intValue];
	}
	if (![delegate.socket acceptOnPort:port error:&error]) {
		// TODO: error handling
		[dict removeObjectForKey:key];
		return nil;
	}
	if (![[params objectAtIndex:1] isKindOfClass:[NSNull class]]) {
		delegate.host = [params objectAtIndex:1];
	}

	[delegate.socket setIPv6Enabled:NO];
	[nios sendMessage:[NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:@"listening", [NSNumber numberWithInt:socketId], nil], @"parameters", [params lastObject], @"callback", @"1", @"keepCallback", nil]];
	return [NSArray arrayWithObjects:[NSNumber numberWithInt:delegate.socketId], [delegate.socket localHost], [NSNumber numberWithInt:[delegate.socket localPort]], nil];
}

+ (id) write:(NSArray*)params nios:(Nios*)nios {
	Nios_socket* socket = [sDict valueForKey:[NSString stringWithFormat:@"%d", [[params objectAtIndex:0] intValue]]];
	NSData* data = [[params objectAtIndex:1] dataUsingEncoding:NSUTF8StringEncoding]; // TODO: use proper encoding
	[socket.socket writeData:data withTimeout:socket.server.timeout tag:0];
	return nil;
}

@end

@implementation Nios_socket

@synthesize nios;
@synthesize socket;
@synthesize listener;
@synthesize socketId;
@synthesize server;

- (Nios_socket*)initWithSocket:(GCDAsyncSocket*)_socket nios:(Nios*)_nios {

	self = [self init];
	if (self) {
		self.socket = _socket;
		socketId = sLastId++;
		self.nios = _nios;
		if (sDict == nil) {
			sDict = [[NSMutableDictionary alloc] initWithCapacity:1];
		}
		[sDict setValue:self forKey:[NSString stringWithFormat:@"%d", socketId]];
	}
	return self;
}
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
	NSLog(@"Nios_socket:: socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag");
	[nios sendMessage:[NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:@"data", data, nil], @"parameters", listener, @"callback", @"1", @"keepCallback", nil]];
	[sock readDataWithTimeout:server.timeout tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
	[nios sendMessage:[NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:@"write", nil], @"parameters", listener, @"callback", @"1", @"keepCallback", nil]];
}

- (void)socketDidCloseReadStream:(GCDAsyncSocket *)sock {
	[nios sendMessage:[NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:@"end", nil], @"parameters", listener, @"callback", @"1", @"keepCallback", nil]];
	[nios sendMessage:[NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:@"close", nil], @"parameters", listener, @"callback", @"1", @"keepCallback", nil]];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)error {
	if (error) {
		[nios sendMessage:[NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:@"error",
																	  [NSDictionary dictionaryWithObjectsAndKeys:
																	   [error description], @"message",
																	   [NSNumber numberWithInt:error.code], @"errno",
																	   nil]
																	  , nil], @"parameters", listener, @"callback", @"0", @"keepCallback", nil]];
	}
	[nios sendMessage:[NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:@"end", nil], @"parameters", listener, @"callback", @"1", @"keepCallback", nil]];
	[nios sendMessage:[NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:@"close", nil], @"parameters", listener, @"callback", @"1", @"keepCallback", nil]];
}

@end