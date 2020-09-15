//
//  EMStreamView.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/9/20.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "EMStreamView.h"

@interface EMStreamView()

@property (nonatomic, strong) UIImageView *statusView;

@property (nonatomic, strong) UIImageView* adminView;

@end

@implementation EMStreamView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _enableVoice = YES;
        self.layer.borderWidth = 0.5;
        self.layer.borderColor = [UIColor grayColor].CGColor;
        self.backgroundColor = [UIColor grayColor];
        self.bgView = [[UIImageView alloc] init];
        self.bgView.contentMode = UIViewContentModeScaleAspectFit;
        self.bgView.userInteractionEnabled = YES;
        UIImage *image = [UIImage imageNamed:@"bg_connecting"];
        self.bgView.image = image;
        [self addSubview:self.bgView];
        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            //make.edges.equalTo(self);
            make.centerX.equalTo(self);
            make.centerY.equalTo(self).with.offset(-5);
            make.width.lessThanOrEqualTo(@75);
            make.height.lessThanOrEqualTo(@75);
        }];
        
        self.statusView = [[UIImageView alloc] init];
        self.statusView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.statusView];
        [self.statusView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@20);
            make.centerY.equalTo(self).multipliedBy(0.1);
            make.centerX.multipliedBy(1.8);
        }];
        
        self.nameLabel = [[UILabel alloc] init];
        self.nameLabel.textColor = [UIColor redColor];
        self.nameLabel.font = [UIFont systemFontOfSize:10];
        self.nameLabel.numberOfLines = 0;
        [self addSubview:self.nameLabel];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(12);
            make.left.equalTo(self).offset(5);
            make.width.equalTo(@90);
        }];
        self.nameLabel.hidden = YES;
        
        self.nickNameLabel = [[UILabel alloc] init];
        self.nickNameLabel.textColor = [UIColor whiteColor];
        self.nickNameLabel.font = [UIFont systemFontOfSize:16];
        self.nickNameLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.nickNameLabel];
        [self.nickNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self.bgView.mas_bottom);
            make.width.equalTo(self);
            make.height.equalTo(@20);
        }];
        
        self.adminView = [[UIImageView alloc] init];
        self.adminView.image = [UIImage imageNamed:@"admin"];
        [self.adminView setTintColor:[UIColor blueColor]];

        //self.adminView.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:191/255.0 blue:0/255.0 alpha:1.0].CGColor;
        [self addSubview:self.adminView];
        [self.adminView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self).multipliedBy(0.1);
            make.centerY.equalTo(self);
            make.height.equalTo(@20);
            make.width.equalTo(@20);
        }];
        self.adminView.hidden = YES;
        
        _activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        [self addSubview:_activity];
        [_activity mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        _activity.hidesWhenStopped = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapAction:)];
        
        [self addGestureRecognizer:tap];
        
        [self bringSubviewToFront:_nameLabel];
        
        [self bringSubviewToFront:_nickNameLabel];
        
        [self bringSubviewToFront:_adminView];
        
        _isLockedBgView = NO;
    }
    
    return self;
}

- (void)setStatus:(StreamStatus)status
{
    if (_status == status) {
        return;
    }
    
    _status = status;
    [self bringSubviewToFront:_statusView];
    
    switch (_status) {
        case StreamStatusConnecting:
        {
            if (_enableVoice) {
                _statusView.image = [UIImage imageNamed:@"ring_gray"];
            }
        }
            break;
        case StreamStatusConnected:
        {
            if (_enableVoice) {
                _statusView.image = nil;
            }
            if(_activity.isAnimating) {
                [_activity stopAnimating];
            }
//
//            if (!self.isLockedBgView) {
//                UIImage*image = [UIImage imageNamed:@"bg_micro"];
//                _bgView.image = image;
//            }
        }
            break;
        case StreamStatusTalking:
            if (_enableVoice) {
                _statusView.image = [UIImage imageNamed:@"talking_green"];
            }
            break;
            
        default:
            {
                if (_enableVoice) {
                    _statusView.image = nil;
                }
            }
            break;
    }
}

- (void)setEnableVoice:(BOOL)enableVoice
{
    _enableVoice = enableVoice;
    
    [self bringSubviewToFront:_statusView];
    if (enableVoice) {
        _statusView.image = nil;
    } else {
        self.status = StreamStatusNormal;
        _statusView.image = [UIImage imageNamed:@"mute_red"];
    }
}

- (void)setEnableVideo:(BOOL)enableVideo
{
    _enableVideo = enableVideo;
    
    if (enableVideo) {
        //[self sendSubviewToBack:_bgView];
        _bgView.hidden = YES;
        self.nickNameLabel.hidden = YES;
    } else {
        _bgView.hidden = NO;
        [self sendSubviewToBack:_displayView];
        self.nickNameLabel.hidden = NO;
    }
}

-(void)setIsAdmin:(BOOL)isAdmin
{
    _isAdmin = isAdmin;
    self.adminView.hidden = !isAdmin;
}

- (void)setDisplayView:(UIView *)displayView
{
    _displayView = displayView;
    if([_displayView isKindOfClass:[EMCallRemoteView class]]) {
        [self bringSubviewToFront:_activity];
        [_activity startAnimating];
    }
}

#pragma mark - UITapGestureRecognizer

- (void)handleTapAction:(UITapGestureRecognizer *)aTap
{
    if (aTap.state == UIGestureRecognizerStateEnded) {

        if (_delegate && [_delegate respondsToSelector:@selector(streamViewDidTap:)]) {
            [_delegate streamViewDidTap:self];
        }
    }
}

@end


@implementation EMStreamItem

@end
