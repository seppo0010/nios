//
//  NSObject+DictionaryInitialization.h
//  nios
//
//  Created by Sebastian Waisbrot on 3/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (DictionaryInitialization)

- (id)initWithDictionary_n:(NSDictionary*)dictionary; // ugly name, but avoiding collision

@end
