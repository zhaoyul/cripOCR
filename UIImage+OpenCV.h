//
//  UIImage+OpenCV.h
//  OpenCVClient
//
//  Created by Kevin Li on 2013-10-17
//  Copyright (c) 2012 Centling, co,. ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (UIImage_OpenCV)

+(UIImage *)imageWithCVMat:(const cv::Mat&)cvMat;
-(id)initWithCVMat:(const cv::Mat&)cvMat;

@property(nonatomic, readonly) cv::Mat CVMat;
@property(nonatomic, readonly) cv::Mat CVGrayscaleMat;

@end
