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

typedef NS_ENUM(NSInteger, PBPassState) {
    kPBDefault = 0,
    kPBInBox,
    kPBOutBox,
};

@protocol PBPassGroupDelegate;
@interface PBPassGroupView : UIView
@property(nonatomic, assign) PBPassState presentationState;
@property(nonatomic, assign) id<PBPassGroupDelegate> pbDelegate;

- (id)initWithFrame:(CGRect)frame tapEnable:(BOOL)enable;
- (void)enableSubViewsTap:(BOOL)eableTap;
- (void)updateContents:(NSArray *)data;
- (void)setInBoxIndex:(NSUInteger)index itemsCount:(NSUInteger)count;
- (void)animationToState:(PBPassState)state;

@end

@protocol PBPassGroupDelegate <NSObject>

@optional
- (void)handleTap:(UITapGestureRecognizer *)tap item:(PBPassGroupView *)itemV;
@end

@protocol PBPassViewTapDelegate;
@interface PBPassView : UIView
@property(nonatomic, assign) NSUInteger subIndex;
@property(nonatomic, assign) NSUInteger subCount;
@property(nonatomic, strong) UIView <PBPassViewTapDelegate> *contentView;
- (id)initWithOrigin:(CGPoint)theOrigin content:(UIView <PBPassViewTapDelegate> *)theView;
- (void)toDefaultWithStackIndex:(NSUInteger)sIndex currentPage:(NSUInteger)cPage;
@end

@protocol PBPassViewTapDelegate <NSObject>

@optional
- (BOOL)sholdHandleItemTap:(UITapGestureRecognizer *)tap item:(PBPassView *)itemV;
@end

@interface PBScrollView : UIScrollView

@end
