//
//  YERecordVoiceTool.h
//  YERecordingVoicePlay
//
//  Created by yongen on 17/3/20.
//  Copyright © 2017年 yongen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class YERecordVoiceTool;
@protocol YERecordVoiceToolDelegate <NSObject>

@optional
- (void)recordTool:(YERecordVoiceTool *)recordTool didstartRecoring:(int)updateimage;

@end
@interface YERecordVoiceTool : NSObject

//更新图片代理
@property (nonatomic, strong) id <YERecordVoiceToolDelegate>delegate;
//录音tool
+ (instancetype)sharedRecordTool;
//开始录音
- (void)startRecording;
//停止录音
- (void)stopRecording;
//播放录音文件
- (void)playRecordingFile;
//停止播放录音文件
- (void)stopPlaying;
//销毁录音文件
- (void)destructionRecordingFile;

//录音对象
@property (nonatomic, strong) AVAudioRecorder *recorder;
//播放对象
@property (nonatomic, strong) AVAudioPlayer *player;

@end
