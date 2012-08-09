//
//  TwilioPhone.m
//  Local Report
//
//  Created by jaron moore on 8/9/12.
//  Copyright (c) 2012 Stanford University - Vice Provost for Undergraduate Education. All rights reserved.
//

#import "TwilioPhone.h"

@implementation TwilioPhone

@synthesize device = _device;

#define TWILIO_AUTH_URL @"http://live.whitmanlocalreport.net:8080/twilio/twilio_auth.php"

-(TCDevice *)device
{
    if (!_device) {
        NSURL *url = [NSURL URLWithString:TWILIO_AUTH_URL];
        NSOperationQueue *twilioQueue = [[NSOperationQueue alloc] init];
        [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:url] queue:twilioQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            if (data) {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                if (httpResponse.statusCode == 200) {
                    NSString *capabilityToken = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    _device = [[TCDevice alloc] initWithCapabilityToken:capabilityToken delegate:nil];
                }
                else {
                    NSString *errorString = [NSString stringWithFormat:@"HTTP status code %D", httpResponse.statusCode];;
                    NSLog(@"Error logging in :%@", errorString);
                }
            }
        }];
    }
    return _device;
}
@end
