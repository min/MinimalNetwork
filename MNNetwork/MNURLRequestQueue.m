//
//  MNURLRequestQueue.m
//  MNNetwork
//
//  Created by Min Kim on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MNURLRequestQueue.h"
#import "MNURLRequestLoader.h"

@interface MNURLRequestQueue()

@property(nonatomic,assign) dispatch_semaphore_t request_lock;
@property(nonatomic,assign) dispatch_queue_t     request_queue;
@property(nonatomic,strong) NSMutableArray      *requests;
@property(nonatomic,strong) NSMutableArray      *loaders;

- (void)next;
- (void)load:(MNURLRequest *)request;

@end

@implementation MNURLRequestQueue

@synthesize request_lock, request_queue;
@synthesize requests, loaders;

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
    self.request_lock  = dispatch_semaphore_create(8);
    self.request_queue = dispatch_queue_create(NULL, NULL);
    
    self.requests      = [NSMutableArray arrayWithCapacity:0];
    self.loaders       = [NSMutableArray arrayWithCapacity:0];
  }
  return self;
}

- (void)next {
  if (self.requests && self.requests.count > 0) {
    [self load:[self.requests lastObject]];
  }
}

- (void)load:(MNURLRequest *)request {
  MNURLRequestLoader *loader = 
    [[MNURLRequestLoader alloc] initWithRequest:request 
                                       queue:self];
  
  [self.loaders addObject:loader];
  [self.requests removeObject:request];
}

- (void)queue:(MNURLRequest *)request {
  [self.requests insertObject:request atIndex:0];
  
  dispatch_async(self.request_queue, ^{
    dispatch_semaphore_wait(self.request_lock, DISPATCH_TIME_FOREVER);
    dispatch_async(dispatch_get_main_queue(), ^{
      [self next];
    });
  });
}

- (void)cancelAll {
  [self.requests removeAllObjects];
}

- (void)cancel:(MNURLRequest *)request {
  request.cancelled = YES;
  [self.requests removeObject:request];
}

- (void)didFinish:(MNURLRequestLoader *)loader {
  [self.loaders removeObject:loader];
  dispatch_semaphore_signal(self.request_lock);
}

- (void)loader:(MNURLRequestLoader *)loader success:(id)data {
  loader.request.successBlock(loader.request, data);
  
  [self didFinish:loader];
}

- (void)loader:(MNURLRequestLoader *)loader failure:(NSError *)error {
  loader.request.failureBlock(loader.request, error);
  
  [self didFinish:loader];
}

@end
