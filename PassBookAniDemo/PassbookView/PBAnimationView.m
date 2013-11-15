//
//  PBAnimationView.m
//  IBTDemo
//
//  Created by Xummer on 13-10-29.
//  Copyright (c) 2013年 Xummer. All rights reserved.
//

#import "PBAnimationView.h"

#define PB_ITEM_START_Y 44

CGPoint const PBDefaultAcceleration = (CGPoint){1.0f, 1.0f};

@interface PBAnimationView ()<PBContainerDelegate>
@property(nonatomic, strong) NSMutableDictionary *accelerationsOfSubViews;
@property(nonatomic, strong) NSMutableArray *pbItems;

- (void)_init;

@end

@implementation PBAnimationView   

// designated init
- (void)_init {
    [self setBounces:YES];
    [self setAlwaysBounceVertical:YES];
    [self setCanCancelContentTouches:YES];
    self.accelerationsOfSubViews = [[NSMutableDictionary alloc] init];
    self.pbItems = [[NSMutableArray alloc] init];
}

- (id)initWithFrame:(CGRect)frame andItemsContent:(NSMutableArray *)iContents {
    self = [super initWithFrame:frame];
    if (self) {
        [self _init];
        [self updateWithItemsContent:iContents];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _init];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _init];
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        [self _init];
    }
    return self;
}

- (void)updateWithItemsContent:(NSMutableArray *)iContents {
    CGRect frame = CGRectMake(0, PB_ITEM_START_Y, 320, 397);
    NSUInteger icCount = [iContents count];
    if (icCount <= 0) {
        return;
    }
    
    CGFloat minHeight = 0;
    CGFloat itemGap = (self.frame.size.height-PB_ITEM_START_Y) / icCount;
    CGFloat accelerationRate = 1.0f / icCount;
    
    for (NSUInteger i = 0; i < icCount; i ++) {
        if ([iContents[ i ] isKindOfClass:[NSArray class]]) {
            
            NSArray *subItems = iContents[ i ];
            UIView *contentView = subItems[ 0 ];
            frame = contentView.frame;
            frame.origin.y = PB_ITEM_START_Y + i*itemGap;
            
            PBContainerView *cV = [[PBContainerView alloc] initWithFrame:frame];
            [cV setPbDelegate:self];
            [cV setInBoxIndex:i itemsCount:icCount];
            [cV updateContents:subItems];
            
            
            [_pbItems addObject:cV];
            [self addSubview:cV
             withAcceleration:CGPointMake(0, .009f+i*accelerationRate)];
            
            minHeight = MIN(frame.size.height, minHeight);
        }
    }
}

//====================================================================
#pragma mark - logic

- (void)addSubview:(UIView *)view {
    [self addSubview:view withAcceleration:PBDefaultAcceleration];
}

- (void)addSubview:(UIView *)view withAcceleration:(CGPoint) acceleration {
    // add to super
    [super addSubview:view];
    [self setAcceleration:acceleration forView:view];
}

- (void)setAcceleration:(CGPoint)acceleration forView:(UIView *)view {
    // store acceleration
    NSValue *pointValue =
     [NSValue value:&acceleration withObjCType:@encode(CGPoint)];
    _accelerationsOfSubViews[ @((int)view) ] = pointValue;
}

- (CGPoint)accelerationForView:(UIView *)view {
    
    // return
    CGPoint accelecration;
    
    // get acceleration
    NSValue *pointValue = _accelerationsOfSubViews[ @((int)view) ];
    if(pointValue == nil){
        accelecration = CGPointZero;
    }
    else{
        [pointValue getValue:&accelecration];
    }
    
    return accelecration;
}

- (void)willRemoveSubview:(UIView *)subview {
    [_accelerationsOfSubViews removeObjectForKey:@((int)subview)];
}

//====================================================================

- (void)animationToSelect:(PBContainerView *)selectView {
    
    NSUInteger inboxIndex = 0;
    for (NSUInteger i = 0; i < [_pbItems count]; i ++) {
        PBContainerView *itemV = (PBContainerView *)_pbItems[ i ];
        if (itemV == selectView) {
            [selectView animationToState:kPBOutBox];
        }
        else {
            [itemV setInBoxIndex:inboxIndex ++ itemsCount:[_pbItems count]];
            [itemV animationToState:kPBInBox];
        }
    }
}

- (void)animationToDefault {
    for (NSUInteger i = 0; i < [_pbItems count]; i ++) {
        [(PBContainerView *)_pbItems[ i ] animationToState:kPBDefualt];
    }
}

#pragma mark - layout

- (void)layoutSubviews {
    [super layoutSubviews];
    for (UIView *v in self.subviews) {
        // get acceleration
        CGPoint accelecration = [self accelerationForView:v];
        
        // move the view
//        NSLog(@"%f, %f, %f, %f", self.contentOffset.x, self.contentOffset.y, self.contentOffset.x*(1.0f-accelecration.x), self.contentOffset.y*(1.0f-accelecration.y));
        
//        NSLog(@"- %@ %@, %@", v, NSStringFromCGAffineTransform(v.transform), NSStringFromCGRect(v.frame));
        v.transform = CGAffineTransformMakeTranslation(self.contentOffset.x*(1.0f-accelecration.x), self.contentOffset.y*(1.0f-accelecration.y));
        
//        NSLog(@"+ %@ %@, %@", v, NSStringFromCGAffineTransform(v.transform), NSStringFromCGRect(v.frame));
    }

}

#pragma mark - PBItemDelegate
- (void)handleTap:(UITapGestureRecognizer *)tap item:(PBContainerView *)itemV; {
    switch (itemV.itemState) {
        case kPBDefualt:
            [self animationToSelect:itemV];
            break;
        case kPBInBox:
            [self animationToDefault];
            break;
        case kPBOutBox:
            [self animationToDefault];
            break;
        default:
            break;
    }
}

@end
