//
//  CYCircularSlider.m
//  CYCircularSlider
//
//  Created by user on 2018/3/23.
//  Copyright © 2018年 com. All rights reserved.
//

#import "CYCircularSlider.h"

#define ToRad(deg)         ( (M_PI * (deg)) / 180.0 )
#define ToDeg(rad)        ( (180.0 * (rad)) / M_PI )
#define SQR(x)            ( (x) * (x) )
@implementation CYCircularSlider{
    int _angle;
    CGFloat radius;
    int _fixedAngle;
    
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        CGPoint center = CGPointMake(frame.size.width/2, frame.size.height/2);
        
        _maximumValue = 300.0f;
        _minimumValue = 0.0f;
        //_currentValue = 0.0f;
        _lineWidth = 12.0;//圆环线宽
        if ([[UIDevice currentDevice].name containsString:@"iPad"]) {
            _lineWidth = 15.0;
        }
        _unfilledColor = [UIColor colorWithValue:@"#89cc56"];
        _filledColor = [UIColor colorWithValue:@"#e95d4f"];
        _handleColor = [UIColor whiteColor];
        radius = self.frame.size.height/2 - _lineWidth/2;//半径
        _angle = 240;
        
        CGFloat perAngle = 5*M_PI/150;

        for (int i = 0; i < 42; i++) {
            CGFloat starAngle = 5*M_PI/6 + perAngle*i;
            CGFloat endAngle = starAngle + perAngle/5;

            UIBezierPath *tickPath = [UIBezierPath bezierPathWithArcCenter:center radius:radius + 15 startAngle:starAngle endAngle:endAngle clockwise:YES];
            CAShapeLayer *perLayer = [CAShapeLayer layer];
            perLayer.strokeColor = [UIColor colorWithValue:@"#ff87c6"].CGColor;
                        perLayer.lineWidth   = 8;

            perLayer.path = tickPath.CGPath;
            [self.layer addSublayer:perLayer];
        }
    }
    return  self;
}

- (void)setMaximumValue:(float)maximumValue
{
    _maximumValue = maximumValue;
}

- (void)setMinimumValue:(float)minimumValue
{
    _minimumValue = minimumValue;
}

- (void)setCurrentValue:(float)currentValue
{
    _currentValue = currentValue;
}


#pragma mark 画圆
-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    
    //外圆
    NSLog(@"nagel is angel is %d",_angle);
    //画固定的下层圆
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2, radius, M_PI/180*150, M_PI/180*390, 0);
    [_unfilledColor setStroke];
    CGContextSetLineWidth(ctx, _lineWidth);
    CGContextSetLineCap(ctx, kCGLineCapSquare);
    CGContextDrawPath(ctx, kCGPathStroke);
    
    CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2, radius, M_PI/180*150, M_PI/180*(_angle), 0);
   //画可滑动的上层圆
    [_filledColor setStroke];
    CGContextSetLineWidth(ctx, _lineWidth);
    CGContextSetLineCap(ctx, kCGLineCapSquare);
    CGContextDrawPath(ctx, kCGPathStroke);
    
    /*
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat colors[] = {0.56,0.93,0.56,1,1,0.64,0,1,1,0,0,1};
        //locations代表3个颜色的分布区域（0~1），如果需要均匀分布只需要传入NULL
        CGFloat locations[3]={0.35,0.7,1};
        
        CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, 3);
    
    //绘制色彩空间
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    NSArray *colors = @[(id)[[UIColor colorWithValue:@"#7FFF00"] CGColor],
//                        (id)[[UIColor colorWithValue:@"#EEEE00"] CGColor],
//                        (id)[[UIColor colorWithValue:@"#FFEC8B"] CGColor],
//                        (id)[[UIColor colorWithValue:@"#FF6347"] CGColor]];
//    NSArray *locations = @[@(0.25),@(0.5),@(0.75)];
//    CGFloat locations[3] = {0.25,0.5,0.75};
//
//    //CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colors, (const CGFloat *)locations);
//    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, <#const CGFloat * _Nullable components#>, <#const CGFloat * _Nullable locations#>, <#size_t count#>)
    CGColorSpaceRelease(colorSpace);
    colorSpace = NULL;
    
    CGContextReplacePathWithStrokedPath(ctx);
        // 剪裁路径
        CGContextClip(ctx);
        // 4. 用渐变色填充
        CGContextDrawLinearGradient(ctx, gradient, CGPointMake(0, self.frame.size.height / 2), CGPointMake(self.frame.size.width, self.frame.size.height / 2), 0);
        // 释放渐变色
        CGGradientRelease(gradient);
    */
    [self drawHandle:ctx];
    
}

#pragma mark 画按钮
-(void)drawHandle:(CGContextRef)ctx{
    CGContextSaveGState(ctx);
    CGPoint handleCenter =  [self pointFromAngle: _angle];
//    [_handleColor set];
//    CGContextFillEllipseInRect(ctx, CGRectMake(handleCenter.x-2.5, handleCenter.y-2.5, 25, 25));
    UIImage *point = [UIImage imageNamed:@"whitePoint"];
    [point drawInRect:CGRectMake(handleCenter.x-10, handleCenter.y-10, 39, 39)];
    //CGContextDrawTiledImage(ctx, CGRectMake(handleCenter.x-7.5, handleCenter.y-7.5, 39, 39), point.CGImage);
    CGContextRestoreGState(ctx);
    
    
}

-(CGPoint)pointFromAngle:(int)angleInt{
    
    //Define the Circle center
    CGPoint centerPoint = CGPointMake(self.frame.size.width/2 - _lineWidth/2, self.frame.size.height/2 - _lineWidth/2);
    //Define The point position on the circumference
    CGPoint result;
    
    result.y = round(centerPoint.y + radius * sin(ToRad(angleInt))) ;
    result.x = round(centerPoint.x + radius * cos(ToRad(angleInt)));
    return result;
}

-(BOOL) beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super beginTrackingWithTouch:touch withEvent:event];
    
    return YES;
}

-(BOOL) continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super continueTrackingWithTouch:touch withEvent:event];
    
    CGPoint lastPoint = [touch locationInView:self];
    
    //用于排除点在圆外面点与圆心半径80以内的点
    if ((lastPoint.x>=0&&lastPoint.x<=self.bounds.size.width)&&(lastPoint.y>=0 && lastPoint.y<=self.bounds.size.height)) {

        if ((lastPoint.x<=50 ||lastPoint.x>=self.bounds.size.width - 50)||(lastPoint.y<=50 ||lastPoint.y>=self.bounds.size.width - 50)) {
            [self moveHandle:lastPoint];
        }
    }
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    return YES;
}




-(void)moveHandle:(CGPoint)point {
    CGPoint centerPoint = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    int currentAngle = floor(AngleFromNorth(centerPoint, point, NO));
    //NSLog(@"当前角度是------%d",currentAngle);
//    if (currentAngle >= 0 && currentAngle <= 60) {
//        _angle = 360 - currentAngle;
//    }
//
//
//    if (currentAngle>0 && currentAngle <180) {
//
//    }else{
//        if (currentAngle<=0) {
//            _angle = currentAngle+360;
//        }else{
//            _angle = currentAngle;
//        }
//
//    }
    if (currentAngle > 60  && currentAngle < 120) {
        
    }else{
        _angle = currentAngle;
    }
    
    
    //NSLog(@"获取到的angle is %d",_angle);
    _currentValue =[self valueFromAngle];
    [self setNeedsDisplay];
}

static inline float AngleFromNorth(CGPoint p1, CGPoint p2, BOOL flipped) {
    CGPoint v = CGPointMake(p2.x-p1.x,p2.y-p1.y);
    float vmag = sqrt(SQR(v.x) + SQR(v.y)), result = 0;
    v.x /= vmag;
    v.y /= vmag;
    double radians = atan2(v.y,v.x);
    result = ToDeg(radians);
    return (result >=0  ? result : result + 360.0);
}

//在这个地方调整进度条
-(float) valueFromAngle {
    
//    NSLog(@"_angle is %d",_angle);
//    if(_angle <= 180) {
//        _currentValue = 16;
//    } else if(_angle>180 && _angle < 360){
//        _currentValue = 16 + (_angle - 180)/(_maximumValue - _minimumValue);
//    }else{
//        _currentValue = 30;
//    }
    
    
    
    if (_angle >= 120 && _angle <= 360) {
        _currentValue = _angle - 120;
    }else if (_angle >=0 && _angle <= 60) {
        _currentValue = 240 + _angle;
    }
    _fixedAngle = _currentValue;
    return _currentValue;
}

-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super endTrackingWithTouch:touch withEvent:event];
    //[self.delegate senderVlueWithNum:(int8_t)roundf(_currentValue)];
    [self.delegate senderAngel:_angle];
}

#pragma mark - 设定类型
- (void)setCircleType:(CircleType)circleType
{
    NSLog(@"设置类型-----%ld",circleType);
    _circleType = circleType;
}


#pragma mark 设置进度条位置
-(void)setAngel:(int)num{
    //先关闭NSLog(@"当前温度是----------%d",num);
    num = 2.4*num;
    if (_circleType == CIRCLE_OTHER) {
        //NSLog(@"这也能进来？---- %ld",_circleType);
    }
    
    
    if (_circleType == CIRCLE_INTER) {
        //NSLog(@"内环进来了---- %ld",_circleType);
//        if (num >= 0 && num <= 64) {
//            _angle = num*60/17 + 120;
//        }else if (num > 64 && num <= 85) {
//            _angle = num*60/17 - 240;
//        }
        _angle = num + 150;
        
    }
    
    if (_circleType == CIRCLE_OUTER) {
        //NSLog(@"外环进来了---- %ld",_circleType);
        if (num > 240 && num <= 300) {
            _angle = num - 240;
        }else if (num >= 0 && num <= 240) {
            _angle = num + 120;
        }
        
    }
        [self setNeedsDisplay];
    //_angle =  180 + 180 / (_maximumValue - _minimumValue) * (num - _minimumValue);
    
}

-(void)setAddAngel{
    
    _angle += (int)260/(_maximumValue - _minimumValue);
    
    if (_angle>360) {
        _angle = 360;
    }
    [self setNeedsDisplay];
}

-(void)setMovAngel{
    _angle -= (int)260/(_maximumValue - _minimumValue);
    NSLog(@"_angle is %d ",_angle);
    if (_angle<180) {
        _angle = 180;
    }
    [self setNeedsDisplay];
}


- (void)setUnfilledColor:(UIColor *)unfilledColor
{
    _unfilledColor = unfilledColor;
    [self setNeedsDisplay];
}

- (void)setLineWidth:(int)lineWidth
{
    _lineWidth = lineWidth;
    [self setNeedsDisplay];
}




@end
