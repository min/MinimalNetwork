//
//  MNURLRequestQueue.h
//  MNNetwork
//
//  Created by Min Kim on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MNURLRequest.h"
#import "MNURLRequestLoader.h"

@interface MNURLRequestQueue : NSObject {
  
}

@property(nonatomic) dispatch_queue_t parse_queue;

+ (MNURLRequestQueue *)mainQueue;

- (void)queue:(MNURLRequest *)request;
- (void)cancel:(MNURLRequest *)request;

- (void)loaded:(MNURLRequestLoader *)loader;

@end
