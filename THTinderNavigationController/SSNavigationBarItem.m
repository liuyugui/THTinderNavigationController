//  Created by Sebastian Suchanowski (@ssuchanowski, www.synappse.co)

#import "SSNavigationBarItem.h"

@interface SSNavigationBarItem ()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIColor *activeColor;
@property (nonatomic, strong) UIColor *inactiveColor;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic) CGRect contentViewFrame;
@end

@implementation SSNavigationBarItem

- (instancetype)initWithImage:(UIImage *)image activeColor:(UIColor *)activeColor inactiveColor:(UIColor *)inactiveColor {
    self = [super init];
    if (self) {
        self.activeColor = activeColor;
        self.inactiveColor = inactiveColor;
        [self setupImage:image];
    }

    return self;
}

- (instancetype)initWithView:(UIView *)view activeColor:(UIColor *)activeColor inactiveColor:(UIColor *)inactiveColor {
    self = [super init];
    if (self) {
        self.activeColor = activeColor;
        self.inactiveColor = inactiveColor;
        self.contentView = view;
        self.contentViewFrame = view.frame;
        [self addSubview:view];
    }

    return self;
}

- (void)setupImage:(UIImage *)image {
    UIImage *iconImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.imageView = [[UIImageView alloc] initWithImage:iconImage];
    self.imageView.tintColor = self.activeColor;
    [self addSubview:self.imageView];
}

- (void)updateViewWithRatio:(CGFloat)ratio {

    CGFloat activeRed, inactiveRed, newRed;
    CGFloat activeGreen, inactiveGreen, newGreen;
    CGFloat activeBlue, inactiveBlue, newBlue;
    if ([self.activeColor getRed:&activeRed green:&activeGreen blue:&activeBlue alpha:NULL] &&
            [self.inactiveColor getRed:&inactiveRed green:&inactiveGreen blue:&inactiveBlue alpha:NULL]) {
        newRed = inactiveRed + ratio * (activeRed - inactiveRed);
        newGreen = inactiveGreen + ratio * (activeGreen - inactiveGreen);
        newBlue = inactiveBlue + ratio * (activeBlue - inactiveBlue);
        UIColor *newTintColor = [UIColor colorWithRed:newRed green:newGreen blue:newBlue alpha:1.0f];

        if (self.imageView) {
            self.imageView.tintColor = newTintColor;
        } else if (self.contentView) {
            [self changeSubviewsOfView:self.contentView tintColor:newTintColor];
        }
    }

    ratio = ratio / 4.0f + 0.5f;
    if (self.imageView) {
        CGFloat height = self.frame.size.height * ratio;
        CGFloat width = self.frame.size.width * ratio;
        CGFloat x = (self.frame.size.width - width) / 2.0f;
        CGFloat y = (self.frame.size.height - height) / 2.0f;
        self.imageView.frame = CGRectMake(x, y, width, height);
    } else if (self.contentView) {
        CGFloat height = self.contentViewFrame.size.height * ratio;
        CGFloat width = self.contentViewFrame.size.width * ratio;
        CGFloat x = (self.contentViewFrame.size.width - width) / 2.0f;
        CGFloat y = (self.contentViewFrame.size.height - height) / 2.0f;
        self.contentView.frame = CGRectMake(x, y, width, height);
    }
}

- (void)changeSubviewsOfView:(UIView *)view tintColor:(UIColor *)tintColor {
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];

    for (UIView *singleSubview in view.subviews) {
        // disable actions on non active items
        singleSubview.userInteractionEnabled = [tintColor isEqual:self.activeColor];

        if ([singleSubview isKindOfClass:[UIActivityIndicatorView class]]) {
            ((UIActivityIndicatorView *) singleSubview).color = tintColor;
        } else if ([singleSubview isKindOfClass:[UILabel class]]) {
            ((UILabel *) singleSubview).textColor = tintColor;
        } else if ([singleSubview isKindOfClass:[UIButton class]]) {
            ((UIButton *) singleSubview).tintColor = tintColor;
            [((UIButton *) singleSubview) setTitleColor:tintColor forState:UIControlStateNormal];
            [((UIButton *) singleSubview) setTitleColor:tintColor forState:UIControlStateHighlighted];
        } else if ([singleSubview isKindOfClass:[UITextField class]]) {
            ((UITextField *) singleSubview).textColor = tintColor;
        } else if ([singleSubview isKindOfClass:[UITextView class]]) {
            ((UITextView *) singleSubview).textColor = tintColor;
        } else if ([singleSubview isKindOfClass:[UIImageView class]]) {
            ((UIImageView *) singleSubview).tintColor = tintColor;
        } else if ([singleSubview isKindOfClass:[UIView class]] && ![singleSubview isKindOfClass:[UIControl class]]) {
            [self changeSubviewsOfView:singleSubview tintColor:tintColor]; // go deep :P
        } else {
            singleSubview.tintColor = tintColor;
        }
    }
}

@end
