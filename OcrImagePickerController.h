//
//  OcrImagePickerController.h
//  instaoverlay
//
//  Created by Kevin Li on 2013-10-18.
//  Copyright (c) 2012 Centling co,. ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OcrCaptureSession.h"
#import "OcrConstants.h"
#import <MediaPlayer/MediaPlayer.h>

typedef NS_ENUM(NSInteger, MAImagePickerControllerSourceType)
{
    MAImagePickerControllerSourceTypeCamera,
    MAImagePickerControllerSourceTypePhotoLibrary
};



@protocol MAImagePickerControllerDelegate <NSObject>

@required
- (void)imagePickerDidCancel;
- (void)imagePickerDidChooseImageWithPath:(NSString *)path;

@end

@interface OcrImagePickerController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    BOOL flashIsOn;
    BOOL imagePickerDismissed;
}

@property (nonatomic,assign) id<MAImagePickerControllerDelegate> delegate;

@property (strong, nonatomic) OcrCaptureSession *captureManager;
@property (strong, nonatomic) UIToolbar *cameraToolbar;
@property (strong, nonatomic) UIBarButtonItem *flashButton;
@property (strong, nonatomic) UIBarButtonItem *pictureButton;
@property (strong, nonatomic) UIView *cameraPictureTakenFlash;

@property (strong ,nonatomic) UIImagePickerController *invokeCamera;

@property  MAImagePickerControllerSourceType *pickerSourceType;

@property (strong, nonatomic) MPVolumeView *volumeView;

@property (strong, nonatomic) UIImage *adjustedImg;


@end
