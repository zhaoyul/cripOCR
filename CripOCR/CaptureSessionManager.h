//
//  CaptureSessionManager.h
//  CripOCR
//
//  Created by Zhaoyu Li on 12/2/13.
//  Copyright (c) 2013 Zhaoyu Li. All rights reserved.
//
#define kImageCapturedSuccessfully @"imageCapturedSuccessfully"

#import <Foundation/Foundation.h>
#import <ImageIO/ImageIO.h>
@import AVFoundation;

@interface CaptureSessionManager : NSObject

@property (strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (strong) AVCaptureSession *captureSession;

@property (strong) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, strong) UIImage *stillImage;
@property (nonatomic, strong) UIImage *cropedImage;


- (void)addVideoPreviewLayer;
- (void)addStillImageOutput;
- (void)captureStillImage;
- (void)addVideoInputFrontCamera:(BOOL)front;
@end
