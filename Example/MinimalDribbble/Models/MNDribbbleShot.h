//
//  MNDribbbleShot.h
//  MinimalDribbble
//
//  Created by Min Kim on 6/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MNDribbbleShot : NSObject

@property (readonly, strong, nonatomic) NSNumber *id;
@property (readonly, strong, nonatomic) NSString *title;
@property (readonly, strong, nonatomic) NSString *imageUrl;

+ (void)everyone:(void (^)(NSArray *shots))success
         failure:(void (^)(NSError *error))failure;

+ (void)get:(NSNumber *)shotId 
    success:(void (^)(MNDribbbleShot *shots))success 
    failure:(void (^)(NSError *error))failure;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
