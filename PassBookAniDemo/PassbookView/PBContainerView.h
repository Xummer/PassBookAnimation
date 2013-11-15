//
//  PBContainerView.h
//  HappyTreasure
//
//  Created by Xummer on 13-11-14.
//  Copyright (c) 2013年 Mars. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TOP_GAP             0
#define BOTTOM_GAP          5
#define BOX_BANNER_HEIGHT   50
#define BOX_GAP             5

typedef NS_ENUM(NSInteger, PBItemState) {
    kPBDefualt = 0,
    kPBInBox,
    kPBOutBox,
};

@protocol PBContainerDelegate;
@interface PBContainerView : UIView
@property(nonatomic, assign) PBItemState itemState;
@property(nonatomic, assign) id<PBContainerDelegate> pbDelegate;

- (void)updateContents:(NSArray *)data;
- (void)setInBoxIndex:(NSUInteger)index itemsCount:(NSUInteger)count;
- (void)animationToState:(PBItemState)state ;

@end

@protocol PBContainerDelegate <NSObject>

@optional
- (void)handleTap:(UITapGestureRecognizer *)tap item:(PBContainerView *)itemV;
@end

@interface PBItemView : UIView
@property(nonatomic, assign) NSUInteger subIndex;
@property(nonatomic, assign) NSUInteger subCount;
- (id)initWithOrigin:(CGPoint)theOrigin content:(UIView *)theView;
- (void)toDefualtWithStackIndex:(NSUInteger)sIndex currentPage:(NSUInteger)cPage;
@end

@interface PBScrollView : UIScrollView

@end
