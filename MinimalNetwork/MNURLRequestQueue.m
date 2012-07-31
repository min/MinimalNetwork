//
//  MNURLRequestQueue.m
//  MNNetwork
//
//  Created by Min Kim on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MNURLRequestQueue.h"
#import "MNURLRequestLoader.h"
#import <UIKit/UIKit.h>

@interface MNURLRequestQueue()

@property(nonatomic,strong) NSMutableArray  *loaders;
@property(nonatomic)        dispatch_queue_t parse_queue;

- (void)next;

@end

@implementation MNURLRequestQueue

@synthesize loaders = _loaders;

+ (MNURLRequestQueue *)mainQueue {
  static dispatch_once_t network_predicate;
  static MNURLRequestQueue *kMainQueue = nil;
  dispatch_once(&network_predicate, ^{
    kMainQueue = [[MNURLRequestQueue alloc] init];
  });
  return kMainQueue;
}

- (id)init {
  if (self = [super init]) {
    self.loaders     = [NSMutableArray arrayWithCapacity:0];
    self.parse_queue = dispatch_queue_create("com.minimal.parse", 0);
  }
  return self;
}

- (void)dealloc {
  dispatch_release(self.parse_queue);
}

- (void)next {
  if (self.loaders && self.loaders.count > 0) {
    MNURLRequestLoader *loader = [self.loaders objectAtIndex:0];
    
    if ([loader.request.URL.scheme isEqualToString:@"bundle"]) {
      NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:loader.request.URL.host];

      if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [self loader:loader success:[NSData dataWithContentsOfFile:path]];
      } else {
        NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                             code:NSFileReadNoSuchFileError
                                         userInfo:nil];
        [self loader:loader failure:error];
      }
      return;
    }
    [loader start];
  }
}

- (void)queue:(MNURLRequest *)request {
  MNURLRequestLoader *loader =
  [[MNURLRequestLoader alloc] initWithRequest:request
                                        queue:self];
  
  if (self.loaders.count == 0) {
    MNNetworkRequestStarted();
  }
  [self.loaders addObject:loader];
  
  if (self.loaders.count <= 10) {
    [self next];
  }
}

- (void)cancelAll {
  [self.loaders removeAllObjects];
}

- (void)cancel:(MNURLRequest *)request {
  request.cancelled = YES;
  
  NSMutableArray *cancelledLoaders = [NSMutableArray arrayWithCapacity:0];
  
  for (MNURLRequestLoader *loader in self.loaders) {
    if (request == loader.request) {
      [loader cancel];
      [cancelledLoaders addObject:loader];
    }
  }
  
  for (MNURLRequestLoader *loader in cancelledLoaders) {
    [self didFinish:loader];
  }
}

- (void)didFinish:(MNURLRequestLoader *)loader {
  [self.loaders removeObject:loader];
  if (self.loaders.count == 0) {
    MNNetworkRequestFinished();
  }
  [self next];
}

- (void)loader:(MNURLRequestLoader *)loader success:(id)data {
  [self didFinish:loader];
  
  __block id parsedData = data;
  
  dispatch_async(self.parse_queue, ^{
    parsedData = [MNURLRequestLoader process:loader.response data:parsedData request:loader.request];
    
    if (loader.request.parseBlock) {
      parsedData = loader.request.parseBlock(parsedData);
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
      if (loader.request.successBlock) {
        loader.request.successBlock(loader.request, parsedData);
      }
    });
  });
}

- (void)loader:(MNURLRequestLoader *)loader failure:(NSError *)error {
  if (loader.request.failureBlock) {
    loader.request.failureBlock(loader.request, error);
  }
  
  [self didFinish:loader];
}

@end
