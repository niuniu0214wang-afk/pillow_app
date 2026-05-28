//
//  UIImageView+GIF.m
//  SmartBedControl
//
//  Created by 刘飞 on 2026/5/7.
//

#import "UIImageView+GIF.h"
#import <ImageIO/ImageIO.h>
@implementation UIImageView (GIF)

- (void)playGifWithName:(NSString *)gifName {
    NSString *path = [[NSBundle mainBundle] pathForResource:gifName ofType:@"gif"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    [self playGifWithData:data];
}

- (void)playGifWithData:(NSData *)gifData {
    if (!gifData) return;
    
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)gifData, NULL);
    if (!source) return;
    
    size_t count = CGImageSourceGetCount(source);
    NSMutableArray *images = [NSMutableArray array];
    NSTimeInterval duration = 0;
    
    for (size_t i = 0; i < count; i++) {
        CGImageRef cgImage = CGImageSourceCreateImageAtIndex(source, i, NULL);
        if (!cgImage) continue;
        
        [images addObject:[UIImage imageWithCGImage:cgImage]];
        CGImageRelease(cgImage);
        
        NSDictionary *properties = (__bridge NSDictionary *)CGImageSourceCopyPropertiesAtIndex(source, i, NULL);
        NSDictionary *gifInfo = properties[(NSString *)kCGImagePropertyGIFDictionary];
        NSNumber *delayTime = gifInfo[(NSString *)kCGImagePropertyGIFDelayTime];
        
        if (delayTime) {
            duration += delayTime.doubleValue;
        }
        
        CFRelease((__bridge CFTypeRef)properties);
    }
    
    CFRelease(source);
    
    self.animationImages = images;
    self.animationDuration = duration;
    self.animationRepeatCount = 0;
    [self startAnimating];
}

@end
