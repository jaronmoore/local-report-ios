//
//  VideoCaptureViewController.m
//  Local Report
//
//  Created by jaron moore on 8/21/12.
//  Copyright (c) 2012 Stanford University - Vice Provost for Undergraduate Education. All rights reserved.
//

#import "VideoCaptureViewController.h"
#import "AVFoundation/AVFoundation.h"
#import "DIYCam.h"
#import "VideoUploaderViewController.h"
#import "DIYCamDefaults.h"

@interface VideoCaptureViewController () <DIYCamDelegate>


@property (strong, nonatomic) IBOutlet UIView *previewView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *recordButton;
@property (strong, nonatomic) IBOutlet UIProgressView *timerView;
@property (weak, nonatomic) NSString *assetPath;
@property (strong, nonatomic)DIYCam *cam;

@property NSTimeInterval time;
@property (strong, nonatomic) NSTimer *timer;

@end

@implementation VideoCaptureViewController
@synthesize previewView = _previewView;
@synthesize recordButton = _recordButton;
@synthesize timerView = _timerView;

@synthesize cam = _cam;

@synthesize time = _time;
@synthesize timer = _timer;

@synthesize networkstatus = _networkstatus;
@synthesize assetPath = _assetPath;

- (IBAction)recordPressed:(UIBarButtonItem *)sender 
{
    [self.cam startVideoCapture];
    [sender setEnabled:NO];
}

- (void)stopRecording
{
    [self.cam stopVideoCapture];
}

- (void)updateTimerLabel
{
    if (self.time > 0){

        [self.timerView setProgress:(float)((20.0-self.time)/20.0) animated:YES];
        self.time--;
    } else {
        [self stopRecording];
        [self.timer invalidate];
    }
}

-(void) setUpTimerUI
{
    self.time = 20;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTimerLabel) userInfo:nil repeats:YES];
}

- (void)camReady:(DIYCam *)cam
{
    
}
- (void)camDidFail:(DIYCam *)cam withError:(NSError *)error{
    
}
- (void)camCaptureStarted:(DIYCam *)cam
{
    [self setUpTimerUI];
}
- (void)camCaptureStopped:(DIYCam *)cam
{
    
}
- (void)camCaptureProcessing:(DIYCam *)cam{
    
}
- (void)camCaptureComplete:(DIYCam *)cam withAsset:(NSDictionary *)asset{
    self.assetPath = [asset objectForKey:@"path"];
    [self performSegueWithIdentifier:@"show upload" sender:self];
 /*
    VideoUploaderViewController *vuvc =[self.storyboard instantiateViewControllerWithIdentifier:@"vidUpload"];
    vuvc.videoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:assetPath]];
    vuvc.audioOrVideo = @"video";
    [self.navigationController pushViewController:vuvc animated:NO];
   */
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self.navigationController setNavigationBarHidden:YES];
    self.cam = [[DIYCam alloc] init];
    switch (self.networkstatus) {
        case NotReachable:
            //alert
            break;
        case ReachableViaWiFi:
            self.cam.frameRate = [NSNumber numberWithInt:WIFI_BITRATE];
            break;
        case ReachableViaWWAN:
            self.cam.frameRate = [NSNumber numberWithInt:NETWORK_BITRATE];
            break;
        default:
            break;
    }
    [self.cam setDelegate:self];
    [self.cam setup];
    
    self.cam.preview.frame  = self.previewView.frame;
    [self.view.layer addSublayer:self.cam.preview];
    
    CGRect bounds = self.previewView.layer.bounds;
    self.cam.preview.bounds = bounds;
    self.cam.preview.position = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
}


- (void)viewDidUnload
{
    [self setRecordButton:nil];
    [self setPreviewView:nil];
    [self setRecordButton:nil];
    [self setTimerView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"show upload"]) {
        ((VideoUploaderViewController*)segue.destinationViewController).videoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.assetPath]];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

@end
