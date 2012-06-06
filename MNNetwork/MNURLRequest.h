//
//  MNURLRequest.h
//  MNNetwork
//
//  Created by Min Kim on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

typedef void (^MNRequestSuccessBlock)(id request, id data);
typedef void (^MNRequestFailureBlock)(id request, NSError *error);
typedef void (^MNRequessBlock)(id request);

@interface MNURLRequest : NSMutableURLRequest

@property(nonatomic,readonly) NSMutableDictionary  *parameters;
@property(nonatomic,copy)     MNRequestSuccessBlock successBlock;
@property(nonatomic,copy)     MNRequestFailureBlock failureBlock;
@property(nonatomic)          BOOL                  cancelled;

@property(readonly) MNURLRequest *(^success)(MNRequestSuccessBlock block);
@property(readonly) MNURLRequest *(^failure)(MNRequestFailureBlock block);
@property(readonly) MNURLRequest *(^send)();

+ (MNURLRequest *)get:(NSString *)URLString;

+ (void)get:(NSURL *)URL 
     before:(MNRequessBlock)before
    success:(MNRequestSuccessBlock)success
    failure:(MNRequestFailureBlock)failure;

+ (void)post:(NSURL *)URL 
      before:(MNRequessBlock)before
     success:(MNRequestSuccessBlock)success
     failure:(MNRequestFailureBlock)failure;

@end
