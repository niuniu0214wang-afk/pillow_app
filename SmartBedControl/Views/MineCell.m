//
//  MineCell.m
//  SmartBedControl
//
//  Created by 刘飞 on 2026/5/7.
//

#import "MineCell.h"

@implementation MineCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.contentView.backgroundColor = [UIColor colorWithValue:@"#111111"];
    self.detailLabel.textColor = [UIColor colorWithValue:@"#6b7280"];
    self.icon.contentMode = UIViewContentModeScaleAspectFit;
    self.icon.tintColor = [UIColor colorWithValue:@"#9ca3af"];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.icon.frame = CGRectMake(22, 19, 28, 28);
    CGFloat textX = CGRectGetMaxX(self.icon.frame) + 16;
    CGFloat textW = CGRectGetWidth(self.contentView.bounds) - textX - 18;
    self.titleLabel.frame = CGRectMake(textX, 13, textW, 20);
    self.detailLabel.frame = CGRectMake(textX, 34, textW, 20);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
