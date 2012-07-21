//
//  UIImageView+MinimalNetwork.m
//  MinimalNetwork
//
//  Created by Min Kim on 6/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIImageView+MinimalNetwork.h"
#import <objc/runtime.h>

static char const * const kMNImageURLObjectKey = "MNImageURLObjectKey";

@implementation UIImageView (MinimalNetwork)

@dynamic mn_request;

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

- (void)setMn_request:(MNURLRequest *)request {
  objc_setAssociatedObject(self, kMNImageURLObjectKey, request, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)mn_load:(NSString *)url {
  if (nil == url || ![url isKindOfClass:[NSString class]]) {
    return;
  }
  
  UIImage *image = [[[self class] mn_cache] objectForKey:url];
  if (image && [image isKindOfClass:[UIImage class]]) {
    self.image = image;
    return;
  }
  
  [self.mn_request cancel];
  self.image = nil;
  
  __weak id _self = self;
  
  self.mn_request = MN_GET(url).
    success(^(MNURLRequest *request, UIImage *image) {
      [[[self class] mn_cache] setObject:image forKey:request.URL.absoluteString];
      [_self setImage:image];
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
