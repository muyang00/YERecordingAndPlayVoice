//
//  YERecordVoiceTool.m
//  YERecordingVoicePlay
//
//  Created by yongen on 17/3/20.
//  Copyright © 2017年 yongen. All rights reserved.
//

#import "YERecordVoiceTool.h"

#define YERecordFielName @"record.caf"

@interface YERecordVoiceTool ()<AVAudioRecorderDelegate>

//录音文件地址
@property (nonatomic, strong) NSURL *recordFileUrl;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) AVAudioSession *session;

@property (nonatomic, assign) CGFloat timeCount;
@property (nonatomic, assign) CGFloat timeMargin;

@end

@implementation YERecordVoiceTool

- (void)startRecording {
    // 录音时停止播放 删除曾经生成的文件
    [self stopPlaying];
    [self destructionRecordingFile];
    
    // 真机环境下需要的代码
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *sessionError;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    
    if(session == nil)
        NSLog(@"Error creating session: %@", [sessionError description]);
    else
        [session setActive:YES error:nil];
    
    self.session = session;
    
    [self.recorder record];
    
    CGFloat signleTime = 0.5;
    self.timeCount = 0;
    self.timeMargin = signleTime;
    NSTimer *timer = [NSTimer timerWithTimeInterval:signleTime target:self selector:@selector(updateImage) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    [timer fire];
   
    self.timer = timer;
}

- (void)updateImage {
    
    [self.recorder updateMeters];
//    double lowPassResults = pow(10, (0.05 * [self.recorder peakPowerForChannel:0]));
//    float result  = 10 * (float)lowPassResults;
     self.timeCount += self.timeMargin;
    int no = 0;
   // no+= 0.5;
    
    if (self.timeCount == 0.5) {
        no = 1;
    } else if (self.timeCount == 1.0) {
        no = 2;
    } else if (self.timeCount == 1.5) {
        no = 3;
    } else if (self.timeCount == 2.0) {
        no = 4;
    } else if (self.timeCount == 2.5) {
        no = 5;
    } else if (self.timeCount == 3.0) {
        no = 6;
    } else if (self.timeCount == 3.5) {
        no = 7;
    }else if (self.timeCount > 3.5){
        no = 7;
    }
      NSLog(@"self.timeMargin ---- %f ,, no --- %d, self.timeCount -- %f", self.timeMargin, no,  self.timeCount);
    if ([self.delegate respondsToSelector:@selector(recordTool:didstartRecoring:)]) {
        [self.delegate recordTool:self didstartRecoring: no];
    }
}

- (void)stopRecording {
    if ([self.recorder isRecording]) {
        [self.recorder stop];
        [self.timer invalidate];
    }
}

- (void)playRecordingFile {
    // 播放时停止录音
    [self.recorder stop];
    
    // 正在播放就返回
    if ([self.player isPlaying]) return;
    
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.recordFileUrl error:NULL];
    [self.session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [self.player play];
}

- (void)stopPlaying {
    [self.player stop];
}

static id instance;
#pragma mark - 单例
+ (instancetype)sharedRecordTool {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            instance = [[self alloc] init];
        }
    });
    return instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            instance = [super allocWithZone:zone];
        }
    });
    return instance;
}

#pragma mark - 懒加载
- (AVAudioRecorder *)recorder {
    if (!_recorder) {
        
        // 1.获取沙盒地址
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *filePath = [path stringByAppendingPathComponent:YERecordFielName];
        self.recordFileUrl = [NSURL fileURLWithPath:filePath];
        NSLog(@"filePath ---- %@", filePath);
        
        // 3.设置录音的一些参数
        NSMutableDictionary *setting = [NSMutableDictionary dictionary];
        // 音频格式
        setting[AVFormatIDKey] = @(kAudioFormatAppleIMA4);
        // 录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）8000是电话采样率
        setting[AVSampleRateKey] = @(44100);
        // 音频通道数 1 或 2
        setting[AVNumberOfChannelsKey] = @(1);
        // 线性音频的位深度  8、16、24、32、 每个采样点位数
        setting[AVLinearPCMBitDepthKey] = @(8);
        //录音的质量
        setting[AVEncoderAudioQualityKey] = [NSNumber numberWithInt:AVAudioQualityHigh];
        
      /*
       //设置录音格式
        [setting setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
        //设置录音采样率，8000是电话采样率，对于一般录音已经够了
        [setting setObject:@(8000) forKey:AVSampleRateKey];
        //设置通道，这里采用单声道
        [setting setObject:@(1) forKey:AVNumberOfChannelsKey];
        //每个采样点位数，分为8、16、24、32
        [setting setObject:@(8) forKey:AVLinearPCMBitDepthKey];
        //是否使用浮点数采样
        [setting setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
        */
        
        _recorder = [[AVAudioRecorder alloc] initWithURL:self.recordFileUrl settings:setting error:NULL];
        _recorder.delegate = self;
        _recorder.meteringEnabled = YES;
        
        [_recorder prepareToRecord];
    }
    return _recorder;
}

- (void)destructionRecordingFile {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (self.recordFileUrl) {
        [fileManager removeItemAtURL:self.recordFileUrl error:NULL];
    }
}

#pragma mark - AVAudioRecorderDelegate
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    if (flag) {
        [self.session setActive:NO error:nil];
    }
}

@end
