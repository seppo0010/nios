//
//  NSObject+DictionaryInitialization.m
//  nios
//
//  Created by Sebastian Waisbrot on 3/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSObject+DictionaryInitialization.h"

@implementation NSObject (DictionaryInitialization)

- (id)initWithDictionary_n:(NSDictionary*)dictionary {
	self = [self init];
	if (self) {
		for (NSString* key in dictionary) {
			[self setValue:[dictionary valueForKey:key] forKey:key];
		}
	}
	return self;
}


@end
