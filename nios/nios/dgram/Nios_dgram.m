//
//  Nios_dgram.m
//  nios
//
//  Created by Sebastian Waisbrot on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Nios_dgram.h"
#import "Nios.h"
#import "GCDAsyncUdpSocket.h"

@implementation Nios_dgram

@synthesize socket;
@synthesize listener;
@synthesize nios;
@synthesize socketId;

- (void) dealloc {
	if (socket.delegate == self) {
		socket.delegate = nil;
	}
	[socket release];
	self.listener = nil;
	[super dealloc];
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address {}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError *)error {
	//TODO: send error
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag {}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error {}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
	  fromAddress:(NSData *)address
withFilterContext:(id)filterContext {
	[nios sendMessage:[NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys: [NSArray arrayWithObjects:data, [NSDictionary dictionaryWithObjectsAndKeys:address, @"address", [NSNumber numberWithInt:socket.localPort], @"port", [NSNumber numberWithInt:[data length]], @"size", nil], nil], @"parameters", [NSString stringWithFormat:@"%d", socketId], @"socketId", @"message", @"event", nil]], @"parameters", listener, @"callback", @"1", @"keepCallback", nil]];
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error {
	//TODO: send error
	[nios sendMessage:[NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat:@"%d", socketId], @"socketId", @"close", @"event", nil]], @"parameters", listener, @"callback", @"1", @"keepCallback", nil]];
}

static NSMutableDictionary* dict = nil;
static int lastId = 1;

+ (id)bind:(NSArray*)params nios:(Nios*)nios {
	if (dict == nil) {
		dict = [[NSMutableDictionary alloc] initWithCapacity:1024];
	}
	GCDAsyncUdpSocket* socket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
	Nios_dgram* delegate = [[self alloc] init];
	socket.delegate = delegate;
	delegate.listener = [params lastObject];
	delegate.socket = socket;
	delegate.nios = nios;
	delegate.socketId = lastId;
	NSError* error;
	int port = [[params objectAtIndex:0] intValue];
	NSString* key = [NSString stringWithFormat:@"%d", lastId++];
	if ([socket bindToPort:port error:&error]) {
		[dict setValue:delegate forKey:key];
	} else {
		// TODO: error handling
		return nil;
	}
	if (![[params objectAtIndex:1] isKindOfClass:[NSNull class]]) {
		if (![socket bindToAddress:[[params objectAtIndex:1] dataUsingEncoding:NSUTF8StringEncoding] error:&error]) {
			// TODO: error handling
			[dict removeObjectForKey:key];
			return nil;
		}
	}
	if ([socket beginReceiving:&error]) {
		return [NSArray arrayWithObjects:[NSNumber numberWithInt:delegate.socketId], [socket localHost], nil];
	} else {
		// TODO: error handling
		[dict removeObjectForKey:key];
		return nil;
	}
}

+ (id)send:(NSArray*)params nios:(Nios*)nios {
	Nios_dgram* connection = [dict valueForKey:[NSString stringWithFormat:@"%d", [params objectAtIndex:0]]];
	NSData* data = [[params objectAtIndex:1] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
	NSRange range;
	range.location = [[params objectAtIndex:2] unsignedIntValue]; 
	range.length = [[params objectAtIndex:3] unsignedIntValue];
	NSData* dataToSend = [data subdataWithRange:range];
	[connection.socket sendData:dataToSend toHost:[params objectAtIndex:5] port:[[params objectAtIndex:4] intValue] withTimeout:0 tag:0];
	return nil;
}

+ (id)close:(NSArray*)params nios:(Nios*)nios {
	NSString* key = [NSString stringWithFormat:@"%d", [params objectAtIndex:0]];
	Nios_dgram* connection = [dict valueForKey:key];
	[connection.socket close];
	[connection release];
	[dict removeObjectForKey:key];
	return nil;
}

+ (id)setBroadcast:(NSArray*)params nios:(Nios*)nios {
	NSString* key = [NSString stringWithFormat:@"%d", [params objectAtIndex:0]];
	Nios_dgram* connection = [dict valueForKey:key];
	NSError* error = nil;
	if (![connection.socket enableBroadcast:[[params objectAtIndex:1] boolValue] error:&error]) {
		// TODO: handle me
		return nil;
	}
	return nil;
}

+ (id)setTTL:(NSArray*)params nios:(Nios*)nios {
	// TODO: not implemented
	return nil;
}

+ (id)setMulticastTTL:(NSArray*)params nios:(Nios*)nios {
	// TODO: not implemented
	return nil;
}

+ (id)setMulticastLoopback:(NSArray*)params nios:(Nios*)nios {
	// TODO: not implemented
	return nil;
}

+ (id)addMembership:(NSArray*)params nios:(Nios*)nios {
	NSString* key = [NSString stringWithFormat:@"%d", [params objectAtIndex:0]];
	Nios_dgram* connection = [dict valueForKey:key];
	NSError* error = nil;
	if (![connection.socket joinMulticastGroup:[params objectAtIndex:0] error:&error]) {
		return nil;
	}
	return nil;
}

+ (id)dropMembership:(NSArray*)params nios:(Nios*)nios {
	
	// TODO: not implemented
	return nil;
}

@end
