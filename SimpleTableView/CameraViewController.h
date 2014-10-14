//
//  CameraViewController.h
//  SimpleTableView
//
//  Created by Ratheesh Reddy on 10/8/14.
//  Copyright (c) 2014 Ventois. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBarSDK.h"

// custom protocol 
@protocol CameraViewControllerDelegate <NSObject>

-(void)scanCompletedWithString:(NSArray*)barCodes;

@end

@interface CameraViewController : UIViewController <ZBarReaderViewDelegate>

-(id)initWithDelegate:(id<CameraViewControllerDelegate>)delegate;

@end