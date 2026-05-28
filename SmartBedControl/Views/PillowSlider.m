//
//  PillowSlider.m
//  SmartBedControl
//
//  Created by 刘飞 on 2026/5/6.
//

#import "PillowSlider.h"


@interface PillowSlider ()
@property (strong, nonatomic) UILabel *poseLabel;
@property (strong, nonatomic) UISlider *slider;
@property (strong, nonatomic) UILabel *valueLabel;
@end


@implementation PillowSlider


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setupSliderView];
    }
    return self;
}


- (void)setupSliderView
{
    
    NSArray *titleArr = @[@"6",@"7",@"8",@"9",@"10",@"11",@"12"];
    
    self.poseLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 100, 20)];
    self.poseLabel.font = [UIFont systemFontOfSize:12.0];
    self.poseLabel.textColor = [UIColor colorWithValue:@"#9ca3af"];
    self.poseLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:self.poseLabel];
    
    
    self.valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 120, 0, 100, 20)];
    self.valueLabel.font = [UIFont systemFontOfSize:12.0];
    self.valueLabel.textColor = [UIColor whiteColor];
    self.valueLabel.textAlignment = NSTextAlignmentRight;
    //self.valueLabel.text = @"6.0cm";
    self.valueLabel.text = @"0cm";
    [self addSubview:self.valueLabel];
    
    
    UIImage *maxImage = [UIImage imageNamed:@"sliderMax"];
    UIImage *minImage = [UIImage imageNamed:@"pillowSliderMax"];
    
    self.slider = [[UISlider alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(self.poseLabel.frame) + 15, iPhoneWidth - 80, 16)];
    [self.slider setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    [self.slider setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [self.slider setThumbImage:[UIImage imageNamed:@"pillowPoint"] forState:UIControlStateNormal];
    [self.slider addTarget:self action:@selector(levelChanged:) forControlEvents:UIControlEventValueChanged];
    [self.slider addTarget:self action:@selector(levelChangeEnd:) forControlEvents:UIControlEventTouchUpInside];
//    self.slider.minimumValue = 6.0;
//    self.slider.maximumValue = 12.0;
    self.slider.minimumValue = 0;
    self.slider.maximumValue = 100;
    [self addSubview:self.slider];
    
//    float scal = (iPhoneWidth - 94)/6;
//    
//    for (int i = 0; i < titleArr.count; i++) {
//        UIView *point = [[UIView alloc] init];
//        point.frame = CGRectMake(i%7*(scal+2) + 20, CGRectGetMaxY(self.slider.frame) + 10, 2, 4);
//        point.backgroundColor = [UIColor colorWithValue:@"#3f3f46"];
//        [self addSubview:point];
//        
//        UILabel *numberLabel = [[UILabel alloc] init];
//        numberLabel.frame = CGRectMake(CGRectGetMinX(point.frame) - 8, CGRectGetMaxY(point.frame), 20, 20);
//        numberLabel.font = [UIFont systemFontOfSize:12.0];
//        numberLabel.textAlignment = NSTextAlignmentCenter;
//        numberLabel.textColor = [UIColor colorWithValue:@"#3f3f46"];
//        numberLabel.text = titleArr[i];
//        [self addSubview:numberLabel];
//    }
}

- (void)setValue:(int)value
{
    self.slider.value = value;
}

- (void)setTitle:(NSString *)title
{
    self.poseLabel.text = title;
}


- (void)levelChanged:(UISlider *)slider
{
//    float number = slider.value;
//    self.valueLabel.text = [NSString stringWithFormat:@"%.1fcm",number];
    int number = slider.value;
    self.valueLabel.text = [NSString stringWithFormat:@"%dcm",number];
}

- (void)levelChangeEnd:(UISlider *)slider
{
    int number = slider.value;
    
    if ([_delegate respondsToSelector:@selector(pillowSlider:pressureValue:)]) {
        [_delegate pillowSlider:self pressureValue:number];
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
