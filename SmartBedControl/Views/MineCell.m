//
//  MineCell.m
//  SmartBedControl
//
//  Created by 刘飞 on 2026/5/7.
//

#import "MineCell.h"

@interface MineCell ()
@property (nonatomic, strong) UIView *iconContainer;
@end

@implementation MineCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.contentView.backgroundColor = [UIColor colorWithValue:@"#111111"];
    self.detailLabel.textColor = [UIColor colorWithValue:@"#6b7280"];
    self.icon.contentMode = UIViewContentModeScaleAspectFit;
    self.icon.tintColor = [UIColor colorWithValue:@"#9ca3af"];
    self.iconContainer = [[UIView alloc] initWithFrame:CGRectZero];
    self.iconContainer.backgroundColor = [UIColor colorWithValue:@"#1a1a1a"];
    self.iconContainer.layer.cornerRadius = 10.0;
    self.iconContainer.layer.masksToBounds = YES;
    [self.contentView insertSubview:self.iconContainer belowSubview:self.icon];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.iconContainer.frame = CGRectMake(20, 13, 40, 40);
    self.icon.frame = CGRectMake(30, 23, 20, 20);
    CGFloat textX = 70;
    CGFloat textW = CGRectGetWidth(self.contentView.bounds) - textX - 18;
    self.titleLabel.frame = CGRectMake(textX, 13, textW, 20);
    self.detailLabel.frame = CGRectMake(textX, 34, textW, 20);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
