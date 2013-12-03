//
//  CTLIphoneViewController.m
//  CripOCR
//
//  Created by Zhaoyu Li on 12/2/13.
//  Copyright (c) 2013 Zhaoyu Li. All rights reserved.
//

#import "CTLIphoneViewController.h"
#import <TesseractOCR/TesseractOCR.h>


@interface CTLIphoneViewController ()

@end

@implementation CTLIphoneViewController

- (void)viewDidLoad {
    
	[self setCaptureManager:[[CaptureSessionManager alloc] init] ];
    
    
     [self.captureManager addVideoInputFrontCamera:NO];
    
    [[self captureManager] addStillImageOutput];
    
	[[self captureManager] addVideoPreviewLayer];
	CGRect layerRect = [[[self view] layer] bounds];
    [[[self captureManager] previewLayer] setBounds:layerRect];
    [[[self captureManager] previewLayer] setPosition:CGPointMake(CGRectGetMidX(layerRect),CGRectGetMidY(layerRect))];
	[[[self view] layer] addSublayer:[[self captureManager] previewLayer]];
    
    UIImageView *overlayImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"overlaygraphic.png"]];
    [overlayImageView setFrame:CGRectMake(30, 100, 260, 40)];
    [[self view] addSubview:overlayImageView];
    
    UIButton *overlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [overlayButton setImage:[UIImage imageNamed:@"scanbutton.png"] forState:UIControlStateNormal];
    [overlayButton setFrame:CGRectMake(130, 320, 60, 30)];
    [overlayButton addTarget:self action:@selector(scanButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [[self view] addSubview:overlayButton];
    
    UILabel *tempLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 50, 120, 30)];
    [self setScanningLabel:tempLabel];
	[self.scanningLabel setBackgroundColor:[UIColor clearColor]];
	[self.scanningLabel setFont:[UIFont fontWithName:@"Courier" size: 18.0]];
	[self.scanningLabel setTextColor:[UIColor redColor]];
	[self.scanningLabel setText:@"Saving..."];
//    [self.scanningLabel setHidden:YES];
	[[self view] addSubview:self.scanningLabel];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveImageToPhotoAlbum) name:kImageCapturedSuccessfully object:nil];
    
	[[self.captureManager captureSession] startRunning];
}

- (void)scanButtonPressed {
//	[[self scanningLabel] setHidden:NO];
    [[self captureManager] captureStillImage];
}

- (void)saveImageToPhotoAlbum
{
    UIImageWriteToSavedPhotosAlbum([[self captureManager] stillImage], self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    UIImageWriteToSavedPhotosAlbum([[self captureManager]  cropedImage], self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    self.toBeRecg = self.captureManager.stillImage;
    [self textRecg:nil];
    
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error != NULL) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Image couldn't be saved" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    else {
        [[self scanningLabel] setHidden:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

+ (UIImage *)imageWithImage:(UIImage *)image{
    CGSize newSize = CGSizeMake(image.size.width*10, image.size.height*10);
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)textRecg:(id)sender {
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        //        Tesseract* tesseract = [[Tesseract alloc] initWithDataPath:@"tessdata" language:@"chi_sim"];
        Tesseract* tesseract = [[Tesseract alloc] initWithDataPath:@"tessdata" language:@"eng"];
//        [tesseract setVariableValue:@"0123456789" forKey:@"tessedit_char_whitelist"];
//        UIImage *largeImg = [CTLIphoneViewController imageWithImage:self.toBeRecg];
        [tesseract setImage:self.toBeRecg];
        [tesseract recognize];
        NSString *recoText = [tesseract recognizedText];
        NSLog(@"--------------------:%@", recoText);
        [tesseract clear];
        NSString *version = [Tesseract version];
        NSLog(@"Tesseract's version:%@", version);
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            self.scanningLabel.text = recoText;
        });
    });
    
}

@end
