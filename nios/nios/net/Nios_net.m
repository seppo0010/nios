//
//  Nios_net.m
//  nios
//
//  Created by Sebastian Waisbrot on 2/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Nios_net.h"
#import "Nios.h"
#import "NSData+Base64.h"

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
//	if (host && [[newSocket connectedHost] isEqualToString:host] == FALSE) {
//		[newSocket disconnect];
//	}
	Nios_socket* nios_socket = [[[Nios_socket alloc] initWithSocket:newSocket fromServer:self nios:nios] autorelease];
	[nios_socket startReading];
	if (!clients) {
		clients = [[NSMutableSet setWithCapacity:1] retain];
	}
	[clients addObject:nios_socket];
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
	[socket release];
	[delegate release];
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
	id param = [params objectAtIndex:0];
	Nios_socket* socket;
	if ([param isKindOfClass:[NSDictionary class]]) {
		GCDAsyncSocket* _socket = [[[GCDAsyncSocket alloc] init] autorelease];
		_socket.delegateQueue = dispatch_get_main_queue();
		NSError* error = nil;
		socket = [[[Nios_socket alloc] initWithSocket:_socket withListener:[param valueForKey:@"listener"] nios:nios] autorelease];
		if (![_socket connectToHost:[param valueForKey:@"address"] onPort:[[param valueForKey:@"port"] intValue] error:&error]) {
			return [NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:
											 [error description], @"message",
											 [NSNumber numberWithInt:error.code], @"errno",
											 nil]
					];
		}
	} else if ([param isKindOfClass:[NSString class]] || [param isKindOfClass:[NSNumber class]]) {
		socket = [sDict valueForKey:[NSString stringWithFormat:@"%d", [param intValue]]];
	} else {
		return [NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:
										 // TODO: look for a similar error in node
										 @"Writting to an invalid socket", @"message",
										 -1, @"errno",
										 nil]
				];
;
	}
	NSData* data = [NSData dataFromBase64String:[params objectAtIndex:1]]; // TODO: use proper encoding
	[socket.socket writeData:data withTimeout:socket.timeout tag:0];
	[socket startReading];
	return [NSArray arrayWithObjects:[NSNull null], [NSNumber numberWithInt:socket.socketId], nil];
}

+ (id) connect:(NSArray*)params nios:(Nios*)nios {
	GCDAsyncSocket* _socket = [[[GCDAsyncSocket alloc] init] autorelease];
	Nios_socket* socket = [[[Nios_socket alloc] initWithSocket:_socket fromServer:nil nios:nios] autorelease];
	return [NSArray arrayWithObject:[NSArray arrayWithObject:[NSNumber numberWithInt:socket.socketId]]];
}

+ (id) close:(NSArray*)params nios:(Nios*)nios {
	NSString* key = [NSString stringWithFormat:@"%d", [[params objectAtIndex:0] intValue]];
	[dict removeObjectForKey:key];
	return nil;
}

+ (id) peername:(NSArray*)params nios:(Nios*)nios {
	Nios_socket* socket = [sDict valueForKey:[NSString stringWithFormat:@"%d", [[params objectAtIndex:0] intValue]]];
	return [NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:[socket.socket connectedHost], @"remoteAddress", [NSNumber numberWithInt:[socket.socket connectedPort]], @"remotePort", nil]];
}

- (void) dealloc {
	for (Nios_socket* _socket in clients) {
		[_socket disconnect];
	}
	[socket disconnect];
	self.socket = nil;
	self.listener = nil;
	self.host = nil;
	[clients release];
	[super dealloc];
}

@end

@implementation Nios_socket

@synthesize nios;
@synthesize socket;
@synthesize socketId;
@synthesize server;
@synthesize listener;

- (Nios_socket*) init {
	self = [super init];
	if (self) {
		socket.delegate = self;
		socketId = sLastId++;
		if (sDict == nil) {
			sDict = [[NSMutableDictionary alloc] initWithCapacity:1];
		}
		[sDict setValue:self forKey:[NSString stringWithFormat:@"%d", socketId]];
		[self startReading];
	}
	return self;
}

- (void) dealloc {
	[self disconnect];
	socket.delegate = nil;
	self.socket = nil;
	self.listener = nil;
	[super dealloc];
}

- (Nios_socket*)initWithSocket:(GCDAsyncSocket*)_socket withListener:(NSString*)_listener nios:(Nios*)_nios {
	self.listener = _listener;
	self.nios = _nios;
	self.socket = _socket;
	return [self init];
}

- (Nios_socket*)initWithSocket:(GCDAsyncSocket*)_socket fromServer:(Nios_net*)_server nios:(Nios*)_nios {
	self.server = _server;
	self.nios = _nios;
	self.socket = _socket;
	return [self init];
}

- (void) startReading {
	[socket readDataWithTimeout:self.timeout tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
	[nios sendMessage:[NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:@"data", data, [NSNumber numberWithInt:socketId], nil], @"parameters", self.listener, @"callback", @"1", @"keepCallback", nil]];
	[sock readDataWithTimeout:self.timeout tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
	[nios sendMessage:[NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:@"write", [NSNumber numberWithInt:socketId], nil], @"parameters", self.listener, @"callback", @"1", @"keepCallback", nil]];
}

- (void)socketDidCloseReadStream:(GCDAsyncSocket *)sock {
	[nios sendMessage:[NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:@"end", [NSNumber numberWithInt:socketId], nil], @"parameters", self.listener, @"callback", @"1", @"keepCallback", nil]];
	[nios sendMessage:[NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:@"close", [NSNumber numberWithInt:socketId], nil], @"parameters", self.listener, @"callback", @"1", @"keepCallback", nil]];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)error {
	NSString* _listener = [[self.listener retain] autorelease];
	if (error) {
		[nios sendMessage:[NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:@"error",
																	  [NSDictionary dictionaryWithObjectsAndKeys:
																	   [error description], @"message",
																	   [NSNumber numberWithInt:error.code], @"errno",
																	   nil]
																	  , nil], @"parameters", _listener, @"callback", @"0", @"keepCallback", nil]];
	}
	[nios sendMessage:[NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:@"end", [NSNumber numberWithInt:socketId], nil], @"parameters", _listener, @"callback", @"1", @"keepCallback", nil]];
	[nios sendMessage:[NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:@"close", [NSNumber numberWithInt:socketId], nil], @"parameters", _listener, @"callback", @"1", @"keepCallback", nil]];
}

- (int) timeout {
	if (server) return server.timeout;
	return -1;
}

- (NSString*)listener {
	if (listener) return listener;
	return server.listener;
}

- (void) disconnect {
	socket.delegate = nil;
	[self socketDidCloseReadStream:socket];
	[socket disconnect];
	[sDict removeObjectForKey:[NSString stringWithFormat:@"%d", socketId]];
}

@end