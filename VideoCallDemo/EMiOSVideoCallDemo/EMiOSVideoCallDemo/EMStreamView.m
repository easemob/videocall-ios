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

@property (nonatomic) int imageCount;

@end

@implementation EMStreamView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _enableVoice = YES;
        self.layer.borderWidth = 0.5;
        self.layer.borderColor = [UIColor grayColor].CGColor;
        self.backgroundColor = [UIColor blackColor];
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
            make.width.lessThanOrEqualTo(@70);
            make.height.lessThanOrEqualTo(@70);
        }];
        
        self.statusView = [[UIImageView alloc] init];
        self.statusView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.statusView];
        
        
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
        self.nickNameLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:self.nickNameLabel];
        
        
        self.adminView = [[UIImageView alloc] init];
        self.adminView.image = [UIImage imageNamed:@"admin"];
        [self.adminView setTintColor:[UIColor blueColor]];

        //self.adminView.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:191/255.0 blue:0/255.0 alpha:1.0].CGColor;
        [self addSubview:self.adminView];
        [self.adminView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.bottom.equalTo(self);
            make.height.equalTo(@20);
            make.width.equalTo(@0);
        }];
        [self.statusView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@20);
            make.top.equalTo(self.adminView.mas_top);
            //make.centerX.multipliedBy(1.8);
            make.left.equalTo(self.adminView.mas_right);
        }];
        [self.nickNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.statusView.mas_right);
            make.top.equalTo(self.adminView.mas_top);
            make.width.equalTo(self);
            make.height.equalTo(@20);
        }];
        
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
        
        [self updateIcons];
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
                _statusView.image = [UIImage imageNamed:@"静音"];
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
                if(!self.timeTimer)
                    self.timeTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timeTalkingAction:) userInfo:nil repeats:YES];
            }
            break;
            
        default:
            {
                if (_enableVoice) {
                    _statusView.image = [UIImage imageNamed:@"静音"];
                    if(self.timeTimer){
                        [self.timeTimer invalidate];
                        self.timeTimer = nil;
                    }
                }
            }
            break;
    }
}

- (void)timeTalkingAction:(id)sender
{
    self.imageCount++;
    self.imageCount %= 12;
    NSString* imageName = [NSString stringWithFormat:@"%02d",12-self.imageCount];
    _statusView.image = [UIImage imageNamed:imageName];
}

- (void)setEnableVoice:(BOOL)enableVoice
{
    _enableVoice = enableVoice;
    
    [self bringSubviewToFront:_statusView];
    if (enableVoice) {
        _statusView.image = [UIImage imageNamed:@"静音"];
    } else {
        if(self.timeTimer){
            [self.timeTimer invalidate];
            self.timeTimer = nil;
        }
        self.status = StreamStatusNormal;
        _statusView.image = [UIImage imageNamed:@"解除静音"];
    }
}

- (void)setEnableVideo:(BOOL)enableVideo
{
    _enableVideo = enableVideo;
    
    if (enableVideo) {
        //[self sendSubviewToBack:_bgView];
        _bgView.hidden = YES;
        //self.nickNameLabel.hidden = YES;
        if(_displayView)
        {
            _displayView.hidden = NO;
            [self sendSubviewToBack:_bgView];
        }
    } else {
        _bgView.hidden = NO;
        if(_displayView)
        {
            _displayView.hidden = YES;
            [self sendSubviewToBack:_displayView];
        }
        //[self sendSubviewToBack:_displayView];
        //self.nickNameLabel.hidden = NO;
    }
    [self updateIcons];
}

-(void)setIsAdmin:(BOOL)isAdmin
{
    _isAdmin = isAdmin;
    [self updateIcons];
}

- (void)setDisplayView:(UIView *)displayView
{
    _displayView = displayView;
    if([_displayView isKindOfClass:[EMCallRemoteView class]]) {
        [self bringSubviewToFront:_activity];
        [_activity startAnimating];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

-(void)setIsBigView:(BOOL)isBigView
{
    _isBigView = isBigView;
    [self updateIcons];
}

-(void)updateIcons{
    int adminViewWidth = _isAdmin?16:0;
    if(_isBigView){
        if(!_enableVideo){
            [self.adminView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.bgView.mas_bottom);
                make.centerX.equalTo(self).with.offset(-30);
                make.height.equalTo(@16);
                make.width.equalTo(@(adminViewWidth));
            }];
            [self.nickNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.statusView.mas_right);
                make.top.equalTo(self.adminView.mas_top);
                make.width.lessThanOrEqualTo(@80);
                make.height.equalTo(@16);
            }];
            [self.statusView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(@16);
                make.height.equalTo(@16);
                make.top.equalTo(self.adminView.mas_top);
                //make.centerX.multipliedBy(1.8);
                make.left.equalTo(self.adminView.mas_right);
            }];
            
        }else{
            [self.adminView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self);
                make.top.equalTo(self);
                make.height.equalTo(@16);
                make.width.equalTo(@(adminViewWidth));
            }];
            [self.statusView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(@16);
                make.height.equalTo(@16);
                make.top.equalTo(self.adminView.mas_top);
                //make.centerX.multipliedBy(1.8);
                make.left.equalTo(self.adminView.mas_right);
            }];
            [self.nickNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.statusView.mas_right);
                make.top.equalTo(self.adminView.mas_top);
                make.right.lessThanOrEqualTo(self);
                make.height.equalTo(@20);
            }];
        }
    }else{
        [self.adminView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.bottom.equalTo(self);
            make.height.equalTo(@16);
            make.width.equalTo(@(adminViewWidth));
        }];
        [self.statusView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@16);
            make.height.equalTo(@16);
            make.top.equalTo(self.adminView.mas_top);
            //make.centerX.multipliedBy(1.8);
            make.left.equalTo(self.adminView.mas_right);
        }];
        [self.nickNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.statusView.mas_right);
            make.top.equalTo(self.adminView.mas_top);
            make.right.lessThanOrEqualTo(self);
            make.height.equalTo(@20);
        }];
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
