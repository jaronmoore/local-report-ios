//
//  AudioCallViewController.m
//  Local Report
//
//  Created by jaron moore on 7/31/12.
//  Copyright (c) 2012 Stanford University - Vice Provost for Undergraduate Education. All rights reserved.
//

#import "AudioCallViewController.h"
#import "TwilioPhone.h"
#import "LocalReportAppDelegate.h"

@interface AudioCallViewController ()
@property (strong, nonatomic) IBOutlet UIButton *callButton;

@property (strong, nonatomic) IBOutlet UIButton *hangupButoon;

@end

@implementation AudioCallViewController
@synthesize callButton;
@synthesize hangupButoon;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)dialButtonPressed:(UIButton *)sender 
{
    LocalReportAppDelegate *appDelegate = (LocalReportAppDelegate *)[UIApplication sharedApplication].delegate;
    TwilioPhone *phone = appDelegate.phone;
    [phone connect];
    [sender setEnabled:NO];
}
- (IBAction)hangupButtonPressed:(UIButton *)sender 
{
    LocalReportAppDelegate *appDelegate = (LocalReportAppDelegate *)[UIApplication sharedApplication].delegate;
    TwilioPhone *phone = appDelegate.phone;
    [phone disconnect];
    [self.callButton setEnabled:YES];
}

- (void)sensorStateChange:(NSNotificationCenter *)notification
{
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Enabled monitoring of the sensor
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    
    // Set up an observer for proximity changes
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorStateChange:) 
                                                 name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
}

- (void)viewDidUnload
{
    [self setCallButton:nil];
    [self setHangupButoon:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

@end
