//
//  MNURLRequestLoader.m
//  MNNetwork
//
//  Created by Min Kim on 6/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MNURLRequest.h"
#import "MNURLRequestQueue.h"
#import "MNURLRequestLoader.h"

@interface MNURLRequestLoader()

@property(nonatomic,readwrite) MNURLRequest      *request;
@property(nonatomic,readwrite) NSHTTPURLResponse *response;
@property(nonatomic,readwrite) NSMutableData     *responseData;
@property(nonatomic,readwrite) NSURLConnection   *connection;

- (id)process;
- (void)success:(id)data;
- (void)failure:(NSError *)error;

@end

@implementation MNURLRequestLoader

- (id)initWithRequest:(MNURLRequest *)request {
  if (self = [super init]) {
    self.request = request;
  }
  return self;
}

- (void)dealloc {
  [self cancel];
}

- (void)start {
  if (self.connection) {
    return;
  }
  self.connection = [[NSURLConnection alloc] initWithRequest:self.request
                                                    delegate:self
                                            startImmediately:NO];
  
  [self.connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
  [self.connection start];
}

- (void)cancel {
  [self.connection cancel];
  self.connection = nil;
  self.responseData = nil;
}

- (id)process {
  Class parserClass = self.request.parserClass;
  
  id data = self.responseData;
  
  if ([parserClass respondsToSelector:@selector(process:)]) {
    data = [parserClass process:self.responseData];
  }
  
  if (self.request.parseBlock) {
    data = self.request.parseBlock(data);
  }
  
  return data;
}

- (void)success:(id)data {
  if (self.request.cancelled) {
    return;
  }
  if (self.request.successBlock) {
    self.request.successBlock(self.request, data);
  }
  
  [[MNURLRequestQueue mainQueue] loaded:self];
}

- (void)failure:(NSError *)error {
  if (self.request.cancelled) {
    return;
  }
  if (self.request.failureBlock) {
    self.request.failureBlock(self.request, error);
  }
  
  [[MNURLRequestQueue mainQueue] loaded:self];
}

#pragma mark -
#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response {
  self.response = response;
  
  NSDictionary *headers = [response allHeaderFields];
  int contentLength = [[headers objectForKey:@"Content-Length"] intValue];
  
  self.responseData = [NSMutableData dataWithCapacity:contentLength];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
  [self.responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
  return cachedResponse;
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  if (self.request.cancelled) {
    return;
  }
  
  if (self.response.statusCode >= 300) {
    NSError *error = [NSError errorWithDomain:NSURLErrorDomain 
                                         code:self.response.statusCode 
                                     userInfo:nil];
    
    [self failure:error];
    
    return;
  }
  
  if (!self.request.parserClass && [self.response.MIMEType isEqualToString:@"application/json"]) {
    self.request.parserClass = [MNJSONResponseParser class];
  }
  
  __weak typeof(self) _self = self;
  
  dispatch_async([MNURLRequestQueue mainQueue].parse_queue, ^{
    id data = [_self process];
    
    dispatch_async(dispatch_get_main_queue(), ^{
      [_self success:data];
    });
  });
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  if (self.request.cancelled) {
    return;
  }
  
  [self failure:error];
}

@end
