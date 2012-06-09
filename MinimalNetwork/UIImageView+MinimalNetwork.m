//
//  UIImageView+MinimalNetwork.m
//  MinimalNetwork
//
//  Created by Min Kim on 6/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIImageView+MinimalNetwork.h"
#import <objc/runtime.h>

static char kMNImageURLObjectKey;

@interface UIImageView (_MinimalNetwork)

@property (readwrite, nonatomic, retain, setter = mn_setRequest:) MNURLRequest *mn_request;

@end

@implementation UIImageView (_MinimalNetwork)

@dynamic mn_request;

@end

@implementation UIImageView (MinimalNetwork)

- (MNURLRequest *)mn_request {
  return (MNURLRequest *)objc_getAssociatedObject(self, &kMNImageURLObjectKey);
}

- (void)mn_setRequest:(MNURLRequest *)request {
  objc_setAssociatedObject(self, &kMNImageURLObjectKey, request, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)load:(NSString *)url {
  if (nil == url || ![url isKindOfClass:[NSString class]]) {
    return;
  }
  
  [self.mn_request cancel];
  self.image = nil;
  
  __weak id _self = self;
  
  self.mn_request = GET(url).
    success(^(MNURLRequest *request, UIImage *image){
      [_self setImage:image];
    }).
    send();
}

- (void)cancel {
  if (self.mn_request) {
    [self.mn_request cancel];
  }
}

- (void)dealloc {
  self.mn_request = nil;
}

@end
