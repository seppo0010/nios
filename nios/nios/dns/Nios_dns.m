//
//  Nios_dns.m
//  nios
//
//  Created by Sebastian Waisbrot on 2/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Nios_dns.h"
#import "Nios.h"
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <arpa/inet.h>
#import "GCDAsyncSocket.h"

@implementation Nios_dns

+ (NSString*) lookup:(NSString*)host ipv:(int*)v {
	NSError *error = nil;
	
	NSData *address4 = nil;
	NSData *address6 = nil;
	
	int port = 80; // what is this for?

	if ([host isEqualToString:@"localhost"] || [host isEqualToString:@"loopback"])
	{
		// Use LOOPBACK address
		struct sockaddr_in nativeAddr;
		nativeAddr.sin_len         = sizeof(struct sockaddr_in);
		nativeAddr.sin_family      = AF_INET;
		nativeAddr.sin_port        = htons(port);
		nativeAddr.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
		memset(&(nativeAddr.sin_zero), 0, sizeof(nativeAddr.sin_zero));
		
		struct sockaddr_in6 nativeAddr6;
		nativeAddr6.sin6_len       = sizeof(struct sockaddr_in6);
		nativeAddr6.sin6_family    = AF_INET6;
		nativeAddr6.sin6_port      = htons(port);
		nativeAddr6.sin6_flowinfo  = 0;
		nativeAddr6.sin6_addr      = in6addr_loopback;
		nativeAddr6.sin6_scope_id  = 0;
		
		// Wrap the native address structures
		address4 = [NSData dataWithBytes:&nativeAddr length:sizeof(nativeAddr)];
		address6 = [NSData dataWithBytes:&nativeAddr6 length:sizeof(nativeAddr6)];
	}
	else
	{
		NSString *portStr = [NSString stringWithFormat:@"%hu", port];
		
		struct addrinfo hints, *res, *res0;
		
		memset(&hints, 0, sizeof(hints));
		hints.ai_family   = PF_UNSPEC;
		hints.ai_socktype = SOCK_STREAM;
		hints.ai_protocol = IPPROTO_TCP;
		
		int gai_error = getaddrinfo([host UTF8String], [portStr UTF8String], &hints, &res0);
		
		if (gai_error)
		{
			NSString *errMsg = [NSString stringWithCString:gai_strerror(gai_error) encoding:NSASCIIStringEncoding];
			NSDictionary *userInfo = [NSDictionary dictionaryWithObject:errMsg forKey:NSLocalizedDescriptionKey];
			
			error = [NSError errorWithDomain:@"kCFStreamErrorDomainNetDB" code:gai_error userInfo:userInfo];
		}
		else
		{
			for(res = res0; res; res = res->ai_next)
			{
				if ((address4 == nil) && (res->ai_family == AF_INET))
				{
					// Found IPv4 address
					// Wrap the native address structure
					address4 = [NSData dataWithBytes:res->ai_addr length:res->ai_addrlen];
				}
				else if ((address6 == nil) && (res->ai_family == AF_INET6))
				{
					// Found IPv6 address
					// Wrap the native address structure
					address6 = [NSData dataWithBytes:res->ai_addr length:res->ai_addrlen];
				}
			}
			freeaddrinfo(res0);
			
			if ((address4 == nil) && (address6 == nil))
			{
				NSString *errMsg = [NSString stringWithCString:gai_strerror(gai_error) encoding:NSASCIIStringEncoding];
				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:errMsg forKey:NSLocalizedDescriptionKey];
				
				error = [NSError errorWithDomain:@"kCFStreamErrorDomainNetDB" code:gai_error userInfo:userInfo];
			}
		}
	}
	if (*v == 4) {
		return [GCDAsyncSocket hostFromAddress:address4];
	} else if (*v == 6) {
		return [GCDAsyncSocket hostFromAddress:address6];
	}
	if (address4) {
		*v = 4;
		return [GCDAsyncSocket hostFromAddress:address4];
	} else if (address6) {
		*v = 6;
		return [GCDAsyncSocket hostFromAddress:address6];
	}
	return nil;
}

+ (id)lookup:(NSArray*)params nios:(Nios*)nios {
	int ipv = 0;
	if ([params count] == 3 && [[params objectAtIndex:1] isKindOfClass:[NSNull class]] == FALSE) {
		if ([[params objectAtIndex:1] intValue] == 4) {
			ipv = 4;
		} else if ([[params objectAtIndex:1] intValue] == 6) {
			ipv = 6;
		}
	}
	NSString* result = [self lookup:[params objectAtIndex:0] ipv:&ipv];
	if (result) {
		return [NSArray arrayWithObjects:[NSNull null], result, [NSNumber numberWithInt:ipv], nil];
	}
	return nil;
}

@end
