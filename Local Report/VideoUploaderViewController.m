//
//  VideoUploaderViewController.m
//  Local Report
//
//  Created by jaron moore on 7/30/12.
//  Copyright (c) 2012 Stanford University - Vice Provost for Undergraduate Education. All rights reserved.
//

#import "VideoUploaderViewController.h"

@interface VideoUploaderViewController () <NSURLConnectionDelegate, NSURLConnectionDataDelegate>
@property (strong, nonatomic) NSMutableData *receivedData;
@property (strong, nonatomic) NSString *userid;
@property (strong, nonatomic) IBOutlet UIProgressView *progressView;
@end

@implementation VideoUploaderViewController

@synthesize videoData = _videoData;
@synthesize receivedData = _receivedData;
@synthesize userid = _userid;
@synthesize progressView = _progressView;

#define UPLOAD_URL @"http://23.23.89.21:8080/post.php"

- (NSData *)videoData
{
    if (!_videoData) {
        _videoData = [NSData data];
    }
    return _videoData;
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    float progress = (((float)totalBytesWritten)/totalBytesExpectedToWrite);
    [self.progressView setProgress:progress];
    [self.progressView setNeedsDisplay];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)uploadFileToServer
{
    // Create the request.
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:UPLOAD_URL]
                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                          timeoutInterval:60.0];
    [theRequest setHTTPMethod:@"POST"];
    
    // setup post string
    NSMutableData *body = [NSMutableData data];
    NSMutableString *postString = [[NSMutableString alloc] init];   
    [postString appendFormat:@"file=%@", self.videoData];
    [postString appendFormat:@"&userid=%@", self.userid];
    [postString appendFormat:@"&form_submitted=%@", @"true"];

    [body appendData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [theRequest setHTTPBody:body];
    
    // create the connection with the request
    // and start loading the data
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (theConnection) {
        // Create the NSMutableData to hold the received data.
        // receivedData is an instance variable declared elsewhere.
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];        
        self.receivedData = [NSMutableData data];
    } else {
        // Inform the user that the connection failed.
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
    [self.receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    // receivedData is declared as a method instance elsewhere
    self.receivedData = nil;
    
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self uploadFileToServer];
}

- (void)viewDidUnload
{
    [self setProgressView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
