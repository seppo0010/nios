//
//  Nios_http_parser.m
//  nios
//
//  Created by Sebastian Waisbrot on 2/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Nios_http_parser.h"
#import "Nios.h"
#import "NSData+Base64.h"

static NSMutableSet* currentParsers = nil;

#define HTTP_CB(name)                                               \
    static int name(http_parser* p_) {                              \
      int ret = 0;                                                  \
      NSSet* _currentParsers = [currentParsers copy];               \
      for (Nios_http_parser* parser in _currentParsers) {           \
        if (parser.parser == p_) {                                  \
          ret = [parser name];                                      \
          break;                                                    \
        }                                                           \
      }                                                             \
      [_currentParsers release];                                    \
      return ret;                                                   \
    }                                                               \
                                                                    \
    - (int) name

#define HTTP_DATA_CB(name)                                          \
	static int name(http_parser* p_, const char* at, size_t length) {\
      int ret = 0;                                                  \
      NSSet* _currentParsers = [currentParsers copy];               \
	  for (Nios_http_parser* parser in _currentParsers) {           \
        if (parser.parser == p_) {                                  \
          ret = [parser name:at length:length ];                    \
          break;                                                    \
        }                                                           \
      }                                                             \
      [_currentParsers release];                                    \
      return ret;                                                   \
    }                                                               \
                                                                    \
    - (int) name:(const char*)at length:(size_t)length


static inline NSString* method_to_str(unsigned short m) {
	switch (m) {
		case HTTP_DELETE:     return @"DELETE";
		case HTTP_GET:        return @"GET";
		case HTTP_HEAD:       return @"HEAD";
		case HTTP_POST:       return @"POST";
		case HTTP_PUT:        return @"PUT";
		case HTTP_CONNECT:    return @"CONNECT";
		case HTTP_OPTIONS:    return @"OPTIONS";
		case HTTP_TRACE:      return @"TRACE";
		case HTTP_PATCH:      return @"PATCH";
		case HTTP_COPY:       return @"COPY";
		case HTTP_LOCK:       return @"LOCK";
		case HTTP_MKCOL:      return @"MKCOL";
		case HTTP_MOVE:       return @"MOVE";
		case HTTP_PROPFIND:   return @"PROPFIND";
		case HTTP_PROPPATCH:  return @"PROPPATCH";
		case HTTP_UNLOCK:     return @"UNLOCK";
		case HTTP_REPORT:     return @"REPORT";
		case HTTP_MKACTIVITY: return @"MKACTIVITY";
		case HTTP_CHECKOUT:   return @"CHECKOUT";
		case HTTP_MERGE:      return @"MERGE";
		case HTTP_MSEARCH:    return @"MSEARCH";
		case HTTP_NOTIFY:     return @"NOTIFY";
		case HTTP_SUBSCRIBE:  return @"SUBSCRIBE";
		case HTTP_UNSUBSCRIBE:return @"UNSUBSCRIBE";
		default:              return @"UNKNOWN_METHOD";
	}
}

@implementation Nios_http_parser

@synthesize parser;
@synthesize listener;
@synthesize messages;

- (Nios_http_parser*)initWithParser:(http_parser*)_parser listener:(NSString*)_listener nios:(Nios*)_nios {
	self = [self init];
	if (self) {
		parser = _parser;
		nios = _nios;
		fields = [[NSMutableArray alloc] initWithCapacity:32];
		values = [[NSMutableArray alloc] initWithCapacity:32];
		messages = [[NSMutableArray alloc] initWithCapacity:5];
		self.listener = _listener;
	}
	return self;
}

- (void) dealloc {
	[messages release];
    [url release];
    [fields release];
	[values release];
	self.listener = nil;
	[super dealloc];
}

HTTP_CB(on_message_begin) {
    [fields removeAllObjects];
	[values removeAllObjects];
    [url release];
	url = nil;
    return 0;
}

HTTP_CB(on_headers_complete) {
	NSMutableDictionary* message_info = [NSMutableDictionary dictionaryWithCapacity:10];

	int c = [fields count];
	if ([values count] < c) c = [values count];
	NSMutableArray* headers = [NSMutableArray arrayWithCapacity:c];
	for (int i = 0; i < c; i++) {
		[headers addObject:[fields objectAtIndex:i]];
		[headers addObject:[values objectAtIndex:i]];
	}
	[message_info setValue:headers forKey:@"headers"];
	[fields removeAllObjects];
	[values removeAllObjects];

    // METHOD
    if (parser->type == HTTP_REQUEST) {
		[message_info setValue:method_to_str(parser->method) forKey:@"method"];
    }
	
    // STATUS
    if (parser->type == HTTP_RESPONSE) {
		[message_info setValue:[NSNumber numberWithInt:parser->status_code] forKey:@"statusCode"];
    }

	[message_info setValue:[NSNumber numberWithInt:parser->http_major] forKey:@"versionMajor"];
	[message_info setValue:[NSNumber numberWithInt:parser->http_minor] forKey:@"versionMinor"];
	[message_info setValue:[NSNumber numberWithBool:http_should_keep_alive(parser)] forKey:@"shouldKeepAlive"];
	[message_info setValue:[NSNumber numberWithBool:parser->upgrade] forKey:@"upgrade"];
	[message_info setValue:url forKey:@"url"];

	[messages addObject:[NSArray arrayWithObjects:@"onHeadersComplete", [NSArray arrayWithObject:message_info], nil]];

	return 0;
}

HTTP_CB(on_message_complete) {
	[messages addObject:[NSArray arrayWithObjects:@"onMessageComplete", nil]];
	return 0;
}

HTTP_DATA_CB(on_url) {
	[url release];
	url = [[NSString alloc] initWithBytes:at length:length encoding:NSUTF8StringEncoding];
    return 0;
}

HTTP_DATA_CB(on_header_field) {
	NSString* field = [[NSString alloc] initWithBytes:at length:length encoding:NSUTF8StringEncoding];
	[fields addObject:field];
	[field release];
    return 0;
}

HTTP_DATA_CB(on_header_value) {
	NSString* value = [[NSString alloc] initWithBytes:at length:length encoding:NSUTF8StringEncoding];
	[values addObject:value];
	[value release];
    return 0;
}

HTTP_DATA_CB(on_body) {
	NSData* data = [[NSData alloc] initWithBytes:at length:length];
	[messages addObject:[NSArray arrayWithObjects:@"onBody", [NSArray arrayWithObject:[[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]], nil]];
	[data release];
	return 0;
}


+ (id) execute:(NSArray*)params nios:(Nios*)nios {
	if (!currentParsers) {
		currentParsers = [[NSMutableSet alloc] initWithCapacity:1];
	}
	
	http_parser parser;
	http_parser_settings settings;

	Nios_http_parser* currentParser = [[self alloc] initWithParser:&parser listener:[params lastObject] nios:nios];
	[currentParsers addObject:currentParser];
	[currentParser release];

	NSData* data = [NSData dataFromBase64String:[params objectAtIndex:1]];
	if ([[params objectAtIndex:2] isKindOfClass:[NSNumber class]] && [[params objectAtIndex:3] isKindOfClass:[NSNumber class]]) {
		NSUInteger start = [[params objectAtIndex:2] unsignedIntValue];
		NSUInteger length = [[params objectAtIndex:3] unsignedIntValue];
		if (start != 0 || length != [data length]) {
			NSRange range;
			range.location = start;
			range.length = length;
			data = [data subdataWithRange:range];
		}
	}
	
	size_t len = [data length];
	char *buffer_data = malloc(len);
	[data getBytes:buffer_data length:len];
	settings.on_message_begin    = on_message_begin;
	settings.on_url              = on_url;
	settings.on_header_field     = on_header_field;
	settings.on_header_value     = on_header_value;
	settings.on_headers_complete = on_headers_complete;
	settings.on_body             = on_body;
	settings.on_message_complete = on_message_complete;
	int type = [[params objectAtIndex:0] intValue];
	http_parser_init(&parser, type);
    size_t nparsed = http_parser_execute(&parser, &settings, buffer_data, len);

	NSArray* messages = [[currentParser.messages copy] autorelease];
	[currentParsers removeObject:currentParser];

	if (!parser.upgrade && nparsed != len) {
		return [NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Parse Error", @"message", nil]];
		// TODO : error
	}
	return [NSArray arrayWithObject:messages];
}

@end
