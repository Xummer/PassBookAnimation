//
//  PBPassFrontFaceView.m
//  PassBookAniDemo
//
//  Created by Xummer on 14-2-10.
//  Copyright (c) 2014年 Xummer. All rights reserved.
//

#define CARD_LEFT_GAP       12
#define CARD_BOTTOM_GAP     31
#define MAX_TOP_Y           60

#import "PBPassFrontFaceView.h"

@interface PBPassFrontFaceView ()
@property (strong, nonatomic) UIImageView *cardImageView;

@property (strong, nonatomic) NSMutableArray *bodyAllSubViews;

- (void)_init;

@end

@implementation PBPassFrontFaceView

+ (CGRect)cardRect {
    return (CGRect){
        .origin.x = 0,
        .origin.y = 0,
        .size.width =  320,
        .size.height = 398
    };
}

+ (CGRect)faceViewRect {
    return (CGRect){
        .origin.x = -CARD_LEFT_GAP,
        .origin.y = 0,
        .size.width =  320 + 2*CARD_LEFT_GAP,
        .size.height = 398 + CARD_BOTTOM_GAP
    };
}

- (void)_init {
}

- (id)init {
    self = [super initWithFrame:[[self class] faceViewRect]];
    if (self) {
        [self _init];
    }
    return self;
}

- (id)initWithCustomView:(UIView <PBPassViewTapDelegate> *)customView backImage:(UIImage *)image {
    
    self = [super initWithFrame:[[self class] faceViewRect]];
    if (self) {
        [self _init];
        [self updateWithCustomView:customView backImage:image];
    }
    return self;
}

- (void)setIsOnlyShowTop:(BOOL)isOnlyShowTop {
    if (isOnlyShowTop) {
        [self removeAllOtherViews];
    }
    else {
        [self addAllSubViews];
    }
    
    _isOnlyShowTop = isOnlyShowTop;
}

- (void)updateWithCustomView:(UIView <PBPassViewTapDelegate> *)customView
                   backImage:(UIImage *)image
{
    [self createBodyContentViews];
    
    if (image) {
        _cardImageView.image = image;
    }
    [self addSubview:_cardImageView];
    
    
    
    if (_bodyCustomView.superview) {
        [_bodyCustomView removeFromSuperview];
    }
    self.bodyCustomView = customView;
    CGRect frame = _bodyCustomView.frame;
    frame.origin.x = CARD_LEFT_GAP;
    _bodyCustomView.frame = frame;
    
    self.bodyAllSubViews = [_bodyCustomView.subviews mutableCopy];
    [self removeAllOtherViews];
    
    [self addSubview:_bodyCustomView];
}

- (void)removeAllOtherViews {
    for (UIView *subV in [_bodyCustomView subviews]) {
        if (CGRectGetMinX(subV.frame) < MAX_TOP_Y) {
            [subV removeFromSuperview];
        }
    }
}

- (void)addAllSubViews {
    for (NSUInteger i = 0; i < [_bodyAllSubViews count]; i ++) {
        UIView *subView = _bodyAllSubViews[ i ];
        [_bodyCustomView addSubview:subView];
    }
}

- (void)createBodyContentViews {
    
    if (!_cardImageView) {
        self.cardImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _cardImageView.contentMode = UIViewContentModeCenter;
    }
}

@end
