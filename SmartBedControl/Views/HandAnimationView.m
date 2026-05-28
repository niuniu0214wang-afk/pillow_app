//
//  HandAnimationView.m
//  SmartBedControl
//
//  Created by 刘飞 on 2026/5/17.
//

#import "HandAnimationView.h"

@interface HandAnimationView ()
@property (strong, nonatomic) NSArray *animationArr;
@property (strong, nonatomic) UIView *upView;
@property (strong, nonatomic) UIView *downView;
@property (assign, nonatomic) BedMode mode;
@end

@implementation HandAnimationView

- (instancetype)initWithFrame:(CGRect)frame withBedMode:(BedMode)mode
{
    self = [super initWithFrame:frame];
    if (self) {
        _mode = mode;
        self.backgroundColor = [UIColor clearColor];
        _animationArr = @[[UIImage imageNamed:@"arow1"],[UIImage imageNamed:@"arow2"]];
        [self creatViews];
    }
    return self;
}

- (void)creatViews
{
    
//    _upView = [[UIView alloc] initWithFrame:self.bounds];
//    [self addSubview:_upView];
//    
//    for (int i = 0; i < 5; i++) {
//        UIImageView *arrawImage = [[UIImageView alloc] init];
//        arrawImage.transform = CGAffineTransformMakeRotation(M_PI);
//        arrawImage.frame = CGRectMake(iPhoneWidth/2 - 95 + i%6*(24 + 2), 0, 30, 24);
//        arrawImage.animationImages = _animationArr;
//        arrawImage.animationDuration = 0.8;
//        [_upView addSubview:arrawImage];
//        [arrawImage startAnimating];
//    }
    
    
    _downView = [[UIView alloc] initWithFrame:self.bounds];
    _downView.backgroundColor = [UIColor clearColor];
    [self addSubview:_downView];
    
    CGFloat viewW = CGRectGetWidth(self.bounds);
    for (int i = 0; i < 6; i++) {
        UIImageView *arrawImage = [[UIImageView alloc] init];
        arrawImage.frame = CGRectMake(viewW/2 - 95 + i%6*(24 + 2), 0, 30, 24);
        arrawImage.animationImages = _animationArr;
        arrawImage.animationDuration = 0.8;
        [_downView addSubview:arrawImage];
        arrawImage.tag = 66+i;
        //[arrawImage startAnimating];
    }
}

- (void)didAnimationUp:(BOOL)isUp bodyPart:(int)part
{
//    _downView.hidden = isUp;
//    _upView.hidden = !isUp;
    
    if (part < 6) {
        UIImageView *imageView = (UIImageView *)[self viewWithTag:66+part];
        if (isUp) {
            imageView.transform = CGAffineTransformMakeRotation(M_PI);
        }
        imageView.hidden = NO;
        [imageView startAnimating];
    }else{
        for (int i = 0; i < 6; i++) {
            UIImageView *imageView = (UIImageView *)[self viewWithTag:66+i];
            if (isUp) {
                imageView.transform = CGAffineTransformMakeRotation(M_PI);
            }
            imageView.hidden = NO;
            [imageView startAnimating];
        }
    }
}

- (void)stopAniMation
{
    for (int i = 0; i < 6; i++) {
        UIImageView *imageView = (UIImageView *)[self viewWithTag:66+i];

        imageView.hidden = YES;
        [imageView stopAnimating];
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
