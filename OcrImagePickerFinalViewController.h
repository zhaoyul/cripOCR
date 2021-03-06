//
//  OcrImagePickerFinalViewController.h
//  instaoverlay
//
//  Created by Kevin Li on 2013-10-18.
//  Copyright (c) 2012 Centling co,. ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OcrConstants.h"

@interface OcrImagePickerFinalViewController : UIViewController <UIScrollViewDelegate>
{
    int currentlySelected;
    UIImageOrientation sourceImageOrientation;
}

@property BOOL imageFrameEdited;

@property (strong, nonatomic) UIImage *sourceImage;
@property (strong, nonatomic) UIImage *adjustedImage;

@property (strong, nonatomic) UIButton *firstSettingIcon;
@property (strong, nonatomic) UIButton *secondSettingIcon;
@property (strong, nonatomic) UIButton *thirdSettingIcon;
@property (strong, nonatomic) UIButton *fourthSettingIcon;

@property (strong, nonatomic) UIBarButtonItem *rotateButton;

@property (strong, nonatomic) UIImageView *activityIndicator;
@property (strong, nonatomic) UIActivityIndicatorView *progressIndicator;

@property (strong, nonatomic) UIImageView *finalImageView;

@end
