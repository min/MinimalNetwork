//
//  MNShotViewController.h
//  MinimalDribbble
//
//  Created by Min Kim on 6/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MNViewController.h"

@interface MNShotViewController : MNViewController

@property (strong, nonatomic) NSNumber    *shotId;
@property (strong, nonatomic) UIImageView *imageView;

- (id)initWithShotId:(NSNumber *)shotId;

@end
