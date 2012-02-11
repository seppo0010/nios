//
//  NSData+NSData_proxyForJson.m
//  nios
//
//  Created by Sebastian Waisbrot on 2/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSData+proxyForJson.h"
#import "NSData+Base64.h"

@implementation NSData (proxyForJson)

- (NSString*)proxyForJson {
	return [self base64EncodedString];
}

@end
