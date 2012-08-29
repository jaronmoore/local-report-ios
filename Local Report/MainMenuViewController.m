//
//  MainMenuViewController.m
//  Local Report
//
//  Created by jaron moore on 7/30/12.
//  Copyright (c) 2012 Stanford University - Vice Provost for Undergraduate Education. All rights reserved.
//

#import "MainMenuViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "VideoUploaderViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>



@interface MainMenuViewController ()  <UIImagePickerControllerDelegate, UINavigationControllerDelegate>


@property NSTimeInterval time;
@property BOOL recordedVideo;

@property (strong, nonatomic) NSData *video;

@property (strong, nonatomic) UIImagePickerController *picker;
@property (strong, nonatomic) UIToolbar *pickerToolbar;

@property BOOL enabledButton;

@end

@implementation MainMenuViewController
@synthesize timerLabel = _timerLabel;
@synthesize messagesLabel = _messagesLabel;

@synthesize recordedVideo = _recordedVideo;
@synthesize time = _time;

@synthesize video = _video;

@synthesize picker = _picker;
@synthesize pickerToolbar = _pickerToolbar;


@synthesize enabledButton;

- (IBAction)shootVideo:(UIButton *)sender 
{
    if (!self.recordedVideo) {
        if ([self startCameraControllerFromViewController:self]) {
            self.recordedVideo = NO;
        }
    }
}

-(NSData *)video
{
    if(!_video){
        _video = [NSData data];
    }
    return _video;
}

#define STANDARD_TIME 30 
#define STANDARD_MESSAGE @"Example Message From Server"

- (void)updateTimerLabel:(NSTimer *)sender
{
    if (self.time > 0){
        ((UILabel *)sender.userInfo).text = [NSString stringWithFormat:@"%g", self.time];
         self.time--;
    } else {
        ((UILabel *)sender.userInfo).text = @"Time's up!";
    }
}
- (void)setCountdownTime:(NSTimeInterval)time
{
    self.time = time;
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTimerLabel:) userInfo:self.timerLabel repeats:YES];
}

- (void)setMessage:(NSString *)message
{
    self.messagesLabel.text = message;
    self.messagesLabel.layer.borderColor = [UIColor blackColor].CGColor;
    self.messagesLabel.layer.borderWidth = 2.0;

}


// For responding to the user tapping Cancel.

- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    self.recordedVideo = NO;
    [self dismissModalViewControllerAnimated: YES];
}

-(void)stopRecording
{
    [self.picker stopVideoCapture];
}

-(void) setUpTimerUI
{
    UILabel *timer = [[UILabel alloc]initWithFrame:CGRectMake(15, 30, 40, 25)];
    timer.text = @"20";
    timer.backgroundColor = [UIColor clearColor];
    timer.textColor = [UIColor whiteColor];
    timer.font = [UIFont systemFontOfSize:24];
    [timer setTransform:CGAffineTransformMakeRotation(M_PI / 2)];
    self.time = 20;
    [self.picker.cameraOverlayView addSubview:timer];
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTimerLabel:) userInfo:timer repeats:YES];
}

-(void) recordPressed
{
    if (enabledButton) {
        if([self.picker startVideoCapture])
        {
            UIBarButtonItem *recordButton = [self.pickerToolbar.items lastObject];
            [recordButton setEnabled:NO];
            [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(stopRecording) userInfo:nil repeats:NO];
            [self setUpTimerUI];
            enabledButton = NO;
        }
    }
}

// For responding to the user accepting a newly-captured picture or movie
- (void) imagePickerController: (UIImagePickerController *) picker 
 didFinishPickingMediaWithInfo: (NSDictionary *) info 
{
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    // Handle a movie capture
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
        NSURL *moviePath = [info objectForKey: UIImagePickerControllerMediaURL];
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum ([moviePath path])) {
           // UISaveVideoAtPathToSavedPhotosAlbum (moviePath, nil, nil, nil);
            self.video = [NSData dataWithContentsOfURL:moviePath]; 
        }
    }
    [self dismissModalViewControllerAnimated: YES];
    VideoUploaderViewController *vuvc =[self.storyboard instantiateViewControllerWithIdentifier:@"vidUpload"];
    vuvc.videoData = self.video;
    vuvc.audioOrVideo = @"video";
    [self.navigationController pushViewController:vuvc animated:NO];
}

- (BOOL) startCameraControllerFromViewController: (UIViewController*) controller 
{
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO)|| (controller == nil)) return NO;
    
    self.picker = [[UIImagePickerController alloc] init];
    self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.picker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
    self.picker.allowsEditing = NO;
    self.picker.showsCameraControls = NO;
    self.picker.wantsFullScreenLayout = NO;
    self.picker.delegate = self;
    self.picker.videoQuality = UIImagePickerControllerQualityTypeMedium;
    
    UIView *overlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    self.pickerToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 420, 320, 60)];
    UIBarButtonItem *recordButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"recordbutton.png"] style:UIBarButtonItemStylePlain target:self action:@selector(recordPressed)];
 
    
    [self.pickerToolbar setItems:[NSArray arrayWithObjects: [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], recordButton, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],nil]];
    [overlay addSubview:self.pickerToolbar];
    
    self.picker.cameraOverlayView = overlay;

    self.enabledButton = YES;
    
    [controller presentModalViewController: self.picker animated: YES];
    return YES;
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //[self buildCameraUI];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self setCountdownTime:STANDARD_TIME];
    [self setMessage: STANDARD_MESSAGE];
}

- (void)viewDidUnload
{
    [self setTimerLabel:nil];
    [self setMessagesLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
