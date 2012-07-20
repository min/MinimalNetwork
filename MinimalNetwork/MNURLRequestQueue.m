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

@property(nonatomic,strong) NSMutableArray *loaders;

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
    self.loaders = [NSMutableArray arrayWithCapacity:0];
  }
  return self;
}

- (void)next {
  if (self.loaders && self.loaders.count > 0) {
    MNURLRequestLoader *loader = [self.loaders objectAtIndex:0];
    [loader start];
  }
}

- (void)queue:(MNURLRequest *)request {
  MNURLRequestLoader *loader =
  [[MNURLRequestLoader alloc] initWithRequest:request
                                        queue:self];
  
  [self.loaders addObject:loader];
  NSLog(@"loaders: %@", self.loaders);
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
  
  NSLog(@"loaders: %@", self.loaders);
  
  for (MNURLRequestLoader *loader in self.loaders) {
    if (request == loader.request) {
      [loader cancel];
      [cancelledLoaders addObject:loader];
    }
  }
  
  for (MNURLRequestLoader *loader in cancelledLoaders) {
    [self didFinish:loader];
    MNNetworkRequestFinished();
  }
}

- (void)didFinish:(MNURLRequestLoader *)loader {
  [self.loaders removeObject:loader];
  [self next];
}

- (void)loader:(MNURLRequestLoader *)loader success:(id)data {
  if (loader.request.successBlock) {
    loader.request.successBlock(loader.request, data);
  }
  
  [self didFinish:loader];
}

- (void)loader:(MNURLRequestLoader *)loader failure:(NSError *)error {
  if (loader.request.failureBlock) {
    loader.request.failureBlock(loader.request, error);
  }
  
  [self didFinish:loader];
}

@end
