//
//  AudioCaptureViewController.m
//  Local Report
//
//  Created by jaron moore on 7/31/12.
//  Copyright (c) 2012 Stanford University - Vice Provost for Undergraduate Education. All rights reserved.
//

#import "AudioCaptureViewController.h"
#import "VideoUploaderViewController.h"

@interface AudioCaptureViewController ()

@property (strong, nonatomic) IBOutlet UIButton *stopButton;
@property (strong, nonatomic) IBOutlet UIButton *uploadButton;
@property (strong, nonatomic) NSURL *recordedTmpFile;
@property (strong, nonatomic) AVAudioRecorder *recorder;
@property (strong, nonatomic) NSData *audio;

@property (strong, nonatomic) IBOutlet UILabel *statusText;

@end

@implementation AudioCaptureViewController
@synthesize stopButton = _stopButton;
@synthesize uploadButton = _uploadButton;
@synthesize recordedTmpFile = _recordedTmpFile;
@synthesize recorder = _recorder;
@synthesize audio = _audio;
@synthesize statusText = _statusText;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)stopButtonPressed:(UIButton *)sender 
{
    self.statusText.text = @"Ready to Upload";
    [self.recorder stop];
}
- (IBAction)uploadPressed:(UIButton *)sender 
{
    self.audio = [NSData dataWithContentsOfURL:self.recordedTmpFile];
    if (self.audio) {
    VideoUploaderViewController *vuvc =[self.storyboard instantiateViewControllerWithIdentifier:@"vidUpload"];
    vuvc.videoData = self.audio;
    vuvc.audioOrVideo = @"audio";
    [self.navigationController pushViewController:vuvc animated:YES];
    }
}

- (void)startRecording
{
    NSMutableDictionary* recordSetting =[[NSMutableDictionary alloc]init];
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatAppleIMA4] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
    
    self.recordedTmpFile = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent: [NSString stringWithFormat: @"%.0f.%@", [NSDate timeIntervalSinceReferenceDate] * 1000.0, @"caf"]]];
    NSLog(@"Using File called: %@",self.recordedTmpFile);
    //Setup the recorder to use this file and record to it.
    self.recorder = [[ AVAudioRecorder alloc] initWithURL:self.recordedTmpFile settings:recordSetting error:nil];
    //Use the recorder to start the recording.
    //Im not sure why we set the delegate to self yet.  
    //Found this in antother example, but Im fuzzy on this still.
    [self.recorder setDelegate:self];
    //We call this to start the recording process and initialize 
    //the subsstems so that when we actually say "record" it starts right away.
    [self.recorder prepareToRecord];
    //Start the actual Recording
    [self.recorder record];
    self.statusText.text = @"Recording";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:nil];
    [self startRecording];
}

- (void)viewDidUnload
{
    [self setStopButton:nil];
    [self setUploadButton:nil];
    [self setStatusText:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

@end
