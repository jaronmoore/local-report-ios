//
//  MainMenuViewController.m
//  Local Report
//
//  Created by jaron moore on 7/30/12.
//  Copyright (c) 2012 Stanford University - Vice Provost for Undergraduate Education. All rights reserved.
//

#import "MainMenuViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "VideoCaptureViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "Reachability.h"
#import <MapKit/Mapkit.h>


@interface MainMenuViewController ()  <UIImagePickerControllerDelegate, UINavigationControllerDelegate>


@property NSTimeInterval time;

@property NetworkStatus networkstatus;
@end

@implementation MainMenuViewController
@synthesize timerLabel = _timerLabel;
@synthesize messagesLabel = _messagesLabel;

@synthesize time = _time;
@synthesize networkstatus = _networkstatus;

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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString: @"showVideoRecorder"]) {
        ((VideoCaptureViewController *)segue.destinationViewController).networkstatus = self.networkstatus;
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self setCountdownTime:STANDARD_TIME];
    [self setMessage: STANDARD_MESSAGE];
    Reachability *network = [Reachability reachabilityWithHostName: @"www.whitmanlocalreport.net"];
    self.networkstatus = [network currentReachabilityStatus];
    
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
    return NO;
}

@end
