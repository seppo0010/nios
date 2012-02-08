//
//  Nios_dgram.h
//  nios
//
//  Created by Sebastian Waisbrot on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncUdpSocket.h"

@class Nios;
@interface Nios_dgram : NSObject <GCDAsyncUdpSocketDelegate> {
	Nios* nios;
	GCDAsyncUdpSocket* socket;
	NSString* listener;
	int socketId;
}

@property (retain) GCDAsyncUdpSocket* socket;
@property (retain) NSString* listener;
@property (assign) Nios* nios;
@property int socketId;

@end
