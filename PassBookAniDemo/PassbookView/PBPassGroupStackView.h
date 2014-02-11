//
//  PBPassGroupStackView.h
//  IBTDemo
//
//  Created by Xummer on 13-10-29.
//  Copyright (c) 2013年 Xummer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBPassGroupView.h"

/// default acceleration Behaviour is CGGoint{1.0f, 1.0f}
extern CGPoint const PBDefaultAcceleration;

@protocol PBPassGroupStackDataSource;
@interface PBPassGroupStackView : UIScrollView

- (void)updateWithItemsContent:(NSMutableArray *)iContents;

- (id)initWithFrame:(CGRect)frame
         datasource:(id<PBPassGroupStackDataSource>)dataSource;
- (void)reloadData;

- (void)animationToSelectWithPassIndex:(NSUInteger)psIndex;
- (void)animationToDefault;

@end

@protocol PBPassGroupStackDataSource <NSObject>

@required
- (NSUInteger)numberOfPassGroupViews;
- (CGFloat)defaultOffsetYAtStackIndex:(NSUInteger)index;
- (NSArray *)passViewsAtStackIndex:(NSUInteger)index;

@end
