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

static int gMNNetworkRequestsCount = 0;
static dispatch_queue_t requests_count_queue;

///////////////////////////////////////////////////////////////////////////////////////////////////
void MNNetworkRequestStarted() {
//  dispatch_async(requests_count_queue, ^{
//    if (0 == gMNNetworkRequestsCount) {
//      [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
//    }
//    gMNNetworkRequestsCount++;
//  });
}


///////////////////////////////////////////////////////////////////////////////////////////////////
void MNNetworkRequestFinished() {
//  dispatch_async(requests_count_queue, ^{
//    --gMNNetworkRequestsCount;
//    gMNNetworkRequestsCount = MAX(0, gMNNetworkRequestsCount);
//    
//    if (gMNNetworkRequestsCount == 0) {
//      [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//    }
//  });
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
  NSArray *components = [[self componentsSeparatedByString:@"&"] reverseObjectEnumerator];
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

static inline void MNRequestWithMethod(MNURLRequest *request, NSString *method) {
  [request setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
  [request setHTTPMethod:method];
  [request prepare];
  [[MNURLRequestQueue mainQueue] queue:request];
}

@implementation MNURLRequest

@synthesize parameters = _parameters;
@synthesize successBlock, failureBlock, beforeBlock, parseBlock;
@synthesize cancelled = _cancelled;

+ (void)initialize {
  static dispatch_once_t once_token;
  dispatch_once(&once_token, ^{
    requests_count_queue = dispatch_queue_create("com.min.requests", NULL);
  });
}

- (id)initWithURL:(NSURL *)URL 
       parameters:(NSDictionary *)parameters 
          success:(MNRequestSuccessBlock)success
          failure:(MNRequestFailureBlock)failure {
  if ((self = [self initWithURL:URL])) {
    self.successBlock = success;
    self.failureBlock = failure;
    
    if (parameters) {
      [self.parameters addEntriesFromDictionary:parameters];
    }
  }
  return self;
}

- (void)dealloc {
}

- (void)prepare {  
  if (self.beforeBlock) {
    self.beforeBlock(self);
  }
  if (self.parameters && [self.parameters isKindOfClass:[NSDictionary class]] && self.parameters.count > 0) {
    NSString *method = self.HTTPMethod;
    if ([method isEqualToString:@"GET"] || [method isEqualToString:@"HEAD"] || [method isEqualToString:@"DELETE"]) {
      NSString *separator = [self.URL.absoluteString rangeOfString:@"?"].location == NSNotFound ? @"?" : @"&";
      
      self.URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", self.URL.absoluteString, separator, [self.parameters mn_queryString]]];
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
  return ^MNURLRequest *(MNRequestParseBlock parse) {
    self.parseBlock = parse;
    return self;
  };
}

- (MNURLRequest *(^)())send {
  return ^{
    MNRequestWithMethod(self, self.HTTPMethod);
    return self;
  };
}

- (void)cancel {
  [[MNURLRequestQueue mainQueue] cancel:self];
}

+ (MNURLRequest *)get:(NSString *)URLString {
  MNURLRequest *request = [[MNURLRequest alloc] initWithURL:[NSURL URLWithString:URLString]];
  request.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
  request.HTTPMethod = @"GET";
  
  return request;
}

+ (MNURLRequest *)post:(NSString *)URLString {
  MNURLRequest *request = [[MNURLRequest alloc] initWithURL:[NSURL URLWithString:URLString]];
  request.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
  request.HTTPMethod = @"POST";
  
  return request;
}

@end
