//
//  MNURLRequest.m
//  MNNetwork
//
//  Created by Min Kim on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MNURLRequest.h"
#import "MNURLRequestQueue.h"

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
  [request setHTTPMethod:method];
  [request prepare];
  [[MNURLRequestQueue mainQueue] queue:request];
}

@implementation MNURLRequest

@synthesize parameters = _parameters;
@synthesize successBlock, failureBlock;
@synthesize cancelled = _cancelled;

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
  __block id _self = self;
  return ^MNURLRequest *(MNRequestSuccessBlock block) {
    [_self setSuccessBlock:block];
    return self;
  };
}

- (MNURLRequest *(^)(MNRequestFailureBlock))failure {
  __block id _self = self;
  return ^MNURLRequest *(MNRequestFailureBlock block) {
    [_self setFailureBlock:block];
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

+ (void)request:(NSURL *)URL 
         method:(NSString *)method
         before:(MNRequessBlock)before
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
  request.HTTPMethod = @"GET";
  return request;
}

+ (void)get:(NSURL *)URL 
     before:(MNRequessBlock)before
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
     before:(MNRequessBlock)before
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
      before:(MNRequessBlock)before
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
        before:(MNRequessBlock)before
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
