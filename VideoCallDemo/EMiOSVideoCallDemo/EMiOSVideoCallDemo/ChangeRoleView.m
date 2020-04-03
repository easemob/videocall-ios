//
//  ChangeRoleView.m
//  EMiOSVideoCallDemo
//
//  Created by lixiaoming on 2020/3/17.
//  Copyright © 2020 easemob. All rights reserved.
//

#import "ChangeRoleView.h"
#import "KickSpeakerViewController.h"
#import "EMDemoOption.h"

@interface ChangeRoleView()
@property (nonatomic) BOOL isKicker;
@end
@implementation ChangeRoleView

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
        [self setupView];
    }
    return self;
}

- (void)setupView
{
    self.isKicker = NO;
    self.kickMem = nil;
    self.layer.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.6].CGColor;
    self.layer.cornerRadius = 4;
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 32, 32)];
    self.imageView.image = [UIImage imageNamed:@"Ask"];
    [self addSubview:self.imageView];
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(40, 6, 84, 16);
    label.numberOfLines = 0;

    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"小仙女小可爱"attributes: @{NSFontAttributeName: [UIFont fontWithName:@"Arial" size: 14],NSForegroundColorAttributeName: [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0]}];

    label.attributedText = string;
    label.textAlignment = NSTextAlignmentLeft;
    label.alpha = 1.0;
    self.name = label;
    [self addSubview:self.name];
    
    self.desc = [[UILabel alloc] init];
    self.desc.frame = CGRectMake(56,26,84,12);
    self.desc.numberOfLines = 0;
    [self addSubview:self.desc];

    NSMutableAttributedString *descstring = [[NSMutableAttributedString alloc] initWithString:@"申请上麦"attributes: @{NSFontAttributeName: [UIFont fontWithName:@"Arial" size: 10],NSForegroundColorAttributeName: [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0]}];

    self.desc.attributedText = descstring;
    self.desc.textAlignment = NSTextAlignmentLeft;
    self.desc.alpha = 0.6;
    
    self.leftButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.leftButton.frame = CGRectMake(10, 50, 76, 36);
    [self.leftButton setBackgroundColor:[UIColor redColor]];
    [self.leftButton setTitle:@"拒绝" forState:UIControlStateNormal];
    [self.leftButton setTintColor:[UIColor whiteColor]];
    self.leftButton.layer.cornerRadius = 18;
    [self.leftButton addTarget:self action:@selector(RefuseAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.leftButton];
    
    self.rightButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.rightButton.frame = CGRectMake(92, 50, 76, 36);
    [self.rightButton setBackgroundColor:[UIColor colorWithRed:0/255.0 green:175/255.0 blue:239/255.0 alpha:1.0]];
    [self.rightButton setTitle:@"批准" forState:UIControlStateNormal];
    [self.rightButton setTintColor:[UIColor whiteColor]];
    self.rightButton.layer.cornerRadius = 18;
    [self.rightButton addTarget:self action:@selector(AllowAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.rightButton];
}

- (void)RefuseAction
{
    self.desc.text = @"上麦申请已拒绝";
    [self.desc setFont:self.name.font];
    self.leftButton.hidden = YES;
    self.rightButton.hidden = YES;
    [self exit];
}

- (void)changeToKicker
{
    self.imageView.image = [UIImage imageNamed:@"Warning"];
    self.desc.text = @"";
    self.name.text = @"主播已满选人下麦?";
    [self.leftButton setBackgroundColor:[UIColor whiteColor]];
    [self.leftButton setTitle:@"返回" forState:UIControlStateNormal];
    [self.leftButton setTintColor:[UIColor blackColor]];
    [self.rightButton setTitle:@"选人下麦" forState:UIControlStateNormal];
}

- (void)AllowAction
{
    if(_isKicker) {
        if(_kickMem)
            _kickMem(self.name.text);
        [self removeFromSuperview];
        return;
    }
    __weak typeof(self) weakself = self;
    [[[EMClient sharedClient] conferenceManager] changeMemberRoleWithConfId:[EMDemoOption sharedOptions].conference.confId memberNames:@[self.memName] role:EMConferenceRoleSpeaker completion:^(EMError *aError) {
        if(aError){
            if(aError.code == EMErrorCallSpeakerFull) {
                weakself.isKicker = YES;
                [weakself changeToKicker];
            }else{
                self.desc.text = @"上麦失败";
                [self.desc setFont:self.name.font];
                self.leftButton.hidden = YES;
                self.rightButton.hidden = YES;
                [weakself exit];
            }
        }else{
            self.desc.text = @"上麦成功";
            [self.desc setFont:self.name.font];
            self.leftButton.hidden = YES;
            self.rightButton.hidden = YES;
            [weakself exit];
        }
    }];
}

-(void)exit
{
    [[[EMClient sharedClient] conferenceManager] deleteAttributeWithKey:self.name.text completion:^(EMError *aError) {
        
    }];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 44);
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self layoutIfNeeded];
        [self setNeedsUpdateConstraints];
        self.frame = CGRectMake(-200, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
        [UIView animateWithDuration:0.3 animations:^{
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    });
}

@end
