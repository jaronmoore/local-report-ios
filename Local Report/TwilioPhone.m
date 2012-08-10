//
//  TwilioPhone.m
//  Local Report
//
//  Created by jaron moore on 8/9/12.
//  Copyright (c) 2012 Stanford University - Vice Provost for Undergraduate Education. All rights reserved.
//

#import "TwilioPhone.h"
#import "TCConnection.h"
#import "TCDevice.h"
@interface TwilioPhone()

@property (strong, nonatomic) TCConnection *connection;

@end

@implementation TwilioPhone

@synthesize device = _device;
@synthesize connection = _connection;


#define TWILIO_AUTH_URL @"http://live.whitmanlocalreport.net:8080/twilio/twilio_auth.php"

-(TCDevice *)device
{
    if (!_device) {
        NSURL *url = [NSURL URLWithString:TWILIO_AUTH_URL];
        NSURLResponse *response = nil;
        NSError *error = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:url] returningResponse:&response error:&error];
        if (data) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            
            if (httpResponse.statusCode == 200) {
                NSString *capabilityToken = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                _device = [[TCDevice alloc] initWithCapabilityToken:capabilityToken delegate:nil];
            } else {
                NSString *errorString = [NSString stringWithFormat:@"HTTP status code %d", httpResponse.statusCode];
                NSLog(@"Error logging in: %@", errorString);
            }
        }
        else {
            NSLog(@"Error logging in : %@", [error localizedDescription]);
        }
    }
    return _device;
}

-(void)connect
{
    self.connection = [self.device connect:nil delegate:nil];
}

-(void)disconnect
{
    [self.connection disconnect];
    self.connection = nil;
}
@end
