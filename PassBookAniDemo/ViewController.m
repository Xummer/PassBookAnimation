//
//  ViewController.m
//  PassBookAniDemo
//
//  Created by Xummer on 13-11-15.
//  Copyright (c) 2013年 Xummer. All rights reserved.
//

#import "ViewController.h"
#import "PBPassGroupStackView.h"

@interface ViewController () < PBPassGroupDataSource >
@property(nonatomic, strong) PBPassGroupStackView *passbookView;
@property(nonatomic, strong) NSMutableArray *pbData;

@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupPBDataSource];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    if (!_passbookView) {
        
        
        CGRect frame = self.view.bounds;
        CGFloat maxY = (([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)\
                        ? 20 : 0);
        frame.origin.y += maxY;
        frame.size.height -= maxY;
        
        self.passbookView =
        [[PBPassGroupStackView alloc] initWithFrame:frame datasource:self];
        [self.view addSubview:_passbookView];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupPBDataSource {
    NSMutableArray *iContents = [[NSMutableArray alloc] init];
    
    CGRect frame = CGRectMake(0, 0, 320, __DEVICE_SCREEN_SIZE_5 ? 458 : 370 );
    
    NSUInteger subItemsCount = 1;
    NSArray *collors =
    @[
      [UIColor colorWithRed:225.0f/255.0f green:230.0f/255.0f blue:227.0f/255.0f alpha:1],
      [UIColor colorWithRed:107.0f/255.0f green:154.0f/201.0f blue:227.0f/255.0f alpha:1],
      [UIColor colorWithRed:46.0f/255.0f green:98.0f/201.0f blue:205.0f/255.0f alpha:1],
      [UIColor colorWithRed:121.0f/255.0f green:210.0f/201.0f blue:210.0f/255.0f alpha:1]
      ];
    for (int i = 0; i < 4; i++) {
        switch (i) {
            case 2:
                subItemsCount = 4;
                break;
            default:
            {
                subItemsCount = 1;
            }
                break;
        }
        
        NSMutableArray *subItems = [[NSMutableArray alloc] init];
        UIView *itemV = nil;
        for (int j = 0; j < subItemsCount; j ++) {
            
            itemV = [[UIView alloc] initWithFrame:frame];
            itemV.layer.cornerRadius = 5;
            itemV.layer.borderColor = [UIColor whiteColor].CGColor;
            itemV.layer.borderWidth = 1;
            itemV.backgroundColor = collors[ i % 4 ];
            
            UILabel *label = [[UILabel alloc] initWithFrame:itemV.bounds];
            label.backgroundColor = [UIColor clearColor];
            label.font = [UIFont systemFontOfSize:56];
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor whiteColor];
            label.text = [NSString stringWithFormat:@"%d - %d", i+1, j+1];
            [itemV addSubview:label];
            
            if (itemV) {
                itemV.tag = j;
                [subItems addObject:itemV];
            }
        }
        
        [iContents addObject:subItems];
    }
    
    self.pbData = iContents;
}


#pragma mark - PassBook View Delegate
- (NSUInteger)numberOfPassbookViews {
    return [_pbData count];
}

- (NSArray *)contentViewsAtStackIndex:(NSUInteger)index {
    if ([_pbData[ index ] isKindOfClass:[NSArray class]]) {
        return _pbData[ index ];
    }
    
    return nil;
}

- (CGFloat)defaultOffsetYAtStackIndex:(NSUInteger)sIndex {
    
    CGFloat offsetY = 0;
    UIScreen *screen = [UIScreen mainScreen];
    CGFloat height =
    screen.currentMode.size.height / screen.scale - 64;
    CGFloat unitGap = height / 4;
    offsetY = unitGap * sIndex;
    
    return offsetY;
}


@end
