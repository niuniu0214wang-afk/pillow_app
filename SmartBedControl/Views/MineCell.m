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
    self.titleLabel.font = [UIFont systemFontOfSize:15.0 weight:UIFontWeightMedium];
    self.detailLabel.font = [UIFont systemFontOfSize:12.0];
    self.detailLabel.textColor = [UIColor colorWithValue:@"#6b7280"];
    self.icon.contentMode = UIViewContentModeScaleAspectFit;
    self.icon.tintColor = [UIColor colorWithValue:@"#9ca3af"];
    self.iconContainer = [[UIView alloc] initWithFrame:CGRectZero];
    self.iconContainer.backgroundColor = [UIColor colorWithValue:@"#1a1a1a"];
    self.iconContainer.layer.cornerRadius = 9.0;
    self.iconContainer.layer.masksToBounds = YES;
    [self.contentView insertSubview:self.iconContainer belowSubview:self.icon];

    // The XIB pins the old larger frames with Auto Layout constraints.
    // Remove those constraints so the manual sizing in layoutSubviews takes effect.
    NSMutableArray<NSLayoutConstraint *> *constraintsToRemove = [NSMutableArray array];
    for (NSLayoutConstraint *constraint in self.contentView.constraints) {
        id firstItem = constraint.firstItem;
        id secondItem = constraint.secondItem;
        BOOL affectsIconLayout =
            firstItem == self.icon || secondItem == self.icon ||
            firstItem == self.titleLabel || secondItem == self.titleLabel ||
            firstItem == self.detailLabel || secondItem == self.detailLabel;
        if (affectsIconLayout) {
            [constraintsToRemove addObject:constraint];
        }
    }
    [self.contentView removeConstraints:constraintsToRemove];
    self.icon.translatesAutoresizingMaskIntoConstraints = YES;
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = YES;
    self.detailLabel.translatesAutoresizingMaskIntoConstraints = YES;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat containerSize = self.prefersLargeIcon ? 40.0 : 36.0;
    CGFloat iconSize = self.prefersLargeIcon ? 20.0 : 18.0;
    CGFloat containerY = self.prefersLargeIcon ? 13.0 : 15.0;
    CGFloat iconX = 20.0 + (containerSize - iconSize) / 2.0;
    CGFloat iconY = containerY + (containerSize - iconSize) / 2.0;
    self.iconContainer.frame = CGRectMake(20, containerY, containerSize, containerSize);
    self.icon.frame = CGRectMake(iconX, iconY, iconSize, iconSize);
    CGFloat textX = self.prefersLargeIcon ? 70.0 : 68.0;
    CGFloat textW = CGRectGetWidth(self.contentView.bounds) - textX - 18;
    self.titleLabel.frame = CGRectMake(textX, 14, textW, 20);
    self.detailLabel.frame = CGRectMake(textX, 34, textW, 18);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
