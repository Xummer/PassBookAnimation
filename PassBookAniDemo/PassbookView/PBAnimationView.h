//
//  PBAnimationView.h
//  IBTDemo
//
//  Created by Xummer on 13-10-29.
//  Copyright (c) 2013年 Xummer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBContainerView.h"

/// default acceleration Behaviour is CGGoint{1.0f, 1.0f}
extern CGPoint const PBDefaultAcceleration;

@interface PBAnimationView : UIScrollView

- (id)initWithFrame:(CGRect)frame andItemsContent:(NSMutableArray *)iContents;
- (void)updateWithItemsContent:(NSMutableArray *)iContents;

@end
