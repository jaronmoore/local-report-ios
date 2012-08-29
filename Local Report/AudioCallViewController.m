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


@end

@implementation AudioCallViewController

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
}
- (IBAction)hangupButtonPressed:(UIButton *)sender 
{
    LocalReportAppDelegate *appDelegate = (LocalReportAppDelegate *)[UIApplication sharedApplication].delegate;
    TwilioPhone *phone = appDelegate.phone;
    [phone disconnect];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
