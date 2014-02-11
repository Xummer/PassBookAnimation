//
//  PBContainerView.h
//  HappyTreasure
//
//  Created by Xummer on 13-11-14.
//  Copyright (c) 2013年 Mars. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBPassFrontFaceView.h"

#define TOP_GAP             (__DEVICE_SCREEN_SIZE_5 ? 27 : 5)
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
@property (assign, nonatomic) PBPassState presentationState;
@property (assign, nonatomic) id<PBPassGroupDelegate> pbDelegate;

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

@interface PBPassView : UIView
@property (assign, nonatomic) NSUInteger subIndex;
@property (assign, nonatomic) NSUInteger subCount;
@property (strong, nonatomic) PBPassFrontFaceView *frontFaceView;;

- (id)initWithOrigin:(CGPoint)theOrigin
          customView:(UIView <PBPassViewTapDelegate> *)theView
             backImg:(UIImage *)backImg;
- (void)toDefaultWithStackIndex:(NSUInteger)sIndex currentPage:(NSUInteger)cPage;
@end

@protocol PBPassViewTapDelegate <NSObject>

@optional
- (BOOL)sholdHandleItemTap:(UITapGestureRecognizer *)tap item:(PBPassView *)itemV;
@end
