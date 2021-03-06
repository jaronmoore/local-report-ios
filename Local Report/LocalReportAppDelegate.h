//
//  LocalReportAppDelegate.h
//  Local Report
//
//  Created by jaron moore on 7/30/12.
//  Copyright (c) 2012 Stanford University - Vice Provost for Undergraduate Education. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TwilioPhone.h"
#import <Mapkit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface LocalReportAppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) TwilioPhone *phone;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end
