//
//  DeviceCell.m
//  SmartBedControl
//
//  Created by 刘飞 on 2026/3/3.
//

#import "DeviceCell.h"

@implementation DeviceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.rssiLabel.textColor = [UIColor colorWithValue:@"#6b7280"];
    self.line.backgroundColor = [UIColor colorWithValue:@"#18181b"];
    self.contentView.backgroundColor = [UIColor colorWithValue:@"#111111"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
