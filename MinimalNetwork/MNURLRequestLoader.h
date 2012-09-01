//
//  MNURLRequestLoader.h
//  MNNetwork
//
//  Created by Min Kim on 6/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

@class MNURLRequest;

@interface MNURLRequestLoader : NSObject

@property(nonatomic,readonly) MNURLRequest *request;

- (id)initWithRequest:(MNURLRequest *)request;
- (void)start;
- (void)cancel;

@end
