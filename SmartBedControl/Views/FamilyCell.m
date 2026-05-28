//
//  FamilyCell.m
//  SmartBedControl
//
//  Created by 刘飞 on 2026/5/7.
//

#import "FamilyCell.h"

@implementation FamilyCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.contentView.backgroundColor = [UIColor colorWithValue:@"#111111"];
    self.detailLabel.textColor = [UIColor colorWithValue:@"#6b7280"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
