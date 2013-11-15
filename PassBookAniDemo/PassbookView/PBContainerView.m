//
//  PBContainerView.m
//  HappyTreasure
//
//  Created by Xummer on 13-11-14.
//  Copyright (c) 2013年 Mars. All rights reserved.
//

#import "PBContainerView.h"

#define PB_SUBITEM_GAP          5
#define PB_PAGECONTROL_HEIGHT   20

@interface PBContainerView () <UIScrollViewDelegate>{
 @private
    CGRect _defualtRect;
    CGFloat _inboxY;
    CGFloat _outboxY;
    
    NSUInteger _inboxIndex;
    NSUInteger _itemsCount;
    
    NSUInteger _currentPage;
}

@property(nonatomic, strong) PBScrollView *contentScroll;
@property(nonatomic, strong) NSMutableArray *subItems;
@property(nonatomic, strong) UIPageControl *pageConrol;
@end

@implementation PBContainerView

- (id)init {
    self = [super init];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    CGRect newFrame = frame;
    newFrame.size.height += PB_PAGECONTROL_HEIGHT;
    self = [super initWithFrame:newFrame];
    if (self) {
        // Initialization code
        _defualtRect = frame;
        
        [self setupViews];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    // reset _contentScroll subView size
    CGRect subViewRect = _contentScroll.frame;
    subViewRect.size.width = frame.size.width;
    [_contentScroll setFrame:subViewRect];
}

- (void)setInBoxIndex:(NSUInteger)index itemsCount:(NSUInteger)count {
    _inboxIndex = index;
    _itemsCount = count;
    _inboxY = self.superview.bounds.size.height - BOX_BANNER_HEIGHT
    - (count - index)*BOX_GAP;
}

- (void)updateContents:(NSArray *)data {
    _outboxY = TOP_GAP;
    
    NSUInteger iCount = [data count];
    [_pageConrol setNumberOfPages:iCount];
    for (NSUInteger i = 0; i < [data count]; i ++) {
        NSUInteger index = iCount-1 - i;
        if ([data[ index ] isKindOfClass:[UIView class]]) {
            UIView *conV = data[ index ];
            
            PBItemView *iV =
            [[PBItemView alloc] initWithOrigin:CGPointMake(0, i*PB_SUBITEM_GAP)
                                       content:conV];
            
            iV.subIndex = index;
            iV.subCount = iCount;
            [_subItems addObject:iV];
            [_contentScroll addSubview:iV];
        }
    }
    
    [_contentScroll setContentSize:
     CGSizeMake(iCount * _defualtRect.size.width, _defualtRect.size.height)];
}

- (void)setupViews {
    
    [self setBackgroundColor:[UIColor clearColor]];
    [self setClipsToBounds:NO];
    
    // scrollView setting
    CGRect frame = _defualtRect;
    frame.origin = CGPointZero;
    
    self.contentScroll = [[PBScrollView alloc] initWithFrame:frame];
    [_contentScroll setDelegate:self];
    [_contentScroll setShowsHorizontalScrollIndicator:NO];
    [_contentScroll setShowsVerticalScrollIndicator:NO];
    [_contentScroll setPagingEnabled:YES];
    [_contentScroll setClipsToBounds:NO];
    [self addSubview:_contentScroll];
    
    // Page Control
    _currentPage = 0;
    
    frame = (CGRect){
        .origin.x = 0,
        .origin.y = CGRectGetMaxY(_contentScroll.bounds),
        .size.width =  CGRectGetWidth(self.bounds),
        .size.height = PB_PAGECONTROL_HEIGHT
    };
    
    self.pageConrol = [[UIPageControl alloc] initWithFrame:frame];
    [_pageConrol setHidesForSinglePage:YES];
    [_pageConrol setPageIndicatorTintColor:
     [UIColor colorWithRed:1.000 green:0.441 blue:0.391 alpha:1]];
    [_pageConrol setCurrentPageIndicatorTintColor:
     [UIColor colorWithRed:0.871 green:0.000 blue:0.075 alpha:1]];
    
    [_pageConrol setCurrentPage:_currentPage];
    [_pageConrol addTarget:self action:@selector(pageTurn:) forControlEvents:UIControlEventValueChanged];
    [self insertSubview:_pageConrol belowSubview:_contentScroll];
    
    
    [self setItemState:kPBDefualt];
    self.subItems = [[NSMutableArray alloc] init];
    
    UITapGestureRecognizer *tapGesture =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(tapHandle:)];
    [self addGestureRecognizer:tapGesture];
    
}

- (void)tapHandle:(UITapGestureRecognizer *)tap {
    if ([_pbDelegate respondsToSelector:@selector(handleTap:item:)]) {
        CGPoint point = [tap locationInView:_contentScroll];
        CGRect scrollRect = _contentScroll.frame;
        scrollRect.size.width *= [_pageConrol numberOfPages];
        if (CGRectContainsPoint(scrollRect, point)) {
            [_pbDelegate handleTap:tap item:self];
        }
    }
}

- (void)pageTurn:(UIPageControl *)pageControl
{
    NSInteger nextPage = [pageControl currentPage];
    CGPoint destination = CGPointMake(CGRectGetWidth(_contentScroll.bounds)*nextPage, 0);
    [_contentScroll setContentOffset:destination animated:YES];
}

- (void)animationToState:(PBItemState)state {
    if (_itemState == state) {
        return;
    }
    
    CGRect frame = _defualtRect;
    frame.size.height += PB_PAGECONTROL_HEIGHT;
    
    CGFloat shadowAlpha = 0;
    BOOL enableScroll = NO;
    switch (state) {
        case kPBDefualt:
            if ([self.superview isKindOfClass:[UIScrollView class]]) {
                [(UIScrollView *)self.superview setScrollEnabled:YES];
            }
            frame.origin.y = _defualtRect.origin.y;
            break;
        case kPBInBox:
            frame.origin.y = _inboxY;
            
            CGFloat gap = MIN(5, _itemsCount-2 - _inboxIndex * 1);
            
            frame = (CGRect){
                .origin.x = gap,
                .origin.y = _inboxY,
                .size.width =  frame.size.width - 2*gap,
                .size.height = frame.size.height
            };
            
            break;
        case kPBOutBox:
            frame.origin.y = _outboxY;
            if ([self.superview isKindOfClass:[UIScrollView class]]) {
                [(UIScrollView *)self.superview setScrollEnabled:NO];
            }
            
            shadowAlpha = 1;
            enableScroll = YES;
            
            break;
        default:
            break;
    }
    
    [self setUserInteractionEnabled:NO];
    [self doMultiAnimationByState:state];

    [UIView animateWithDuration:.4f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [_contentScroll setScrollEnabled:enableScroll];
                         [self setFrame:frame];
                         
//                         [_shadowView setAlpha:shadowAlpha];
                         
                     }
                     completion:^(BOOL finished) {
                         
                         if (finished) {
                             _itemState = state;
                         }
                         
                         [self setUserInteractionEnabled:YES];
                     }
     ];
    
    
}


#pragma mark - multi item animation
- (void)doMultiAnimationByState:(PBItemState)state {
    switch (state) {
        case kPBDefualt:
            [self multiItemsToDefualtAnimation];
            break;
        case kPBInBox:
            break;
            
        case kPBOutBox:
            [self multiItemsOutboxUnfold];
            break;
            
        default:
            break;
    }
}

- (void)multiItemsOutboxUnfold {
    [UIView animateWithDuration:.3f
                          delay:.1f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         CGRect itemRect = _defualtRect;
                         
                         NSUInteger itemIndex = 0;
                         for (NSUInteger i = 0; i < [_contentScroll subviews].count; i++) {
                             if ([_contentScroll.subviews[ i ] isKindOfClass:[PBItemView class]]) {
                                 PBItemView *iV = _contentScroll.subviews[ i ];
                                 itemRect = iV.frame;
                                 itemRect.origin =
                                  CGPointMake(_currentPage*CGRectGetWidth(itemRect), itemIndex*44);
                                 [iV setFrame:itemRect];
                                 itemIndex ++;
                             }
                         }
                     }
                     completion:^(BOOL finished) {
                         [self multiItemsOutboxMoveAway];
                     }
     ];

    
}

- (void)multiItemsOutboxMoveAway {
    [UIView animateWithDuration:.36f
                          delay:.16f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         CGRect itemRect = _defualtRect;
                         for (NSUInteger i = 0; i < [_subItems count]; i++) {
                             
                             if ([_subItems[ i ] isKindOfClass:[PBItemView class]]) {
                                 PBItemView *iV = _subItems[ i ];
                                 itemRect = iV.frame;
                                 itemRect.origin = CGPointMake(iV.subIndex*CGRectGetWidth(itemRect), 0);
                                 [iV setFrame:itemRect];
                             }
                         }
                     }
                     completion:^(BOOL finished) {

                     }
     ];
}

- (void)multiItemsToDefualtAnimation {
    [UIView animateWithDuration:.1f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         NSUInteger stackIndex = 0;
                         for (NSUInteger i = 0; i < [_contentScroll subviews].count; i++) {
                             if ([_contentScroll.subviews[ i ] isKindOfClass:[PBItemView class]]) {
                                 PBItemView *iV = _contentScroll.subviews[ i ];
                                 [iV toDefualtWithStackIndex:stackIndex
                                                 currentPage:_currentPage];
                                 stackIndex ++;
                             }
                         }
                     }
                     completion:^(BOOL finished) {
                         
                     }
     ];
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat tmpPage = scrollView.contentOffset.x/self.bounds.size.width;
    if (tmpPage > 0 && tmpPage < [_subItems count]) {
        _currentPage = tmpPage;
        _pageConrol.currentPage = _currentPage;
        
        // Bring current page to front
        NSUInteger stackIndex = [_subItems count] - 1 - _currentPage;
        if ([_subItems[ stackIndex ] isKindOfClass:[PBItemView class]]) {
            PBItemView *itemV = (PBItemView *)_subItems[ stackIndex ];
            [itemV.superview bringSubviewToFront:itemV ];
        }
    }
}

@end


#pragma mark - PBItemView

@interface PBItemView () {
 @private
    CGRect _defualtRect;
}
@end

@implementation PBItemView

- (id)initWithOrigin:(CGPoint)theOrigin content:(UIView *)theView {
    CGRect frame = theView.bounds;
    theView.frame = frame;
    frame.origin = theOrigin;
    
    self = [super initWithFrame:frame];
    if (self) {
        _defualtRect = frame;
        [self setAutoresizingMask:
         UIViewAutoresizingFlexibleWidth |
         UIViewAutoresizingFlexibleHeight
         ];
        
        [theView setAutoresizingMask:
         UIViewAutoresizingFlexibleWidth |
         UIViewAutoresizingFlexibleHeight
         ];
//        [theView setAutoresizingMask:
//         UIViewAutoresizingFlexibleLeftMargin |
//         UIViewAutoresizingFlexibleWidth |
//         UIViewAutoresizingFlexibleRightMargin |
//         UIViewAutoresizingFlexibleTopMargin |
//         UIViewAutoresizingFlexibleHeight |
//         UIViewAutoresizingFlexibleBottomMargin
//         ];
        [self addSubview:theView];
    }
    return self;
}

- (void)toDefualtWithStackIndex:(NSUInteger)sIndex currentPage:(NSUInteger)cPage{
    CGRect frame = _defualtRect;
    frame.origin.x = cPage * CGRectGetWidth(frame);
    frame.origin.y = sIndex * PB_SUBITEM_GAP;
    [self setFrame:frame];
}

@end


#pragma mark - PBScrollView
@interface PBScrollView ()

@end

@implementation PBScrollView

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];

    // reset subView size
    CGRect subViewRect;
    for (NSUInteger i = 0; i < [self subviews].count; i++) {
        if ([self.subviews[ i ] isKindOfClass:[PBItemView class]]) {
            PBItemView *iV = self.subviews[ i ];
            subViewRect = iV.frame;
            subViewRect.size.width = frame.size.width;
            [iV setFrame:subViewRect];
        }
    }
}

@end