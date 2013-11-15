//
//  OcrDrawRect.h
//  instaoverlay
//
//  Created by Kevin Li on 2013-10-18.
//  Copyright (c) 2012 Centling co,. ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OcrConstants.h"

//            cd
//  d   -------------   c
//     |             |
//     |             |
//  da |             |  bc 
//     |             |
//     |             |
//     |             |
//  a   -------------   b
//            ab
//
// a = 1, b = 2, c = 3, d = 4

@interface OcrDrawRect : UIView
{
    CGPoint touchOffset;
    CGPoint a;
    CGPoint b;
    CGPoint c;
    CGPoint d;
    
    BOOL frameMoved;
}

@property (strong, nonatomic) UIButton *pointD;
@property (strong, nonatomic) UIButton *pointC;
@property (strong, nonatomic) UIButton *pointB;
@property (strong, nonatomic) UIButton *pointA;

- (BOOL)frameEdited;
- (void)resetFrame;
- (CGPoint)coordinatesForPoint: (int)point withScaleFactor: (CGFloat)scaleFactor;

- (void)bottomLeftCornerToCGPoint: (CGPoint)point;
- (void)bottomRightCornerToCGPoint: (CGPoint)point;
- (void)topRightCornerToCGPoint: (CGPoint)point;
- (void)topLeftCornerToCGPoint: (CGPoint)point;

@end
