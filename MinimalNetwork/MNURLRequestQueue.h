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

+ (MNURLRequestQueue *)mainQueue;

- (void)queue:(MNURLRequest *)request;
- (void)cancel:(MNURLRequest *)request;

- (void)loader:(MNURLRequestLoader *)loader success:(id)data;
- (void)loader:(MNURLRequestLoader *)loader failure:(NSError *)error;

@end
