//
//  UIImage+Extensions.h
//  CripOCR
//
//  Created by Zhaoyu Li on 12/8/13.
//  Copyright (c) 2013 Zhaoyu Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Extensions)
- (UIImage *)imageAtRect:(CGRect)rect;
- (UIImage *)imageByScalingProportionallyToMinimumSize:(CGSize)targetSize;
- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize;
- (UIImage *)imageByScalingToSize:(CGSize)targetSize;
- (UIImage *)imageRotatedByRadians:(CGFloat)radians;
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;

@end
