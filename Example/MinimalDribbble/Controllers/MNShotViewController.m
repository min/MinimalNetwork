//
//  MNShotViewController.m
//  MinimalDribbble
//
//  Created by Min Kim on 6/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MNShotViewController.h"
#import "MNDribbbleShot.h"

@interface MNShotViewController ()

@end

@implementation MNShotViewController

@synthesize shotId = _shotId, imageView = _imageView;

- (id)initWithShotId:(NSNumber *)shotId {
  if (self = [super init]) {
    self.shotId = shotId;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.view.backgroundColor = [UIColor whiteColor];
  self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0f,10.0f,300.0f,240.0f)];  
  [self.view addSubview:self.imageView];
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [MNDribbbleShot get:self.shotId 
              success:^(MNDribbbleShot *shot) {
              }
              failure:^(NSError *error) {
                
              }];
}

@end
