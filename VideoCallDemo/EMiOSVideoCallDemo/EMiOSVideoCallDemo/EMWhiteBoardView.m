//
//  EMWhiteBoardView.m
//  EMiOSVideoCallDemo
//
//  Created by lixiaoming on 2020/6/15.
//  Copyright © 2020 easemob. All rights reserved.
//

#import "EMWhiteBoardView.h"

@implementation EMWhiteBoardView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapAction:)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)handleTapAction:(UITapGestureRecognizer *)aTap
{
    if (aTap.state == UIGestureRecognizerStateEnded) {

        if (_delegate && [_delegate respondsToSelector:@selector(whiteBoardViewDidTap)]) {
            [_delegate whiteBoardViewDidTap];
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

-(void)setWKView:(WKWebView*)wkView
{
    if(wkView)
    {
        [wkView removeFromSuperview];
        [self addSubview:wkView];
        [self sendSubviewToBack:wkView];
        [wkView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    };
}
@end
