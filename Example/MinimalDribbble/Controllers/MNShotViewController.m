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

@synthesize shotId = _shotId;

- (id)initWithShotId:(NSNumber *)shotId {
  if (self = [super init]) {
    self.shotId = shotId;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
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
