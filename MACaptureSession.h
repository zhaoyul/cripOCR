//
//  MACaptureSession.h
//  instaoverlay
//
//  Created by Kevin Li on 2013-10-18.
//  Copyright (c) 2012 Centling co,. ltd. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "MAConstants.h"

@interface MACaptureSession : NSObject
{
    BOOL flashOn;
}

@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) AVCaptureStillImageOutput *stillImageOutput;
@property (strong, nonatomic) UIImage *stillImage;

- (void)addVideoPreviewLayer;
- (void)addStillImageOutput;
- (void)captureStillImage;
- (void)addVideoInputFromCamera;

- (void)setFlashOn:(BOOL)boolWantsFlash;

@end