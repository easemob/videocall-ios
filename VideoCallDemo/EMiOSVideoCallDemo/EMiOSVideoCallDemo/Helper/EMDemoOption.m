//
//  EMDemoOption.m
//  EMiOSVideoCallDemo
//
//  Created by lixiaoming on 2020/2/10.
//  Copyright © 2020 easemob. All rights reserved.
//

#import "EMDemoOption.h"
static EMDemoOption *sharedOptions = nil;
NSString* kUserid = @"userid";
NSString* kPswd = @"pwsd";
NSString* kCamera = @"camera";
NSString* kMicrophone = @"microphone";
NSString* kResolution = @"resoltionrate";
NSString* kNickname = @"nickname";
NSString* kHeadImage = @"headimage";
NSString* kCDN = @"cdn";
NSString* kCDNUrl = @"cdnUrl";
NSString* kRecord = @"record";
NSString* kMerge = @"merge";
NSString* kBackCamera = @"backCamera";
NSString* kLivePureAudio = @"livePureAudio";
NSString* kSpecifyServer = @"specifyServer";
NSString* kIsClarityFirst = @"isClarityFirst";
NSString* kIsJoinAsAudience = @"isJoinAsAudience";
@implementation EMDemoOption
-(instancetype)init{
    EMDemoOption* p = [super init];
    if(p){
        [p initServerOptions];
    }
    return p;
}
- (void)initServerOptions
{
    self.appkey = @"easemob-demo#chatdemoui";
    self.specifyServer = NO;
    self.chatServer = @"116.85.43.118";
    self.chatPort = 6717;
    self.restServer = @"a1-hsb.easemob.com";
    self.openCamera = YES;
    self.openMicrophone = YES;
    self.resolutionrate = ResolutionRate_480p;
    self.nickName = @"";
    self.cdnUrl = @"";
    self.isMerge = NO;
    self.isRecord = NO;
    self.isBackCamera = NO;
    self.liveWidth = 640;
    self.liveHeight = 480;
    self.livePureAudio = NO;
    self.recordExt = RecordExtAUTO;
    self.isClarityFirst = NO;
    self.isJoinAsAudience = NO;
}

- (void)archive
{
    NSString *fileName = @"emdemo_options.data";
    NSString *file = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:fileName];
    [NSKeyedArchiver archiveRootObject:self toFile:file];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.userid forKey:kUserid];
    [aCoder encodeObject:self.pswd forKey:kPswd];
    [aCoder encodeBool:self.openCamera forKey:kCamera];
    [aCoder encodeBool:self.openMicrophone forKey:kMicrophone];
    [aCoder encodeInt:self.resolutionrate forKey:kResolution];
    [aCoder encodeObject:self.nickName forKey:kNickname];
    [aCoder encodeObject:self.headImage forKey:kHeadImage];
    [aCoder encodeBool:self.openCDN forKey:kCDN];
    [aCoder encodeBool:self.isRecord forKey:kRecord];
    [aCoder encodeBool:self.isMerge forKey:kMerge];
    [aCoder encodeBool:self.isBackCamera forKey:kBackCamera];
    [aCoder encodeObject:self.cdnUrl forKey:kCDNUrl];
    [aCoder encodeBool:self.livePureAudio forKey:kLivePureAudio];
    [aCoder encodeBool:self.specifyServer forKey:kSpecifyServer];
    [aCoder encodeBool:self.isClarityFirst forKey:kIsClarityFirst];
    [aCoder encodeBool:self.isJoinAsAudience forKey:kIsJoinAsAudience];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        [self initServerOptions];
        self.userid = [aDecoder decodeObjectForKey:kUserid];
        self.pswd = [aDecoder decodeObjectForKey:kPswd];
        self.openCamera = [aDecoder decodeBoolForKey:kCamera];
        self.openMicrophone = [aDecoder decodeBoolForKey:kMicrophone];
        int reso = [aDecoder decodeIntForKey:kResolution];
        self.resolutionrate = reso + ResolutionRate_720p;
        self.nickName = [aDecoder decodeObjectForKey:kNickname];
        self.headImage = [aDecoder decodeObjectForKey:kHeadImage];
        self.cdnUrl = [aDecoder decodeObjectForKey:kCDNUrl];
        self.openCDN = [aDecoder decodeBoolForKey:kCDN];
        self.isRecord = [aDecoder decodeBoolForKey:kRecord];
        self.isMerge = [aDecoder decodeBoolForKey:kMerge];
        self.isBackCamera = [aDecoder decodeBoolForKey:kBackCamera];
        self.livePureAudio = [aDecoder decodeBoolForKey:kLivePureAudio];
        self.specifyServer = [aDecoder decodeBoolForKey:kSpecifyServer];
        self.isClarityFirst = [aDecoder decodeBoolForKey:kIsClarityFirst];
        self.isJoinAsAudience = [aDecoder decodeBoolForKey:kIsJoinAsAudience];
    }
    return self;
}

+ (instancetype)sharedOptions
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedOptions = [EMDemoOption getOptionsFromLocal];
    });
    
    return sharedOptions;
}

+ (instancetype)getOptionsFromLocal
{
    EMDemoOption *retModel = nil;
    NSString *fileName = @"emdemo_options.data";
    NSString *file = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:fileName];
    retModel = [NSKeyedUnarchiver unarchiveObjectWithFile:file];
    if (!retModel) {
        retModel = [[EMDemoOption alloc] init];
        [retModel archive];
    }
    
    return retModel;
}

-(void)setTheSpecifyServer:(BOOL)specifyServer
{
    if(self.specifyServer != specifyServer) {
        if([[EMClient sharedClient] isLoggedIn])
            [[EMClient sharedClient] logout:NO completion:^(EMError *aError) {
                
            }];
        self.specifyServer = specifyServer;
        self.userid = @"";
        self.pswd = @"";
    }
}

@end
