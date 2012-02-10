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
}

@property (retain) GCDAsyncSocket* socket;
@property (retain) NSString* listener;
@property (retain) NSString* host;
@property (assign) Nios* nios;
@property int socketId;

@end

@interface Nios_socket : NSObject <GCDAsyncSocketDelegate> {
	Nios* nios;
	GCDAsyncSocket* socket;
	NSString* listener;
	int socketId;
	int timeout;
}

@property (retain) GCDAsyncSocket* socket;
@property (retain) NSString* listener;
@property (assign) Nios* nios;
@property int socketId;

- (Nios_socket*)initWithSocket:(GCDAsyncSocket*)_socket nios:(Nios*)_nios;

@end