//
//  CTLIphoneViewController.h
//  CripOCR
//
//  Created by Zhaoyu Li on 12/2/13.
//  Copyright (c) 2013 Zhaoyu Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CaptureSessionManager.h"

@interface CTLIphoneViewController : UIViewController
@property (strong) CaptureSessionManager *captureManager;
@property (nonatomic, strong) UILabel *scanningLabel;
@property (nonatomic, strong) UIImage *toBeRecg;

@end
