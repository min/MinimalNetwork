//
//  MNURLRequestLoader.m
//  MNNetwork
//
//  Created by Min Kim on 6/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MNURLRequest.h"
#import "MNURLRequestQueue.h"
#import "MNURLRequestLoader.h"

@interface MNURLRequestLoader()

@property(nonatomic,readwrite) MNURLRequest      *request;
@property(nonatomic,readwrite) MNURLRequestQueue *queue;
@property(nonatomic,readwrite) NSHTTPURLResponse *response;
@property(nonatomic,readwrite) NSMutableData     *responseData;
@property(nonatomic,readwrite) NSURLConnection   *connection;
@property(nonatomic,assign)    dispatch_queue_t   parse_queue;

- (id)process;

@end

@implementation MNURLRequestLoader

@synthesize request = _request, response = _response, responseData = _responseData;
@synthesize connection = _connection, queue = _queue, parse_queue;

- (id)initWithRequest:(MNURLRequest *)request queue:(MNURLRequestQueue *)queue {
  if (self = [super init]) {
    self.request     = request;
    self.connection  = [NSURLConnection connectionWithRequest:self.request delegate:self];
    self.queue       = queue;
    self.parse_queue = dispatch_queue_create("com.minimal.parse", 0);
  }
  return self;
}

- (void)dealloc {
  dispatch_release(self.parse_queue);
}

- (id)process {
  id data = self.responseData;
  
  if ([[self.response.allHeaderFields objectForKey:@"Content-Type"] rangeOfString:@"json"].location != NSNotFound) {
    Class clazz = NSClassFromString(@"NSJSONSerialization");
    if (nil != clazz) {
      data = [clazz JSONObjectWithData:data options:kNilOptions error:nil];
    }
  }
  
  return data;
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
  if (self.response.statusCode >= 300) {
    NSError *error = [NSError errorWithDomain:NSURLErrorDomain 
                                         code:self.response.statusCode 
                                     userInfo:nil];
    
    [self.queue loader:self failure:error];
    return;
  }
  
  dispatch_async(self.parse_queue, ^{
    id data = [self process];
    
    dispatch_async(dispatch_get_main_queue(), ^{
      [self.queue loader:self success:data];
    });
  });
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge{
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  self.responseData = nil;

  [self.queue loader:self failure:error];
}

@end