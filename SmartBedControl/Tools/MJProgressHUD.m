//
//  MJProgressHUD.m
//  EonHome
//
//  Created by 刘飞 on 2026/1/20.
//

#import "MJProgressHUD.h"

@implementation MJProgressHUD



+ (void)onlyShowMessage:(NSString *)message afterDelay:(NSTimeInterval)delay showAddTo:(UIView *)view
{
//    MBProgressHUD *hub = [MBProgressHUD showHUDAddedTo:view animated:YES];
//    hub.label.text = message;
    
    
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text = message;
    hud.mode = MBProgressHUDModeText;
    // 修改bezelView（中间圆角区域）
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.backgroundColor = [UIColor colorWithWhite:0.15 alpha:0.95];

    // 修改背景（周围遮罩区域）
    hud.backgroundView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];

    // 修改内容的颜色（文字、指示器等）
    hud.contentColor = [UIColor whiteColor];
    [hud hideAnimated:YES afterDelay:delay];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
