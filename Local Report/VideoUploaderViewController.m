//
//  VideoUploaderViewController.m
//  Local Report
//
//  Created by jaron moore on 7/30/12.
//  Copyright (c) 2012 Stanford University - Vice Provost for Undergraduate Education. All rights reserved.
//

#import "VideoUploaderViewController.h"

@interface VideoUploaderViewController ()

@end

@implementation VideoUploaderViewController

@synthesize videoData = _videoData;

#define UPLOAD_URL @"http://23.23.89.21:8080/post.php"

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:UPLOAD_URL]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:self.videoData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:nil completionHandler:nil];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
