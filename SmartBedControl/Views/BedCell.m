//
//  BedCell.m
//  SmartBedControl
//
//  Created by 刘飞 on 2026/3/2.
//

#import "BedCell.h"

@implementation BedCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.boomView.backgroundColor = [UIColor colorWithValue:@"#18181b"];
    self.boomView.layer.cornerRadius = 18.0;
    self.boomView.layer.masksToBounds = YES;
    
    self.topView.backgroundColor = [UIColor colorWithValue:@"#161616"];
    self.topView.layer.cornerRadius = 12.0;
    self.topView.layer.masksToBounds = YES;
    
    self.bedMode.textColor = [UIColor colorWithValue:@"#6b7280"];
    
    
}

@end
