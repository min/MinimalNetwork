//
//  MNURLRequestLoader.h
//  MNNetwork
//
//  Created by Min Kim on 6/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

@class MNURLRequest;
@class MNURLRequestQueue;

@interface MNURLRequestLoader : NSObject


@property(nonatomic,readonly) MNURLRequest      *request;
@property(nonatomic,readonly) MNURLRequestQueue *queue;
@property(nonatomic,readonly) NSHTTPURLResponse *response;
@property(nonatomic,readonly) NSMutableData     *responseData;
@property(nonatomic,readonly) NSURLConnection   *connection;

- (id)initWithRequest:(MNURLRequest *)request queue:(MNURLRequestQueue *)queue;

@end
