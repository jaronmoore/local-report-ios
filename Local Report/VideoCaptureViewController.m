//
//  VideoCaptureViewController.m
//  Local Report
//
//  Created by jaron moore on 8/21/12.
//  Copyright (c) 2012 Stanford University - Vice Provost for Undergraduate Education. All rights reserved.
//

#import "VideoCaptureViewController.h"
#import "AVFoundation/AVFoundation.h"

@interface VideoCaptureViewController ()

@property (strong, nonatomic) IBOutlet UIButton *recordButton;
@property (atomic, strong) AVCaptureMovieFileOutput *movieFileOutput;
@property (strong, nonatomic) AVCaptureSession *session;

@end

@implementation VideoCaptureViewController
@synthesize recordButton = _recordButton;
@synthesize session = _session;
@synthesize movieFileOutput = _movieFileOutput;


- (IBAction)recordPressed:(UIButton *)sender 
{

}






-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session]; 
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    CALayer *rootLayer = [[self view] layer];
    [rootLayer setMasksToBounds:YES];
    [previewLayer setFrame:CGRectMake(-70, 0, rootLayer.bounds.size.height, rootLayer.bounds.size.height)];
    [rootLayer insertSublayer:previewLayer atIndex:0];
    
    [self.session startRunning];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIApplication sharedApplication]setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:YES];
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
    
    self.session = [[AVCaptureSession alloc] init];
    [self.session setSessionPreset:AVCaptureSessionPreset640x480];
    AVCaptureDevice *videoCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoCaptureDevice error:nil];
    if ([self.session canAddInput:deviceInput] )
        [self.session addInput:deviceInput];
    
}

- (void)viewDidUnload
{
    [self setRecordButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

@end
