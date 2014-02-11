//
//  PBPassFrontFaceView.h
//  PassBookAniDemo
//
//  Created by Xummer on 14-2-10.
//  Copyright (c) 2014年 Xummer. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PBPassViewTapDelegate;

@interface PBPassFrontFaceView : UIView
@property (assign, nonatomic) BOOL isOnlyShowTop;
@property (strong, nonatomic) UIView <PBPassViewTapDelegate> *bodyCustomView;

- (id)initWithCustomView:(UIView <PBPassViewTapDelegate> *)customView
               backImage:(UIImage *)image;

- (id)init;
- (void)updateWithCustomView:(UIView <PBPassViewTapDelegate> *)customView
                   backImage:(UIImage *)image;
@end
