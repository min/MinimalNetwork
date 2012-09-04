//
//  UIImageView+MinimalNetwork.m
//  MinimalNetwork
//
//  Created by Min Kim on 6/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIImageView+MinimalNetwork.h"
#import <objc/runtime.h>

static char const *const kMNImageURLObjectKey = "MNImageURLObjectKey";

@interface UIImageView (MinimalNetworkInternal)

@property (nonatomic, readwrite, strong, setter = mn_setRequest:) MNURLRequest *mn_request;

@end

@implementation UIImageView (MinimalNetworkInternal)

@dynamic mn_request;

@end

@implementation UIImageView (MinimalNetwork)

+ (NSCache *)mn_cache {
  static NSCache *kImageCache = nil;
  static dispatch_once_t once_predicate;
  dispatch_once(&once_predicate, ^{
    kImageCache = [[NSCache alloc] init];
  });
  
  return kImageCache;
}

- (MNURLRequest *)mn_request {
  return (MNURLRequest *)objc_getAssociatedObject(self, kMNImageURLObjectKey);
}

- (void)mn_setRequest:(MNURLRequest *)request {
  objc_setAssociatedObject(self, kMNImageURLObjectKey, request, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)mn_load:(NSString *)url {
  [self mn_load:url success:nil];
}

- (void)mn_load:(NSString *)url success:(void (^)(UIImage *image))success {
  if (nil == url || ![url isKindOfClass:[NSString class]]) {
    return;
  }
  self.image = nil;

  [self.mn_request cancel];
  self.mn_request = nil;
  
  UIImage *image = [[[self class] mn_cache] objectForKey:url];
  
  if (image && [image isKindOfClass:[UIImage class]]) {
    self.image = image;
    if (success) {
      success(image);
    }
    return;
  }
  
  self.mn_request = MN_GET(url).
    before(^(MNURLRequest *request) {
      request.parserClass = [MNImageResponseParser class];
      request.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
    }).
    success(^(MNURLRequest *request, UIImage *image) {
      if (image) {
        [[[self class] mn_cache] setObject:image forKey:url];
      }
      self.image = image;
      if (success) {
        success(image);
      }
    }).
    send();
}

- (void)mn_cancel {
  if (self.mn_request) {
    [self.mn_request cancel];
  }
}

- (void)dealloc {
  self.mn_request = nil;
}

@end
