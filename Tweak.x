#import <UIKit/UIKit.h>

@interface MTLumaDodgePillView : UIView
@property (nonatomic, retain) UILabel *ducNamLabel;
@end

%hook MTLumaDodgePillView

%property (nonatomic, retain) UILabel *ducNamLabel;

- (void)layoutSubviews {
    %orig;
    
    if (!self.ducNamLabel) {
        self.ducNamLabel = [[UILabel alloc] init];
        self.ducNamLabel.text = @"Copyright DucNamTweaks Zalo 0395109314";
        self.ducNamLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.8]; // Semi-transparent white
        self.ducNamLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightMedium];
        self.ducNamLabel.textAlignment = NSTextAlignmentCenter;
        
        // Ensure the label is not clipped if the pill view clips its bounds
        self.clipsToBounds = NO;
        
        [self addSubview:self.ducNamLabel];
    }
    
    // Center the label slightly above the home bar
    CGFloat labelWidth = 250.0;
    CGFloat labelHeight = 20.0;
    CGFloat xPos = (self.bounds.size.width - labelWidth) / 2.0;
    CGFloat yPos = -22.0; // 22 pixels above the pill view
    
    self.ducNamLabel.frame = CGRectMake(xPos, yPos, labelWidth, labelHeight);
}

%end
