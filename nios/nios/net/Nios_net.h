//
//  Nios_net.h
//  nios
//
//  Created by Sebastian Waisbrot on 2/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

@class Nios;
@interface Nios_net : NSObject <GCDAsyncSocketDelegate> {
	Nios* nios;
	GCDAsyncSocket* socket;
	NSString* listener;
	NSString* host;
	int socketId;
	int timeout;
}

@property (retain) GCDAsyncSocket* socket;
@property (retain) NSString* listener;
@property (retain) NSString* host;
@property (assign) Nios* nios;
@property int socketId;
@property int timeout;

@end

@interface Nios_socket : NSObject <GCDAsyncSocketDelegate> {
	Nios* nios;
	GCDAsyncSocket* socket;
	int socketId;
	Nios_net* server;
}

@property (retain) GCDAsyncSocket* socket;
@property (assign) Nios* nios;
@property (assign) Nios_net* server;
@property int socketId;

- (Nios_socket*)initWithSocket:(GCDAsyncSocket*)_socket fromServer:(Nios_net*)_server nios:(Nios*)_nios;

@end