//
//  PBContainerView.m
//  HappyTreasure
//
//  Created by Xummer on 13-11-14.
//  Copyright (c) 2013年 Mars. All rights reserved.
//

#import "PBPassGroupView.h"

#define PB_SUBITEM_GAP          5
#define PB_PAGECONTROL_HEIGHT   20
#define PB_SCROLL_GAP           4

@interface PBPassGroupView ()
<
    UIScrollViewDelegate,
    UIGestureRecognizerDelegate
>
{
 @private
    CGRect _defaultRect;
    CGFloat _inboxY;
    CGFloat _outboxY;
    
    NSUInteger _inboxIndex;
    NSUInteger _itemsCount;
    
    NSUInteger _displayIndex;
    
//    PBPassState _toState;
}

@property(nonatomic, strong) UIView *fakeTapMask;
@property(nonatomic, strong) UIScrollView *contentScroll;
@property(nonatomic, strong) NSMutableArray *subItems;
@property(nonatomic, strong) UIPageControl *pageControl;
@end

@implementation PBPassGroupView

- (id)init {
    self = [super init];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame tapEnable:(BOOL)enable {
    CGRect newFrame = frame;
    newFrame.size.height += PB_PAGECONTROL_HEIGHT;
    self = [super initWithFrame:newFrame];
    if (self) {
        _defaultRect = frame;
        
        [self setupViews];
        [self enableTapGesture:enable];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [self initWithFrame:frame tapEnable:YES];
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    // reset _contentScroll subView size
//    CGRect subViewRect = _contentScroll.frame;
//    subViewRect.size.width = frame.size.width;
//    [_contentScroll setFrame:subViewRect];
}

- (void)setPresentationState:(PBPassState)itemState {
    _presentationState = itemState;
    BOOL enableScroll = NO;
    switch (itemState) {
        case kPBDefault:
        case kPBInBox:
            enableScroll = NO;
            break;
        case kPBOutBox:
            enableScroll = YES;
            break;
        default:
            
            break;
    }
    [_fakeTapMask setHidden:enableScroll];
    [_contentScroll setScrollEnabled:enableScroll];
}

- (void)enableSubViewsTap:(BOOL)eableTap {
    if (eableTap) {
        if (_fakeTapMask) {
            [_fakeTapMask removeFromSuperview];
            self.fakeTapMask = nil;
        }
    }
    else {
        if (!_fakeTapMask) {
            self.self.fakeTapMask = [[UIView alloc] initWithFrame:self.bounds];
            [_fakeTapMask setBackgroundColor:[UIColor clearColor]];
            [_fakeTapMask setHidden:_presentationState == kPBOutBox];
            [self addSubview:_fakeTapMask];
        }
    }
}

- (void)setInBoxIndex:(NSUInteger)index itemsCount:(NSUInteger)count {
    _inboxIndex = index;
    _itemsCount = count;
    _inboxY = CGRectGetHeight(self.superview.bounds) - BOX_BANNER_HEIGHT
    - (count - index)*BOX_GAP;
}

- (void)updateContents:(NSArray *)data {
    _outboxY = TOP_GAP;
    
    // remove all subItems
    for (PBPassView *subView in _subItems) {
        [subView removeFromSuperview];
    }
    [self.subItems removeAllObjects];
    
    // reload subItems
    NSUInteger iCount = [data count];
    [_pageControl setNumberOfPages:iCount];
    for (NSUInteger i = 0; i < [data count]; i ++) {
        NSUInteger index = iCount-1 - i;
        if ([data[ index ] isKindOfClass:[UIView class]]) {
            UIView <PBPassViewTapDelegate> *conV = data[ index ];
            
            // TODO 判断 当前状态后
            CGPoint origin = (CGPoint){
                .x = PB_SCROLL_GAP,
                .y = i*PB_SUBITEM_GAP,
            };
            PBPassView *iV =
            [[PBPassView alloc] initWithOrigin:origin
                                       content:conV];
            
            iV.subIndex = index;
            iV.subCount = iCount;
            [_subItems addObject:iV];
            [_contentScroll addSubview:iV];
        }
    }
    
    [_contentScroll setContentSize:
     CGSizeMake(iCount * CGRectGetWidth(_contentScroll.bounds),
                CGRectGetHeight(_contentScroll.bounds))];
}

- (void)setupViews {
    
    [self setBackgroundColor:[UIColor clearColor]];
    [self setClipsToBounds:NO];
    
    // scrollView setting
    CGRect frame = _defaultRect;
    frame.origin = CGPointZero;
    
    self.contentScroll = [[UIScrollView alloc] initWithFrame:CGRectInset(frame, -PB_SCROLL_GAP, 0)];
    [_contentScroll setDelegate:self];
    [_contentScroll setShowsHorizontalScrollIndicator:NO];
    [_contentScroll setShowsVerticalScrollIndicator:NO];
    [_contentScroll setPagingEnabled:YES];
    [_contentScroll setClipsToBounds:NO];
    [self addSubview:_contentScroll];
    
    // Page Control
    _displayIndex = 0;
    
    frame = (CGRect){
        .origin.x = 0,
        .origin.y = CGRectGetMaxY(_contentScroll.bounds),
        .size.width =  CGRectGetWidth(self.bounds),
        .size.height = PB_PAGECONTROL_HEIGHT
    };
    
    self.pageControl = [[UIPageControl alloc] initWithFrame:frame];
    [_pageControl setHidesForSinglePage:YES];
    [_pageControl setPageIndicatorTintColor:[UIColor colorWithWhite:.8 alpha:1]];
    [_pageControl setCurrentPageIndicatorTintColor:
     [UIColor colorWithWhite:.2 alpha:1]];
    
    [_pageControl setCurrentPage:_displayIndex];
    [_pageControl addTarget:self action:@selector(pageTurn:) forControlEvents:UIControlEventValueChanged];
    [self insertSubview:_pageControl belowSubview:_contentScroll];
    
    
    [self setPresentationState:kPBDefault];
    self.subItems = [[NSMutableArray alloc] init];
    
    // fake tap mask view
    
    [self enableSubViewsTap:NO];
    
}

- (void)enableTapGesture:(BOOL)enable {
    if (enable) {
        UITapGestureRecognizer *tapGesture =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(tapHandle:)];
        [tapGesture setDelegate:self];
        [self addGestureRecognizer:tapGesture];
    }
}

- (void)tapHandle:(UITapGestureRecognizer *)tap {
    // -- Before Tap
    if ([_subItems count] > 0 && _displayIndex < [_subItems count]) {
        PBPassView *item = _subItems[ _displayIndex ];
        if ([item.contentView respondsToSelector:@selector(sholdHandleItemTap:item:)]) {
            if (![item.contentView sholdHandleItemTap:tap item:item]) {
                return;
            }
        }
    }
    // -- end
    
    if ([_pbDelegate respondsToSelector:@selector(handleTap:item:)]) {
        CGPoint point = [tap locationInView:_contentScroll];
        CGRect scrollRect = _contentScroll.frame;
        scrollRect.size.width *= [_pageControl numberOfPages];
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

- (void)animationToState:(PBPassState)state {
    if (_presentationState == state) {
        return;
    }
    
    CGRect frame = _defaultRect;
    frame.size.height += PB_PAGECONTROL_HEIGHT;
    
    switch (state) {
        case kPBDefault:
            if ([self.superview isKindOfClass:[UIScrollView class]]) {
                [(UIScrollView *)self.superview setScrollEnabled:YES];
            }
            frame.origin.y = _defaultRect.origin.y;
            break;
        case kPBInBox:
            frame.origin.y = _inboxY;
            
            // cancel reset frame in inBox
//            CGFloat gap = MIN(5, _itemsCount-2 - _inboxIndex * 1);
//            
//            frame = (CGRect){
//                .origin.x = gap,
//                .origin.y = _inboxY,
//                .size.width =  frame.size.width - 2*gap,
//                .size.height = frame.size.height
//            };
            
            break;
        case kPBOutBox:
            frame.origin.y = _outboxY;
            if ([self.superview isKindOfClass:[UIScrollView class]]) {
                [(UIScrollView *)self.superview setScrollEnabled:NO];
            }
            
            break;
        default:
            break;
    }
    
    [self setUserInteractionEnabled:NO];
    [self doMultiAnimationByState:state];

    __unsafe_unretained PBPassGroupView* weakSelf = self;
    [UIView animateWithDuration:.4f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [weakSelf setFrame:frame];
                     }
                     completion:^(BOOL finished) {
                         
                         if (finished) {
                             weakSelf.presentationState = state;
                         }
                         
                         [weakSelf setUserInteractionEnabled:YES];
                     }
     ];
    
    
}

#pragma mark - UIGesture Delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch
{
    // 点击到 |tableViewCell| 时，取消响应
    return ![NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"];
}

#pragma mark - multi item animation
- (void)doMultiAnimationByState:(PBPassState)state {
    switch (state) {
        case kPBDefault:
            [self multiItemsToDefaultAnimation];
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
    __unsafe_unretained PBPassGroupView* weakSelf = self;
    [UIView animateWithDuration:.3f
                          delay:.1f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         CGRect itemRect = _defaultRect;
                         
                         NSUInteger itemIndex = 0;
                         for (NSUInteger i = 0; i < [_contentScroll subviews].count; i++) {
                             if ([_contentScroll.subviews[ i ] isKindOfClass:[PBPassView class]]) {
                                 PBPassView *iV = _contentScroll.subviews[ i ];
                                 itemRect = iV.frame;
                                 itemRect.origin =
                                  CGPointMake(PB_SCROLL_GAP + _displayIndex*(CGRectGetWidth(_contentScroll.bounds)), itemIndex*44);
                                 [iV setFrame:itemRect];
                                 itemIndex ++;
                             }
                         }
                     }
                     completion:^(BOOL finished) {
                         [weakSelf multiItemsOutboxMoveAway];
                     }
     ];

    
}

- (void)multiItemsOutboxMoveAway {
    [UIView animateWithDuration:.36f
                          delay:.16f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         CGRect itemRect = _defaultRect;
                         for (NSUInteger i = 0; i < [_subItems count]; i++) {
                             
                             if ([_subItems[ i ] isKindOfClass:[PBPassView class]]) {
                                 PBPassView *iV = _subItems[ i ];
                                 itemRect = iV.frame;
                                 
                                 itemRect.origin = CGPointMake(PB_SCROLL_GAP + iV.subIndex*CGRectGetWidth(_contentScroll.bounds), 0);
                                 NSLog(@"%@", NSStringFromCGRect(itemRect));
                                 [iV setFrame:itemRect];
                             }
                         }
                     }
                     completion:^(BOOL finished) {

                     }
     ];
}

- (void)multiItemsToDefaultAnimation {
    [UIView animateWithDuration:.1f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         NSUInteger stackIndex = 0;
                         for (NSUInteger i = 0; i < [_contentScroll subviews].count; i++) {
                             if ([_contentScroll.subviews[ i ] isKindOfClass:[PBPassView class]]) {
                                 PBPassView *iV = _contentScroll.subviews[ i ];
                                 [iV toDefaultWithStackIndex:stackIndex
                                                 currentPage:_displayIndex];
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
        _displayIndex = tmpPage;
        _pageControl.currentPage = _displayIndex;
        
        // Bring current page to front
        NSUInteger stackIndex = [_subItems count] - 1 - _displayIndex;
        if ([_subItems[ stackIndex ] isKindOfClass:[PBPassView class]]) {
            PBPassView *itemV = (PBPassView *)_subItems[ stackIndex ];
            [itemV.superview bringSubviewToFront:itemV ];
        }
    }
}

@end


#pragma mark - PBItemView

@interface PBPassView () {
 @private
    CGRect _defaultRect;
}
@end

@implementation PBPassView

- (id)initWithOrigin:(CGPoint)theOrigin content:(UIView <PBPassViewTapDelegate> *)theView {
    CGRect frame = theView.bounds;
    theView.frame = frame;
    frame.origin = theOrigin;
    
    self = [super initWithFrame:frame];
    if (self) {
        _defaultRect = frame;
        self.contentView = theView;
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

- (void)toDefaultWithStackIndex:(NSUInteger)sIndex currentPage:(NSUInteger)cPage{
    CGRect frame = _defaultRect;
    frame.origin.x = cPage * (CGRectGetWidth(frame) + 2*PB_SCROLL_GAP) + PB_SCROLL_GAP;
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
        if ([self.subviews[ i ] isKindOfClass:[PBPassView class]]) {
            PBPassView *iV = self.subviews[ i ];
            subViewRect = iV.frame;
            subViewRect.size.width = frame.size.width;
            [iV setFrame:subViewRect];
        }
    }
}

@end