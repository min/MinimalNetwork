//
//  MNShotCell.m
//  MinimalDribbble
//
//  Created by Min Kim on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MNShotCell.h"

@interface MNShotCell()

@property (readwrite, nonatomic) UIImageView *thumbnailView;

@end

@implementation MNShotCell

@synthesize thumbnailView = _thumbnailView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
    self.imageView.backgroundColor = [UIColor lightGrayColor];
    self.imageView.hidden = NO;
    self.textLabel.numberOfLines = 0;
    self.textLabel.font = [UIFont systemFontOfSize:14.0f];
    
    self.thumbnailView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f,0.0f,133.0f,100.0f)];
    
    [self.contentView addSubview:self.thumbnailView];
  }
  return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
  self.textLabel.frame = CGRectMake(
                                    self.thumbnailView.bounds.size.width,
                                    0.0f,
                                    self.contentView.bounds.size.width - self.thumbnailView.bounds.size.width - 10.0f,
                                    self.contentView.bounds.size.height
                                    );
}

@end
