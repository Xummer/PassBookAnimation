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

@protocol PBPassGroupDataSource;
@interface PBPassGroupStackView : UIScrollView

- (void)updateWithItemsContent:(NSMutableArray *)iContents;

- (id)initWithFrame:(CGRect)frame
         datasource:(id<PBPassGroupDataSource>)dataSource;
- (void)reloadData;

- (void)animationToSelectWithItemIndex:(NSUInteger)itIndex;
- (void)animationToDefault;

@end

@protocol PBPassGroupDataSource <NSObject>

@required
- (NSUInteger)numberOfPassbookViews;
- (CGFloat)defaultOffsetYAtStackIndex:(NSUInteger)index;
- (NSArray *)contentViewsAtStackIndex:(NSUInteger)index;

@end
