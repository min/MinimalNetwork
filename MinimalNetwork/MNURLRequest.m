//
//  MNURLRequest.m
//  MNNetwork
//
//  Created by Min Kim on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MNURLRequest.h"
#import "MNURLRequestQueue.h"
#import <UIKit/UIKit.h>

///////////////////////////////////////////////////////////////////////////////////////////////////
void MNNetworkRequestStarted() {
  [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
void MNNetworkRequestFinished() {
  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

@interface MNURLRequest()

- (id)initWithURL:(NSURL *)URL 
       parameters:(NSDictionary *)parameters 
          success:(MNRequestSuccessBlock)success
          failure:(MNRequestFailureBlock)failure;

- (void)prepare;

@end

@implementation NSMutableArray(MNURLRequestAdditions)

- (id)mn_dequeue {
  if (self.count == 0) return nil;
  
  id firstObject = [self objectAtIndex:0];
  if (firstObject != nil) {
    [self removeObject:firstObject];
    return firstObject;
  }

  return nil;
}

- (id)mn_enqueue:(id)object {
  [self addObject:object];
  return object;
}

@end

@implementation NSString(MNURLRequestAdditions)

- (NSString *)mn_escape {
  CFStringRef escaped = 
  CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                          (__bridge CFStringRef)self,
                                          NULL,
                                          (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                          kCFStringEncodingUTF8);
  NSString *string = [(__bridge NSString *)escaped copy];
  CFRelease(escaped);
  return string;
}

- (NSDictionary *)mn_queryParameters {
  NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
  NSEnumerator *components = [[self componentsSeparatedByString:@"&"] reverseObjectEnumerator];
  for (NSString *component in components) {
    if ([component length] == 0) {
      continue;
    }
      
    NSRange pos = [component rangeOfString:@"="];
    NSString *key;
    NSString *val;
    if (pos.location == NSNotFound) {
      key = [component mn_escape];
      val = @"";
    } else {
      key = [[component substringToIndex:pos.location] mn_escape];
      val = [[component substringFromIndex:pos.location + pos.length] mn_escape];
    }
    if (!key) key = @"";
    if (!val) val = @"";
    [parameters setObject:val forKey:key];
  }
  return parameters;
}

@end

@implementation NSDictionary(MNURLRequestAdditions)

- (NSString *)mn_queryString {
  NSMutableArray *params = [NSMutableArray arrayWithCapacity:[self count]];
  NSString *key;
  for (key in self) {
    [params addObject:[NSString stringWithFormat:@"%@=%@",
                          [key mn_escape],
                          [[[self objectForKey:key] description] mn_escape]
                       ]
     ];
  }
  return [params componentsJoinedByString:@"&"];
}

@end

@implementation MNURLRequest

@synthesize parameters = _parameters;
@synthesize successBlock, failureBlock, beforeBlock, parseBlock;
@synthesize cancelled = _cancelled;

- (id)initWithURL:(NSURL *)URL method:(NSString *)method {
  if ((self = [self initWithURL:URL])) {
    self.HTTPMethod = method;
  }
  return self;
}

- (id)initWithURL:(NSURL *)URL 
       parameters:(NSDictionary *)parameters 
          success:(MNRequestSuccessBlock)success
          failure:(MNRequestFailureBlock)failure {
  if ((self = [self initWithURL:URL])) {
    
    self.successBlock = success;
    self.failureBlock = failure;
    self.parserClass = [MNURLResponseParser class];
    
    if (parameters) {
      [self.parameters addEntriesFromDictionary:parameters];
    }
  }
  return self;
}

- (void)dealloc {
  self.successBlock = nil;
  self.failureBlock = nil;
  self.beforeBlock = nil;
  self.parseBlock = nil;
}

- (void)prepare {
  if (self.beforeBlock) {
    self.beforeBlock(self);
  }

  if (self.parameters.count > 0) {
    NSString *method = self.HTTPMethod;
    if (
        [method isEqualToString:@"GET"] ||
        [method isEqualToString:@"HEAD"] ||
        [method isEqualToString:@"DELETE"]
        )
    {
      NSString *separator = [self.URL.absoluteString rangeOfString:@"?"].location == NSNotFound ? @"?" : @"&";
      
      self.URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [self.URL.absoluteString copy], separator, [self.parameters mn_queryString]]];
      
    } else {
      [self setValue:@"application/x-www-form-urlencoded;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
      [self setHTTPBody:[[self.parameters mn_queryString] dataUsingEncoding:NSUTF8StringEncoding]];
    }
  }
}

- (NSMutableDictionary *)parameters {
  if (nil == _parameters) {
    _parameters = [NSMutableDictionary dictionaryWithCapacity:0];
  }
  return _parameters;
}

- (MNURLRequest *(^)(MNRequestSuccessBlock))success {
  return ^MNURLRequest *(MNRequestSuccessBlock block) {
    self.successBlock = block;
    return self;
  };
}

- (MNURLRequest *(^)(MNRequestFailureBlock))failure {
  return ^MNURLRequest *(MNRequestFailureBlock block) {
    self.failureBlock = block;
    return self;
  };
}

- (MNURLRequest *(^)(MNRequestBlock))before {
  return ^MNURLRequest *(MNRequestBlock block) {
    self.beforeBlock = block;
    return self;
  };
}

- (MNURLRequest *(^)(MNRequestParseBlock))parse {
  return ^MNURLRequest *(MNRequestParseBlock block) {
    self.parseBlock = block;
    return self;
  };
}

- (MNURLRequest *(^)())send {
  [self prepare];
  [[MNURLRequestQueue mainQueue] queue:self];
  
  return ^{
    return self;
  };
}

- (void)cancel {
  [[MNURLRequestQueue mainQueue] cancel:self];
}

+ (MNURLRequest *)get:(NSString *)URLString {
  return [[MNURLRequest alloc] initWithURL:[NSURL URLWithString:URLString]
                                    method:@"GET"];;
}

+ (MNURLRequest *)post:(NSString *)URLString {
  return [[MNURLRequest alloc] initWithURL:[NSURL URLWithString:URLString]
                                    method:@"POST"];;
}

@end
