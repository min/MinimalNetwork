//
//  MNURLRequest.h
//  MNNetwork
//
//  Created by Min Kim on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

void MNNetworkRequestStarted(void);
void MNNetworkRequestFinished(void);

@interface NSMutableArray(MNURLRequestAdditions)

- (id)mn_dequeue;
- (id)mn_enqueue:(id)object;

@end

@interface NSString(MNURLRequestAdditions)

- (NSString *)mn_escape;
- (NSDictionary *)mn_queryParameters;

@end

@interface NSDictionary(MNURLRequestAdditions)

- (NSString *)mn_queryString;

@end

#define MN_GET(path, ...) [MNURLRequest get:[NSString stringWithFormat:path, ##__VA_ARGS__]]
#define MN_POST(path, ...) [MNURLRequest post:[NSString stringWithFormat:path, ##__VA_ARGS__]]

typedef void (^MNRequestSuccessBlock)(id request, id data);
typedef void (^MNRequestFailureBlock)(id request, NSError *error);
typedef id   (^MNRequestParseBlock)(NSData *data);
typedef void (^MNRequestBlock)(id request);


@interface MNURLRequest : NSMutableURLRequest

@property(nonatomic,readonly) NSMutableDictionary  *parameters;
@property(nonatomic,copy)     MNRequestSuccessBlock successBlock;
@property(nonatomic,copy)     MNRequestFailureBlock failureBlock;
@property(nonatomic,copy)     MNRequestBlock        beforeBlock;
@property(nonatomic,copy)     MNRequestParseBlock   parseBlock;
@property(nonatomic)          BOOL                  cancelled;

@property(readonly) MNURLRequest *(^success)(MNRequestSuccessBlock block);
@property(readonly) MNURLRequest *(^failure)(MNRequestFailureBlock block);
@property(readonly) MNURLRequest *(^before)(MNRequestBlock block);
@property(readonly) MNURLRequest *(^parse)(MNRequestParseBlock block);
@property(readonly) MNURLRequest *(^send)();

+ (MNURLRequest *)get:(NSString *)URLString;
+ (MNURLRequest *)post:(NSString *)URLString;

- (void)cancel;

@end
