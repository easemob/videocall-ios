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
        self.nameLabel = [[UILabel alloc] init];
        self.nameLabel.textColor = [UIColor redColor];
        self.nameLabel.font = [UIFont systemFontOfSize:18];
        self.nameLabel.numberOfLines = 0;
        self.nameLabel.text = @"白板";
        [self addSubview:self.nameLabel];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.width.equalTo(@100);
            make.height.equalTo(@40);
        }];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapAction:)];
        
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
@end
