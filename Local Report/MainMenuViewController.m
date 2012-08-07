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

@end

@implementation MainMenuViewController


@synthesize timerLabel = _timerLabel;
@synthesize messagesLabel = _messagesLabel;

@synthesize recordedVideo = _recordedVideo;
@synthesize time = _time;

@synthesize video = _video;

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

- (void)updateTimerLabel
{
    if (self.time > 0){
        self.timerLabel.text = [NSString stringWithFormat:@"%@ %g", @"Time Remaining: ", self.time];
         self.time--;
    } else {
        self.timerLabel.text = @"Time's up!";
    }
}
- (void)setCountdownTime:(NSTimeInterval)time
{
    self.time = time;
    NSTimer *timer;
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTimerLabel) userInfo:nil repeats:YES];
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
    [self.navigationController pushViewController:vuvc animated:NO];
}


- (BOOL) startCameraControllerFromViewController: (UIViewController*) controller 
{
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO)|| (controller == nil)) return NO;
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    cameraUI.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
    cameraUI.allowsEditing = NO;
    cameraUI.delegate = self;
    [controller presentModalViewController: cameraUI animated: YES];
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setCountdownTime:STANDARD_TIME];
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
