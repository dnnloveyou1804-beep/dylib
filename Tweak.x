#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "menu.h"

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

// --- FLOATING MENU BUTTON ---
@interface DucNamMenuButton : UIButton
@end

@implementation DucNamMenuButton
- (void)panAction:(UIPanGestureRecognizer *)pan {
    CGPoint p = [pan translationInView:self.superview];
    self.center = CGPointMake(self.center.x + p.x, self.center.y + p.y);
    [pan setTranslation:CGPointZero inView:self.superview];
}
@end

// --- MENU MANAGER ---
@interface DucNamMenuManager : NSObject <WKScriptMessageHandler>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIButton *closeButton;
+ (instancetype)sharedInstance;
- (void)showMenuInView:(UIView *)view;
- (void)hideMenu;
@end

@implementation DucNamMenuManager
+ (instancetype)sharedInstance {
    static id _shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [[self alloc] init];
    });
    return _shared;
}
- (void)showMenuInView:(UIView *)view {
    if (!self.webView) {
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        [config.userContentController addScriptMessageHandler:self name:@"closeMenu"];
        
        // WKWebView preferences
        [config.preferences setValue:@YES forKey:@"allowFileAccessFromFileURLs"];
        
        self.webView = [[WKWebView alloc] initWithFrame:view.bounds configuration:config];
        self.webView.opaque = NO;
        self.webView.backgroundColor = [UIColor clearColor];
        if (@available(iOS 11.0, *)) {
            self.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        NSString *base64String = GetBase64HTMLMenu();
        NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:base64String options:0];
        NSString *htmlString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
        
        if (htmlString) {
            [self.webView loadHTMLString:htmlString baseURL:nil];
        } else {
            [self.webView loadHTMLString:@"<html><body style='color:white; background:black;'><h1>Error decoding Menu!</h1></body></html>" baseURL:nil];
        }
        
        // Add Close Button (in case HTML doesn't have one)
        self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.closeButton setTitle:@"❌" forState:UIControlStateNormal];
        [self.closeButton addTarget:self action:@selector(hideMenu) forControlEvents:UIControlEventTouchUpInside];
        [self.webView addSubview:self.closeButton];
    }
    
    self.webView.frame = view.bounds;
    self.closeButton.frame = CGRectMake(view.bounds.size.width - 60, 50, 40, 40);
    [view addSubview:self.webView];
}
- (void)hideMenu {
    [self.webView removeFromSuperview];
}
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:@"closeMenu"]) {
        [self hideMenu];
    }
}
@end


// --- WINDOW HOOK ---
%hook UIWindow

- (void)layoutSubviews {
    %orig;
    
    if (CGRectEqualToRect(self.bounds, [UIScreen mainScreen].bounds)) {
        // 1. Rainbow Label
        DucNamRainbowLabel *lbl = (DucNamRainbowLabel *)[self viewWithTag:9395]; 
        if (!lbl) {
            lbl = [[DucNamRainbowLabel alloc] init];
            lbl.tag = 9395;
            lbl.text = @"Copyright DucNamTweaks Zalo 0395109314";
            lbl.font = [UIFont systemFontOfSize:12 weight:UIFontWeightBold];
            lbl.textAlignment = NSTextAlignmentCenter;
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
        
        CGFloat labelWidth = 300.0;
        CGFloat labelHeight = 20.0;
        CGFloat xPos = (self.bounds.size.width - labelWidth) / 2.0;
        CGFloat yPos = self.bounds.size.height - bottomPadding - 15.0;
        lbl.frame = CGRectMake(xPos, yPos, labelWidth, labelHeight);
        [self bringSubviewToFront:lbl];
        
        // 2. Floating Menu Button
        DucNamMenuButton *btn = (DucNamMenuButton *)[self viewWithTag:9396];
        if (!btn) {
            btn = [DucNamMenuButton buttonWithType:UIButtonTypeCustom];
            btn.tag = 9396;
            btn.frame = CGRectMake(20, 100, 50, 50);
            btn.layer.cornerRadius = 25;
            btn.layer.borderWidth = 2;
            btn.layer.borderColor = [UIColor whiteColor].CGColor;
            btn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
            [btn setTitle:@"Menu" forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
            
            UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:btn action:@selector(panAction:)];
            [btn addGestureRecognizer:pan];
            
            [btn addTarget:self action:@selector(ducNamShowMenu) forControlEvents:UIControlEventTouchUpInside];
            
            [self addSubview:btn];
        }
        [self bringSubviewToFront:btn];
    }
}

%new
- (void)ducNamShowMenu {
    [[DucNamMenuManager sharedInstance] showMenuInView:self];
}

%end
