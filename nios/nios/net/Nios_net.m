//
//  Nios_net.m
//  nios
//
//  Created by Sebastian Waisbrot on 2/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Nios_net.h"
#import "Nios.h"

@implementation Nios_net

@synthesize socket;
@synthesize listener;
@synthesize host;
@synthesize nios;
@synthesize socketId;

static NSMutableDictionary* dict = nil;
static int lastId = 1;

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
	if (host && [[newSocket connectedHost] isEqualToString:host] == FALSE) {
		[newSocket disconnect];
	}
	int newSocketId = lastId++;
	[dict setValue:newSocket forKey:[NSString stringWithFormat:@"%d", newSocketId]];
	[nios sendMessage:[NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:@"connect", [NSNumber numberWithInt:newSocketId], nil], @"parameters", listener, @"callback", @"1", @"keepCallback", nil]];
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {}

- (void)socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag {}
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {}

- (void)socket:(GCDAsyncSocket *)sock didWritePartialDataOfLength:(NSUInteger)partialLength tag:(long)tag {}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag
				 elapsed:(NSTimeInterval)elapsed
			   bytesDone:(NSUInteger)length {
	[nios sendMessage:[NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:@"timeout", nil], @"parameters", listener, @"callback", @"1", @"keepCallback", nil]];
	return 0.0f;
}

- (void)socketDidCloseReadStream:(GCDAsyncSocket *)sock {
	[nios sendMessage:[NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:@"close", nil], @"parameters", listener, @"callback", @"0", @"keepCallback", nil]];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)error {
	[nios sendMessage:[NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:@"error",
																  [NSDictionary dictionaryWithObjectsAndKeys:
																   [error description], @"message",
																   [NSNumber numberWithInt:error.code], @"errno",
																   nil]
																  , nil], @"parameters", listener, @"callback", @"0", @"keepCallback", nil]];
	[nios sendMessage:[NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:@"close", nil], @"parameters", listener, @"callback", @"0", @"keepCallback", nil]];
}

- (void)socketDidSecure:(GCDAsyncSocket *)sock {}

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

	[nios sendMessage:[NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:@"listening", [NSNumber numberWithInt:socketId], nil], @"parameters", [params lastObject], @"callback", @"1", @"keepCallback", nil]];
	return [NSArray arrayWithObjects:[NSNumber numberWithInt:delegate.socketId], [delegate.socket localHost], [NSNumber numberWithInt:[delegate.socket localPort]], nil];
}


@end

@implementation Nios_socket

@synthesize nios;
@synthesize socket;
@synthesize listener;
@synthesize socketId;

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
	[nios sendMessage:[NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:@"connection", [NSNumber numberWithInt:socketId], nil], @"parameters", listener, @"callback", @"1", @"keepCallback", nil]];
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {}
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
	[nios sendMessage:[NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:@"data", data, nil], @"parameters", listener, @"callback", @"1", @"keepCallback", nil]];
}

- (void)socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag {}
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {}
- (void)socket:(GCDAsyncSocket *)sock didWritePartialDataOfLength:(NSUInteger)partialLength tag:(long)tag {}
- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag
				 elapsed:(NSTimeInterval)elapsed
			   bytesDone:(NSUInteger)length {
	[nios sendMessage:[NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:@"timeout", nil], @"parameters", listener, @"callback", @"1", @"keepCallback", nil]];
	return 0.0f;
}

- (void)socketDidCloseReadStream:(GCDAsyncSocket *)sock {
	[nios sendMessage:[NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:@"end", nil], @"parameters", listener, @"callback", @"1", @"keepCallback", nil]];
	[nios sendMessage:[NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:@"close", nil], @"parameters", listener, @"callback", @"1", @"keepCallback", nil]];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)error {
	[nios sendMessage:[NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:@"error",
																  [NSDictionary dictionaryWithObjectsAndKeys:
																   [error description], @"message",
																   [NSNumber numberWithInt:error.code], @"errno",
																   nil]
																  , nil], @"parameters", listener, @"callback", @"0", @"keepCallback", nil]];
	[nios sendMessage:[NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:@"end", nil], @"parameters", listener, @"callback", @"1", @"keepCallback", nil]];
	[nios sendMessage:[NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:@"close", nil], @"parameters", listener, @"callback", @"1", @"keepCallback", nil]];
}

- (void)socketDidSecure:(GCDAsyncSocket *)sock {}

@end