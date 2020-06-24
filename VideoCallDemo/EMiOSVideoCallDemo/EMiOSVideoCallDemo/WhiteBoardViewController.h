//
//  WhiteBoardViewController.h
//  EMiOSVideoCallDemo
//
//  Created by lixiaoming on 2020/6/15.
//  Copyright © 2020 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WhiteBoardViewController : UIViewController
- (instancetype)initWithWBUrl:(EMWhiteboard*)wb WKView:(WKWebView*)wkView;
-(void)back;
@end

NS_ASSUME_NONNULL_END
