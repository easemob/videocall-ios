//
//  EMDemoOption.h
//  EMiOSVideoCallDemo
//
//  Created by lixiaoming on 2020/2/10.
//  Copyright © 2020 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMDemoOption : NSObject
typedef NS_ENUM(int,EMResolutionRate) {
    ResolutionRate_720p,
    ResolutionRate_480p,
    ResolutionRate_360p
};
@property (nonatomic, copy) NSString *appkey;
@property (nonatomic) BOOL specifyServer;
@property (nonatomic, assign) int chatPort;
@property (nonatomic, copy) NSString *chatServer;
@property (nonatomic, copy) NSString *restServer;
@property (nonatomic, copy) NSString *userid;
@property (nonatomic, copy) NSString *pswd;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *headImage;
@property (nonatomic) BOOL openCamera;
@property (nonatomic) BOOL openMicrophone;
@property (nonatomic) EMResolutionRate resolutionrate;
@property (nonatomic) NSString* roomName;
@property (nonatomic) NSString* roomPswd;
@property (nonatomic) EMCallConference* conference;
@property (nonatomic) NSMutableDictionary* headImageDic;

+ (instancetype)sharedOptions;
- (void)archive;

@end

NS_ASSUME_NONNULL_END
