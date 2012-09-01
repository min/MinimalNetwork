//
//  MNDribbbleShot.m
//  MinimalDribbble
//
//  Created by Min Kim on 6/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MNDribbbleShot.h"

@interface MNDribbbleShot()

@property (readwrite, strong, nonatomic) NSNumber *id;
@property (readwrite, strong, nonatomic) NSString *title;
@property (readwrite, strong, nonatomic) NSString *imageUrl;

@end

@implementation MNDribbbleShot

@synthesize title, id, imageUrl;

- (id)initWithDictionary:(NSDictionary *)dictionary {
  if ((self = [super init])) {
    self.id       = [dictionary valueForKey:@"id"];
    self.title    = [dictionary valueForKey:@"title"];
    self.imageUrl = [dictionary valueForKey:@"image_teaser_url"];
  }
  return self;
}

+ (void)everyone:(void (^)(NSArray *shots))success
         failure:(void (^)(NSError *error))failure {
  
  MN_GET(@"http://api.dribbble.com/shots/everyone?per_page=30").
    success(^(MNURLRequest *request, id data){
      NSArray *dictionaries = [data valueForKey:@"shots"];
      NSMutableArray *shots = [[NSMutableArray alloc] initWithCapacity:0];
      
      for (NSDictionary *dictionary in dictionaries) {
        [shots addObject:[[MNDribbbleShot alloc] initWithDictionary:dictionary]];
      }
      success(shots);
    }).
    failure(^(MNURLRequest *request, NSError *error){
      failure(error);
    }).
    send();
}

+ (void)get:(NSNumber *)shotId 
    success:(void (^)(MNDribbbleShot *shots))success 
    failure:(void (^)(NSError *error))failure {
  
  MN_GET(@"http://api.dribbble.com/shots/%@", shotId).
    success(^(MNURLRequest *request, id data){
      success([[MNDribbbleShot alloc] initWithDictionary:data]);
    }).
    failure(^(MNURLRequest *request, NSError *error){
      failure(error);
    }).
    send();
}

@end
