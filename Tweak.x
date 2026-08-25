#import <UIKit/UIKit.h>

// --- RAINBOW LABEL ---
@interface DucNamRainbowLabel : UILabel
@property (nonatomic, assign) CGFloat currentHue;
@end

@implementation DucNamRainbowLabel
- (instancetype)init {
    self = [super init];
    if (self) {
        self.currentHue = 0.0;
        CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick:)];
        [link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
    return self;
}

- (void)tick:(CADisplayLink *)link {
    self.currentHue += 0.005;
    if (self.currentHue > 1.0) self.currentHue = 0.0;
    self.textColor = [UIColor colorWithHue:self.currentHue saturation:1.0 brightness:1.0 alpha:1.0];
}
@end

// --- WINDOW HOOK ---
%hook UIWindow

- (void)layoutSubviews {
    %orig;
    
    if (CGRectEqualToRect(self.bounds, [UIScreen mainScreen].bounds)) {
        // Rainbow Label
        DucNamRainbowLabel *lbl = (DucNamRainbowLabel *)[self viewWithTag:9395]; 
        if (!lbl) {
            lbl = [[DucNamRainbowLabel alloc] init];
            lbl.tag = 9395;
            lbl.text = @"Copyright Đỗ Hoàng Vinh Zalo : 0967467242";
            lbl.font = [UIFont systemFontOfSize:12 weight:UIFontWeightBold];
            lbl.textAlignment = NSTextAlignmentCenter;
            
            // Đổ bóng để dễ đọc trên nền sáng
            lbl.layer.shadowColor = [UIColor blackColor].CGColor;
            lbl.layer.shadowOffset = CGSizeMake(0, 1);
            lbl.layer.shadowOpacity = 0.8;
            lbl.layer.shadowRadius = 2.0;
            
            [self addSubview:lbl];
        }
        
        CGFloat bottomPadding = 0.0;
        if (@available(iOS 11.0, *)) {
            bottomPadding = self.safeAreaInsets.bottom;
        }
        if (bottomPadding == 0) bottomPadding = 15.0;
        
        CGFloat labelWidth = 350.0;
        CGFloat labelHeight = 20.0;
        CGFloat xPos = (self.bounds.size.width - labelWidth) / 2.0;
        CGFloat yPos = self.bounds.size.height - bottomPadding - 15.0;
        lbl.frame = CGRectMake(xPos, yPos, labelWidth, labelHeight);
        
        [self bringSubviewToFront:lbl];
    }
}

%end
