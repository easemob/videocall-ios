//
//  SampleHandler.m
//  SharedDesktop
//
//  Created by lixiaoming on 2020/4/24.
//  Copyright © 2020 easemob. All rights reserved.
//


#import "SampleHandler.h"

@implementation SampleHandler

- (void)broadcastStartedWithSetupInfo:(NSDictionary<NSString *,NSObject *> *)setupInfo {
    // User has requested to start the broadcast. Setup info from the UI extension can be supplied but optional.
    NSLog(@"broadcastStartedWithSetupInfo");
    _buffersize = 0;
    _mYuvbuffer = nil;
    self.sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.easemob"];
    [self.sharedDefaults setObject:[NSNumber numberWithInt:0] forKey:@"result"];
    [self.sharedDefaults setObject:[NSNumber numberWithInt:2] forKey:@"status"];
}

- (void)broadcastPaused {
    // User has requested to pause the broadcast. Samples will stop being delivered.
}

- (void)broadcastResumed {
    // User has requested to resume the broadcast. Samples delivery will resume.
}

- (void)broadcastFinished {
    // User has requested to finish the broadcast.
    [self.sharedDefaults setObject:[NSNumber numberWithInt:1] forKey:@"result"];
    if(_mYuvbuffer)
        _mYuvbuffer = nil;
    _buffersize = 0;
}

- (void)bufferToData:(CMSampleBufferRef)source

{
    CMTime t = CMSampleBufferGetPresentationTimeStamp((CMSampleBufferRef)source);
    // 获取yuv数据
    // 通过CMSampleBufferGetImageBuffer方法，获得CVImageBufferRef。
    // 这里面就包含了yuv420(NV12)数据的指针
    CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(source);

    //表示开始操作数据
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);

    //图像宽度（像素）
    size_t pixelWidth = CVPixelBufferGetWidth(pixelBuffer);
    //图像高度（像素）
    size_t pixelHeight = CVPixelBufferGetHeight(pixelBuffer);
    //yuv中的y所占字节数
    size_t y_size = pixelWidth * pixelHeight;
    //yuv中的uv所占的字节数
    size_t uv_size = y_size / 2;

    if(!_mYuvbuffer)
    {
        _mYuvbuffer = malloc(uv_size + y_size);
        _buffersize = uv_size + y_size;
    }else{
        if(uv_size + y_size != _buffersize){
            free(_mYuvbuffer);
            _mYuvbuffer = malloc(uv_size + y_size);
            _buffersize = uv_size + y_size;
        }
    }

    //获取CVImageBufferRef中的y数据
    uint8_t *y_frame = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
    memcpy(_mYuvbuffer, y_frame, y_size);

    //获取CMVImageBufferRef中的uv数据
    uint8_t *uv_frame = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
    memcpy(_mYuvbuffer + y_size, uv_frame, uv_size);
    
    NSData* data = [NSData dataWithBytes:_mYuvbuffer length:(y_size + uv_size)];
    [self.sharedDefaults setObject:data forKey:@"data"];
    [self.sharedDefaults setObject:[NSNumber numberWithInt:pixelWidth] forKey:@"width"];
    [self.sharedDefaults setObject:[NSNumber numberWithInt:pixelHeight] forKey:@"height"];
    [self.sharedDefaults setObject:[NSNumber numberWithLong:t.value] forKey:@"timevalue"];
    [self.sharedDefaults setObject:[NSNumber numberWithInt:t.timescale] forKey:@"timescale"];
    [self.sharedDefaults setObject:[NSNumber numberWithInt:1] forKey:@"status"];
    
    data = nil;

    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
}

- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer withType:(RPSampleBufferType)sampleBufferType {
    switch (sampleBufferType) {
        case RPSampleBufferTypeVideo:
            // Handle video sample buffer
        {
            [self bufferToData:sampleBuffer];
        }
            break;
        case RPSampleBufferTypeAudioApp:
            // Handle audio sample buffer for app audio
            break;
        case RPSampleBufferTypeAudioMic:
            // Handle audio sample buffer for mic audio
            break;
            
        default:
            break;
    }
}

@end
