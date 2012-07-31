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
@property(nonatomic,readwrite) MNURLRequestQueue *queue;
@property(nonatomic,readwrite) NSHTTPURLResponse *response;
@property(nonatomic,readwrite) NSMutableData     *responseData;
@property(nonatomic,readwrite) NSURLConnection   *connection;

- (id)process;

@end

@implementation MNURLRequestLoader

@synthesize request = _request, response = _response, responseData = _responseData;
@synthesize connection = _connection, queue = _queue;

+ (id)process:(NSHTTPURLResponse *)response data:(NSData *)data request:(MNURLRequest *)request {
  NSString *mimeType = response.MIMEType;
  
  Class parserClass = request.parserClass;
  
  if ([mimeType isEqualToString:@"application/json"]) {
    parserClass = [MNJSONResponseParser class];
  }
  
  if ([parserClass respondsToSelector:@selector(process:)]) {
    return [parserClass process:data];
  }

  return data;
}

- (id)initWithRequest:(MNURLRequest *)request queue:(MNURLRequestQueue *)queue {
  if (self = [super init]) {
    self.request     = request;
    self.queue       = queue;
  }
  return self;
}

- (NSURLConnection *)connection {
  if (nil == _connection) {
    _connection = [[NSURLConnection alloc] initWithRequest:self.request
                                                  delegate:self 
                                          startImmediately:NO];
    
    [_connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
  }
  return _connection;
}

- (void)dealloc {  
}

- (id)process {  
  return [[self class] process:self.response data:self.responseData request:self.request];
}

- (void)start {
  [[self connection] start];
}

- (void)cancel {
  [self.connection cancel];
  
  self.responseData = nil;
  self.connection = nil;
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
    
    [self.queue loader:self failure:error];
    return;
  }
  
  [self.queue loader:self success:self.responseData];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge{
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  if (self.request.cancelled) {
    return;
  }
  self.responseData = nil;
  self.connection = nil;

  [self.queue loader:self failure:error];
}

@end
