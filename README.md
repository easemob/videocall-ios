# videocall-ios
--------
## 简介
本Demo展示了怎么使用环信SDK创建一个简易多人音视频Demo，可以进行音频、视频会话，上麦、下麦互动。

## demo运行

1.安装cocoapods

```
sudo gem install cocoapods
```
2.安装成功后, 运行Podfile

```
cd ./VideoCallDemo/EMiOSVideoCallDemo

pod install

```
3.点击iOSVideoCallDemo.xcworkspace进入Demo

## 代码结构
多人音视频Demo主要包含3个target，SharedDesktop和SharedDesktopSetupUI用于实现共享桌面功能，EMiOSVideoCallDemo是注意target，实现类如下：

RoomJoinViewController 加入房间页面

ConferenceViewController 视频展示页面

AccountSettingViewController 个人设置页面

RoomSettingViewController 房间设置页面

SpeakerListViewController 主播列表页面

KickSpeakerViewController 选人下麦页面

EMStreamView                   视频小窗口类

EMDemoOption                   会议管理类，存储会议的设置和单例属性

ChangeRoleView                 管理员处理上麦申请页面

ProfileVidwController          个人资料页面

UpdateNicknameViewController   修改昵称页面

SelectHeadImageViewController  修改头像页面


## 集成文档
多人音视频集成文档参见官方文档：http://docs-im.easemob.com/im/ios/basics/multiuserconference
