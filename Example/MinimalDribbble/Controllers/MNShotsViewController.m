//
//  MNShotsViewController.m
//  MinimalDribbble
//
//  Created by Min Kim on 6/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MNShotsViewController.h"
#import "MNShotViewController.h"
#import "MNShotCell.h"
#import "MNDribbbleShot.h"

@interface MNShotsViewController ()

@property (readwrite, strong, nonatomic) NSArray *shots;

- (void)reload;

@end

@implementation MNShotsViewController

@synthesize shots = _shots;

- (void)reload {

    [MNDribbbleShot everyone:^(NSArray *shots) {
      self.shots = shots;
      [self.tableView reloadData];
    }
   failure:^(NSError *error) {
   }];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.tableView.rowHeight = 100.0f;
  self.navigationItem.rightBarButtonItem = 
  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh 
                                                target:self 
                                                action:@selector(reload)];
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self reload];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (self.shots) {
    return self.shots.count;
  }
  return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"CellIdentifier";
  
  MNShotCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  
  if (cell == nil) {
    cell = [[MNShotCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
  }
  
  MNDribbbleShot *shot = [self.shots objectAtIndex:indexPath.row];
  
  [cell.textLabel setText:shot.title];
  [cell.thumbnailView mn_load:shot.imageUrl];
  [cell setNeedsLayout];
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  MNDribbbleShot *shot = [self.shots objectAtIndex:indexPath.row];
  
  MNShotViewController *controller = [[MNShotViewController alloc] initWithShotId:shot.id];
  [self.navigationController pushViewController:controller animated:YES];
}

@end
