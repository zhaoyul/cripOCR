//
//  MAImagePickerControllerAdjustViewController.h
//  instaoverlay
//
//  Created by Kevin Li on 2013-10-18.
//  Copyright (c) 2012 Centling co,. ltd. All rights reserved.
//

//Dedected Points

#import <UIKit/UIKit.h>

#import "MAConstants.h"
#import "MADrawRect.h"
#import "MAOpenCV.hpp"


#import <opencv2/core/core.hpp>
#import <opencv2/imgproc/imgproc.hpp>

@interface MAImagePickerControllerAdjustViewController : UIViewController
{
    BOOL isGray;
}

@property (strong, nonatomic) UIImageView *sourceImageView;
@property (strong, nonatomic) UIToolbar *adjustToolBar;
@property (strong, nonatomic) UIImage *sourceImage;
@property (strong, nonatomic) UIImage *adjustedImage;
@property (strong, nonatomic) MADrawRect *adjustRect;

@end
