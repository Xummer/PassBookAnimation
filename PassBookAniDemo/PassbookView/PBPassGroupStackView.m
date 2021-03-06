//
//  PBPassGroupStackView.m
//  IBTDemo
//
//  Created by Xummer on 13-10-29.
//  Copyright (c) 2013年 Xummer. All rights reserved.
//

#import "PBPassGroupStackView.h"

#define PB_ITEM_START_Y 44

CGPoint const PBDefaultAcceleration = (CGPoint){1.0f, 1.0f};

@interface PBPassGroupStackView ()<PBPassGroupDelegate>
@property(weak, nonatomic) id<PBPassGroupStackDataSource> dataSource;

@property(strong, nonatomic) NSMutableDictionary *accelerationsOfSubViews;
@property(strong, nonatomic) NSMutableArray *accelerateViews;
@property(strong, nonatomic) NSMutableArray *passPileViews;
@property(copy, nonatomic) NSMutableArray *reuseablePassPileViews;

- (void)_init;

@end

@implementation PBPassGroupStackView   

// designated init
- (void)_init {
    [self setBounces:YES];
    [self setAlwaysBounceVertical:YES];
    [self setCanCancelContentTouches:YES];
    self.accelerationsOfSubViews = [[NSMutableDictionary alloc] init];
    self.accelerateViews = [NSMutableArray array];
    self.passPileViews = [[NSMutableArray alloc] init];
}

- (id)initWithFrame:(CGRect)frame
         datasource:(id<PBPassGroupStackDataSource>)dataSource;
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _init];
        [self setDataSource:dataSource];
        [self reloadData];
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

- (void)reloadData {
    
    if (![_dataSource respondsToSelector:@selector(numberOfPassGroupViews)]) {
        NSLog(@"Errot _dataSource can't responds to |numberOfPassGroupViews|");
    }
    
    NSUInteger icCount = [_dataSource numberOfPassGroupViews];
    if (icCount <= 0) {
        NSLog(@"icCount not more than Zero");
        return;
    }
    
    if (![_dataSource respondsToSelector:@selector(defaultOffsetYAtStackIndex:)]) {
        NSLog(@"Errot _dataSource can't responds to |defaultOffsetYAtStackIndex:|");
        return;
    }
    
    if (![_dataSource respondsToSelector:@selector(passViewsAtStackIndex:)]) {
        NSLog(@"Errot _dataSource can't responds to |contentViewAtStackIndex:|");
        return;
    }
    
    CGFloat accelerationRate = 1.0f / icCount;
    
    [self.accelerateViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.reuseablePassPileViews = _passPileViews;
    [_passPileViews removeAllObjects];
    
    for (NSUInteger i = 0; i < icCount; i ++) {
        
        NSArray *contents = [_dataSource passViewsAtStackIndex:i];
        
        PBPassGroupView *cV = [self dequeueReusablePassPileViewAtIndex:i];
        
        [cV setPbDelegate:self];
        [cV setInBoxIndex:i itemsCount:icCount];
        [cV updateContents:contents];
        
        [_passPileViews addObject:cV];
        [self addSubview:cV
        withAcceleration:CGPointMake(0, .009f+i*accelerationRate)];
    }
}

- (PBPassGroupView *)dequeueReusablePassPileViewAtIndex:(NSUInteger)index {
    
    PBPassGroupView *cV = nil;
    if ([_reuseablePassPileViews count] > index) {
        cV = _reuseablePassPileViews[ index ];
    }
    else {
        NSArray *contents = [_dataSource passViewsAtStackIndex:index];
        UIView *subContentView = contents[ 0 ];
        CGRect frame = subContentView.frame;
        frame.origin.y = [_dataSource defaultOffsetYAtStackIndex:index];;
        cV =
        [[PBPassGroupView alloc] initWithFrame:frame tapEnable:YES];
    }
    
    return cV;
}

- (void)updateWithItemsContent:(NSMutableArray *)iContents {
    CGRect frame = CGRectMake(0, PB_ITEM_START_Y, 320, 397);
    NSUInteger icCount = [iContents count];
    if (icCount <= 0) {
        return;
    }
    
    CGFloat minHeight = 0;
    CGFloat itemGap = (CGRectGetHeight(self.frame)-PB_ITEM_START_Y) / icCount;
    CGFloat accelerationRate = 1.0f / icCount;
    
    for (NSUInteger i = 0; i < icCount; i ++) {
        if ([iContents[ i ] isKindOfClass:[NSArray class]]) {
            
            NSArray *subItems = iContents[ i ];
            UIView *contentView = subItems[ 0 ];
            frame = contentView.frame;
            frame.origin.y = PB_ITEM_START_Y + i*itemGap;
            
            PBPassGroupView *cV = [[PBPassGroupView alloc] initWithFrame:frame];
            [cV setPbDelegate:self];
            [cV setInBoxIndex:i itemsCount:icCount];
            [cV updateContents:subItems];
            
            
            [_passPileViews addObject:cV];
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
    [_accelerateViews addObject:view];
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
    [_accelerateViews removeObject:subview];
    [_accelerationsOfSubViews removeObjectForKey:@((int)subview)];
}

//====================================================================

- (void)animationToSelectWithPassIndex:(NSUInteger)psIndex {
    if (psIndex < [_passPileViews count]) {
        PBPassGroupView *passV = (PBPassGroupView *)_passPileViews[ psIndex ];
        [self animationToSelect:passV];
    }
}

- (void)animationToSelect:(PBPassGroupView *)selectView {
    
    NSUInteger inboxIndex = 0;
    for (NSUInteger i = 0; i < [_passPileViews count]; i ++) {
        PBPassGroupView *passV = (PBPassGroupView *)_passPileViews[ i ];
        if (passV == selectView) {
            [selectView animationToState:kPBOutBox];
        }
        else {
            [passV setInBoxIndex:inboxIndex ++ itemsCount:[_passPileViews count]];
            [passV animationToState:kPBInBox];
        }
    }
}

- (void)animationToDefault {
    for (NSUInteger i = 0; i < [_passPileViews count]; i ++) {
        [(PBPassGroupView *)_passPileViews[ i ] animationToState:kPBDefault];
    }
}

#pragma mark - layout

- (void)layoutSubviews {
    [super layoutSubviews];
    for (UIView *v in self.accelerateViews) {
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
- (void)handleTap:(UITapGestureRecognizer *)tap item:(PBPassGroupView *)passV; {
    switch (passV.presentationState) {
        case kPBDefault:
            [self animationToSelect:passV];
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
