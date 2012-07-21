//
//  UIImageView+MinimalNetwork.h
//  MinimalNetwork
//
//  Created by Min Kim on 6/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MinimalNetwork/MNURLRequest.h>

@interface UIImageView (MinimalNetwork)

@property (nonatomic) MNURLRequest *mn_request;

- (void)mn_load:(NSString *)url;
- (void)mn_cancel;

@end
