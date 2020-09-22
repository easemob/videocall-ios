//
//  SharedDesktopViewController.m
//  EMiOSVideoCallDemo
//
//  Created by lixiaoming on 2020/9/9.
//  Copyright © 2020 easemob. All rights reserved.
//

#import "SharedDesktopViewController.h"

@interface SharedDesktopViewController ()
@property (nonatomic) UIView* sharedDesktopView;
@property (nonatomic) UISwipeGestureRecognizer * recognizer;
@end

@implementation SharedDesktopViewController

-(instancetype)initWithSharedDesktopView:(UIView*)view
{
    self = [super init];
    if(self) {
        self.sharedDesktopView = view;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupSubViews];
}

-(void)setupSubViews{
    _sharedDesktopView.frame = CGRectMake(0, 0, 300, 400);
    [self.view addSubview:_sharedDesktopView];
    [_sharedDesktopView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    self.recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [self.recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight)];
    [self.view addGestureRecognizer:self.recognizer];
    
//    _activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
//    [self.view addSubview:_activity];
//    [_activity mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self.view);
//    }];
//    [_activity startAnimating];
//    _activity.hidesWhenStopped = YES;
}

- (void)handleSwipeFrom:(UISwipeGestureRecognizer*)recognizer
{
    [self.navigationController popViewControllerAnimated:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
