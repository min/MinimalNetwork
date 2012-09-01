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
  if (self.loaders.count > 0) {

    MNURLRequestLoader *loader = [self.loaders objectAtIndex:0];
    
    [loader start];
  }
}

- (void)queue:(MNURLRequest *)request {
  MNURLRequestLoader *loader = [[MNURLRequestLoader alloc] initWithRequest:request];
  
  if (self.loaders.count == 0) {
    MNNetworkRequestStarted();
  }
  [self.loaders addObject:loader];
  
  if (self.loaders.count <= 10) {
    [loader start];
  }
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
    [self loaded:loader];
  }
  cancelledLoaders = nil;
}

- (void)loaded:(MNURLRequestLoader *)loader {
  [self.loaders removeObject:loader];
  if (self.loaders.count == 0) {
    MNNetworkRequestFinished();
  }
  [self next];
}

@end
