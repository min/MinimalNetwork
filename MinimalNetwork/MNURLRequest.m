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
@synthesize successBlock, failureBlock, beforeBlock;
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
  __weak id _self = self;
  
  return ^MNURLRequest *(MNRequestSuccessBlock block) {
    [_self setSuccessBlock:block];
    return _self;
  };
}

- (MNURLRequest *(^)(MNRequestFailureBlock))failure {
  __weak id _self = self;
  
  return ^MNURLRequest *(MNRequestFailureBlock block) {
    [_self setFailureBlock:block];
    return _self;
  };
}

- (MNURLRequest *(^)(MNRequestBlock))before {
  __weak id _self = self;
  
  return ^MNURLRequest *(MNRequestBlock block) {
    [_self setBeforeBlock:block];
    return _self;
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

+ (void)request:(NSURL *)URL 
         method:(NSString *)method
         before:(MNRequestBlock)before
        success:(MNRequestSuccessBlock)success
        failure:(MNRequestFailureBlock)failure {
  MNURLRequest *request = [[MNURLRequest alloc] initWithURL:URL];
  
  __weak MNURLRequest *_request = request;
  
  if (before) {
    before(_request);
  }
  
  request.successBlock = success;
  request.failureBlock = failure;
  
  MNRequestWithMethod(request, method);
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

+ (void)get:(NSURL *)URL 
     before:(MNRequestBlock)before
    success:(MNRequestSuccessBlock)success
    failure:(MNRequestFailureBlock)failure {
  
  [self request:URL 
         method:@"GET" 
         before:before 
        success:success 
        failure:failure
   ];
}

+ (void)put:(NSURL *)URL 
     before:(MNRequestBlock)before
    success:(MNRequestSuccessBlock)success
    failure:(MNRequestFailureBlock)failure {
  
  [self request:URL 
         method:@"PUT" 
         before:before 
        success:success 
        failure:failure
   ];
}

+ (void)post:(NSURL *)URL 
      before:(MNRequestBlock)before
     success:(MNRequestSuccessBlock)success
     failure:(MNRequestFailureBlock)failure {
  
  [self request:URL 
         method:@"POST" 
         before:before 
        success:success 
        failure:failure
   ];
}

+ (void)delete:(NSURL *)URL 
        before:(MNRequestBlock)before
       success:(MNRequestSuccessBlock)success
       failure:(MNRequestFailureBlock)failure {
  
  [self request:URL 
         method:@"DELETE" 
         before:before 
        success:success 
        failure:failure
   ];
}

@end
