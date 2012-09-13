//
//  VideoUploaderViewController.m
//  Local Report
//
//  Created by jaron moore on 7/30/12.
//  Copyright (c) 2012 Stanford University - Vice Provost for Undergraduate Education. All rights reserved.
//

#import "VideoUploaderViewController.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import <Mapkit/MapKit.h>

@interface VideoUploaderViewController () <NSURLConnectionDelegate, NSURLConnectionDataDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) NSMutableData *receivedData;
@property (strong, nonatomic) NSString *userid;
@property (strong, nonatomic) IBOutlet UIProgressView *progressView;

@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation VideoUploaderViewController

@synthesize videoData = _videoData;
@synthesize receivedData = _receivedData;
@synthesize userid = _userid;
@synthesize progressView = _progressView;
@synthesize mapView = _mapView;
@synthesize audioOrVideo = _audioOrVideo;

#define UPLOAD_URL @"http://23.23.89.21:8080/post.php"

- (NSData *)videoData
{
    if (!_videoData) {
        _videoData = [NSData data];
    }
    return _videoData;
}

- (void)uploadFileToServer
{
    // Create the request.
    NSURL *uploadURL = [NSURL URLWithString:UPLOAD_URL];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:uploadURL];
    //[request setData:self.videoData forKey:@"file"];
    [request setData:self.videoData withFileName:@"iPhoneVideo.mp4" andContentType:@"application/octet-stream" forKey:@"file"];
    [request setPostValue:@"1" forKey:@"participant_id"];
    [request setPostValue:self.audioOrVideo forKey:@"audio_or_video"];
    [request setPostValue:@"true" forKey:@"form_submitted"];

    [request setDelegate:self];
    [request setUploadProgressDelegate:self.progressView];
    request.showAccurateProgress = YES;
    [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    // Use when fetching text data
    NSString *responseString = [request responseString];
    NSLog(@"%@", responseString);
    // Use when fetching binary data
    NSData *responseData = [request responseData];
    NSLog(@"%@", responseData);
}
-(void)alertViewCancel:(UIAlertView *)alertView
{
    [self uploadFileToServer];
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"%@", error);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops..." message:@"There was an error uploading your video, but we're trying again" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self uploadFileToServer];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidUnload
{
    [self setProgressView:nil];
    [self setMapView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
