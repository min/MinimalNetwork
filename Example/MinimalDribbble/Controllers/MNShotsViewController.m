//
//  MNShotsViewController.m
//  MinimalDribbble
//
//  Created by Min Kim on 6/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MNShotsViewController.h"
#import "MNShotViewController.h"
#import "MNDribbbleShot.h"

@interface MNShotsViewController ()

@property (readwrite, strong, nonatomic) NSArray *shots;

@end

@implementation MNShotsViewController

@synthesize shots = _shots;

- (void)viewDidLoad {
  [super viewDidLoad];
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
    
  [MNDribbbleShot everyone:^(NSArray *shots) {
    self.shots = shots;
    [self.tableView reloadData];
  }
  failure:^(NSError *error) {
                     
  }];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (self.shots) {
    return self.shots.count;
  }
  return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"CellIdentifier";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
  }
  
  MNDribbbleShot *shot = [self.shots objectAtIndex:indexPath.row];
  
  cell.textLabel.text = shot.title;
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  MNDribbbleShot *shot = [self.shots objectAtIndex:indexPath.row];
  
  MNShotViewController *controller = [[MNShotViewController alloc] initWithShotId:shot.id];
  [self.navigationController pushViewController:controller animated:YES];
}

@end
