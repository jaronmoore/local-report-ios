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
#import "LocalReportAppDelegate.h"

@interface VideoUploaderViewController () <NSURLConnectionDelegate, NSURLConnectionDataDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) NSMutableData *receivedData;
@property (strong, nonatomic) NSString *userid;
@property (strong, nonatomic) IBOutlet UIProgressView *progressView;
@property (strong, nonatomic) ASIFormDataRequest *request;
@property (weak, nonatomic) IBOutlet UILabel *transferProgress;



@end

@implementation VideoUploaderViewController

@synthesize videoData = _videoData;
@synthesize receivedData = _receivedData;
@synthesize userid = _userid;
@synthesize progressView = _progressView;
@synthesize audioOrVideo = _audioOrVideo;
@synthesize request = _request;



#define UPLOAD_URL @"http://23.23.89.21:8080/post.php"

- (NSData *)videoData
{
    if (!_videoData) {
        _videoData = [NSData data];
    }
    return _videoData;
}
- (IBAction)cancelButtonPushed:(id)sender 
{
    [self.request cancel];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)uploadFileToServer
{

    // Create the request.
    NSURL *uploadURL = [NSURL URLWithString:UPLOAD_URL];
    self.request = [ASIFormDataRequest requestWithURL:uploadURL];
    //[request setData:self.videoData forKey:@"file"];
    [self.request setData:self.videoData withFileName:@"iPhoneVideo.mp4" andContentType:@"application/octet-stream" forKey:@"file"];
    [self.request setPostValue:self.userid forKey:@"participant_device_id"];
    [self.request setPostValue:self.audioOrVideo forKey:@"audio_or_video"];
    [self.request setPostValue:@"true" forKey:@"form_submitted"];
    if([CLLocationManager locationServicesEnabled]){
        
        LocalReportAppDelegate *appDelegate= (LocalReportAppDelegate *)[UIApplication sharedApplication].delegate;
        CLLocation *currentLocation=appDelegate.locationManager.location;
        
        //Do what you want with the location...
    [self.request setPostValue:[NSString stringWithFormat:@"%g", currentLocation.coordinate.latitude] forKey:@"latitude"];
    [self.request setPostValue:[NSString stringWithFormat:@"%g", currentLocation.coordinate.longitude] forKey:@"longitude"];
    }
    [self.request setDelegate:self];
    [self.request setUploadProgressDelegate:self.progressView];
    self.request.showAccurateProgress = YES;
    [self.request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    // Use when fetching text data
    //NSString *responseString = [request responseString];
    [self.transferProgress setText:@"Done"];
    //NSLog(@"%@", responseString);
    // Use when fetching binary data
    //NSData *responseData = [request responseData];
    [self.navigationController popToRootViewControllerAnimated:YES];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self uploadFileToServer];
}
-(void)alertViewCancel:(UIAlertView *)alertView
{
    
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"%@", error);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops..." message:@"There was an error uploading your video" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:@"Try Again", nil];
    [alert show];
}

- (void) getUserId
{
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    self.userid = [defaults objectForKey:@"unique"];
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
    [self getUserId];
}

- (void)viewDidUnload
{
    [self setProgressView:nil];
    [self setTransferProgress:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

@end
