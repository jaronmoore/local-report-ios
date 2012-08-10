//
//  TwilioPhone.h
//  Local Report
//
//  Created by jaron moore on 8/9/12.
//  Copyright (c) 2012 Stanford University - Vice Provost for Undergraduate Education. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCDevice.h"

@interface TwilioPhone : NSObject

@property (strong, nonatomic) TCDevice *device;

-(void)connect;
-(void)disconnect;
@end
