#import <UIKit/UIKit.h>

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
    self.currentHue += 0.005; // Tốc độ đổi màu cầu vồng
    if (self.currentHue > 1.0) self.currentHue = 0.0;
    self.textColor = [UIColor colorWithHue:self.currentHue saturation:1.0 brightness:1.0 alpha:1.0];
}
@end

%hook UIWindow

- (void)layoutSubviews {
    %orig;
    
    // Chỉ thêm vào cửa sổ chính của ứng dụng
    if (CGRectEqualToRect(self.bounds, [UIScreen mainScreen].bounds)) {
        DucNamRainbowLabel *lbl = (DucNamRainbowLabel *)[self viewWithTag:9395]; 
        if (!lbl) {
            lbl = [[DucNamRainbowLabel alloc] init];
            lbl.tag = 9395;
            lbl.text = @"Copyright DucNamTweaks Zalo 0395109314";
            lbl.font = [UIFont systemFontOfSize:12 weight:UIFontWeightBold];
            lbl.textAlignment = NSTextAlignmentCenter;
            
            // Thêm bóng đổ để chữ dễ đọc trên nền sáng/tối
            lbl.layer.shadowColor = [UIColor blackColor].CGColor;
            lbl.layer.shadowOffset = CGSizeMake(0, 1);
            lbl.layer.shadowOpacity = 0.8;
            lbl.layer.shadowRadius = 2.0;
            
            [self addSubview:lbl];
        }
        
        // Tính toán vị trí (nằm ngay trên thanh vuốt Home)
        CGFloat bottomPadding = 0.0;
        if (@available(iOS 11.0, *)) {
            bottomPadding = self.safeAreaInsets.bottom;
        }
        if (bottomPadding == 0) {
            bottomPadding = 15.0; // Cho máy viền vuông không có tai thỏ
        }
        
        CGFloat labelWidth = 300.0;
        CGFloat labelHeight = 20.0;
        CGFloat xPos = (self.bounds.size.width - labelWidth) / 2.0;
        CGFloat yPos = self.bounds.size.height - bottomPadding - 15.0; // Cách đáy một chút
        
        lbl.frame = CGRectMake(xPos, yPos, labelWidth, labelHeight);
        
        // Đảm bảo chữ luôn hiển thị trên cùng
        [self bringSubviewToFront:lbl];
    }
}

%end
