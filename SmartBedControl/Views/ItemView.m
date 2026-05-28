//
//  ItemView.m
//  SmartBedControl
//
//  Created by 刘飞 on 2026/4/23.
//

#import "ItemView.h"

@interface ItemView ()
@property (strong, nonatomic) UIView *lineView;
@property (strong, nonatomic) UIImageView *itemImage;
@property (strong, nonatomic) UILabel *itemLabel;
@property (strong, nonatomic) NSString *imageStr;
@end

@implementation ItemView


- (instancetype)initWithFrame:(CGRect)frame withTitle:(NSString *)title withImageName:(NSString *)imageName;
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageStr = imageName;
        self.backgroundColor = [UIColor clearColor];
        self.lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 3, frame.size.height)];
        self.lineView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.lineView];
        
        self.itemImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 14, 14)];
        self.itemImage.center = CGPointMake(frame.size.width/2, frame.size.height/2 - 15);
        NSString *name = [NSString stringWithFormat:@"%@_normal",imageName];
        self.itemImage.image = [UIImage imageNamed:name];
        [self addSubview:self.itemImage];
        
        self.itemLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(self.itemImage.frame) + 10, frame.size.width - 10, 20)];
        self.itemLabel.textColor = [UIColor colorWithValue:@"#374151"];
        self.itemLabel.text = title;
        self.itemLabel.font = [UIFont systemFontOfSize:13.0];
        self.itemLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.itemLabel];
    }
    return self;
}

- (void)setIsSelected:(BOOL)isSelected
{
    NSString *imageName = isSelected == YES ? [NSString stringWithFormat:@"%@_high",self.imageStr] : [NSString stringWithFormat:@"%@_normal",self.imageStr];
    self.itemImage.image = [UIImage imageNamed:imageName];
    if (isSelected) {
        self.lineView.backgroundColor = [UIColor whiteColor];
        self.itemLabel.textColor = [UIColor whiteColor];
        self.backgroundColor = [UIColor colorWithValue:@"#1a1a1a"];
    }else{
        self.lineView.backgroundColor = [UIColor clearColor];
        self.itemLabel.textColor = [UIColor colorWithValue:@"#374151"];
        self.backgroundColor = [UIColor clearColor];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
