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

@end
