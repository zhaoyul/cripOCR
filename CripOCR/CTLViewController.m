//
//  CTLViewController.m
//  CripOCR
//
//  Created by Zhaoyu Li on 10/16/13.
//  Copyright (c) 2013 Zhaoyu Li. All rights reserved.
//

#import "CTLViewController.h"
#import <TesseractOCR/TesseractOCR.h>
#import <dispatch/dispatch.h>
#import "MBProgressHUD.h"
#import "ImageProcessingImplementation.h"
#import <QuartzCore/QuartzCore.h>
#import <MobileCoreServices/MobileCoreServices.h> 
#import "OcrImagePickerController.h"

#import "UIImage+Extensions.h"

@interface CTLViewController () <MAImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextView *resultText;
@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (strong, nonatomic) UIImage *originImg;
@property (strong, nonatomic) OcrImagePickerController *imagePicker;
@end

@implementation CTLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated{
    if (self.imagePicker) {
        self.photo.image = self.imagePicker.adjustedImg;
        self.originImg = self.imagePicker.adjustedImg;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)imagePickerDidCancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerDidChooseImageWithPath:(NSString *)path
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        NSLog(@"File Found at %@", path);
        NSURL *fileUrl=[NSURL fileURLWithPath:path];
        NSData *data = [NSData dataWithContentsOfURL:fileUrl];
        self.photo.image = [UIImage imageWithData:data];
        self.originImg = self.photo.image;
        
    }
    else
    {
        NSLog(@"No File Found at %@", path);
    }
    
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

- (IBAction)takePhoto:(id)sender {
    self.imagePicker = [[OcrImagePickerController alloc] init];
    
    [self.imagePicker setDelegate:self];
    self.imagePicker.pickerSourceType = MAImagePickerControllerSourceTypeCamera;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.imagePicker];
    
    [self presentViewController:navigationController animated:YES completion:^{
    }];
    
    

}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if (!image) image = info[UIImagePickerControllerOriginalImage];
    self.photo.image = image;
    self.originImg = image;
    [self dismissViewControllerAnimated:YES completion:nil];
    
 }
+ (UIImage *)imageWithImage:(UIImage *)image{
    CGSize newSize = CGSizeMake(image.size.width*4, image.size.height*4);
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(UIImage*) cropImage:(UIImage*) image withStartX:(CGFloat) startX withStartY :(CGFloat) startY withWidth :(CGFloat) width withHeight:(CGFloat) height {
    CGRect rect = CGRectMake(image.size.width*startX, image.size.height*startY, image.size.width*width, image.size.height*height);
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
    UIImage *img = [UIImage imageWithCGImage:imageRef];
    return img;
}

- (IBAction)textRecg:(id)sender {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"照片识别中";
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
//        Tesseract* tesseract = [[Tesseract alloc] initWithDataPath:@"tessdata" language:@"chi_sim"];
        Tesseract* tesseract = [[Tesseract alloc] initWithDataPath:@"tessdata" language:@"chi_sim"];
//        [tesseract setVariableValue:@"0123456789" forKey:@"tessedit_char_whitelist"];
        [tesseract setVariableValue:@"Oo_" forKey:@"tessedit_char_blacklist"];
//        [tesseract setVariableValue:@"8" forKey:@"tessedit_pageseg_mode"];

//        UIImage *large = [CTLViewController imageWithImage:self.photo.image];
        UIImage *cropedImage = [self cropImage:self.photo.image withStartX:0.37f withStartY:0.66f withWidth:0.7f withHeight:0.33f];
        [tesseract setImage:cropedImage];
        UIImageWriteToSavedPhotosAlbum(cropedImage, nil, nil, nil);
        [tesseract recognize];
        NSString *recoText = [tesseract recognizedText];
        NSLog(@"----------------%@", recoText);
        [tesseract clear];
        NSString *version = [Tesseract version];
        NSLog(@"Tesseract's version:%@", version);
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            self.resultText.text =recoText;
            [hud hide:YES];
        });
    });

}

- (IBAction)intensifyImg:(id)sender {
//    cv::Mat grayMat = [self.originImg CVGrayscaleMat];
//    self.photo.image = [[UIImage alloc] initWithCVMat:grayMat];
}

- (IBAction)cropPaper:(id)sender {
//    cv::Mat inputMat = [self.originImg CVMat];
//    std::vector<std::vector<cv::Point> > rect = [self findSquaresInImage:inputMat];
//    cv::Mat paperMat = debugSquares(rect, inputMat);
//    self.photo.image = [[UIImage alloc] initWithCVMat:paperMat];
}
- (IBAction)rotation:(id)sender {
    ImageProcessingImplementation *ip = [[ImageProcessingImplementation alloc] init];
    self.photo.image = [ip processRotation:self.originImg];
}
- (IBAction)histogram:(id)sender {
    ImageProcessingImplementation *ip = [[ImageProcessingImplementation alloc] init];
//    self.photo.image = [self fixOrientation:[ip processHistogram:self.originImg]];
//    self.photo.image = rotate([ip processHistogram:self.originImg], UIImageOrientationLeft);
    self.photo.image = [ip processHistogram:self.originImg];
//    CGSize newSize  = CGSizeMake(self.originImg.size.width, self.originImg.size.height);
//    [self.photo.image imageByScalingToSize:newSize];


    
}
- (IBAction)filter:(id)sender {
    ImageProcessingImplementation *ip = [[ImageProcessingImplementation alloc] init];
    self.photo.image = [ip processFilter:self.originImg];

}
- (IBAction)binarize:(id)sender {
    ImageProcessingImplementation *ip = [[ImageProcessingImplementation alloc] init];
    self.photo.image = [ip processBinarize:self.originImg];
//    CGSize newSize  = CGSizeMake(self.originImg.size.width, self.originImg.size.height);
    
//    [self.photo.image imageByScalingToSize:newSize];

}
- (UIImage*)fixOrientation:(UIImage *)originalImage {
    UIImage *adjustedImage = [[UIImage alloc] initWithCGImage: originalImage.CGImage
                                                scale: 1.0
                                          orientation: UIImageOrientationLeft];
    return adjustedImage;
}

static inline double radians (double degrees) {return degrees * M_PI/180;}
UIImage* rotate(UIImage* src, UIImageOrientation orientation)
{
    UIGraphicsBeginImageContext(src.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orientation == UIImageOrientationRight) {
        CGContextRotateCTM (context, radians(90));
    } else if (orientation == UIImageOrientationLeft) {
        CGContextRotateCTM (context, radians(-90));
    } else if (orientation == UIImageOrientationDown) {
        // NOTHING
    } else if (orientation == UIImageOrientationUp) {
        CGContextRotateCTM (context, radians(90));
    }
    
    [src drawAtPoint:CGPointMake(0, 0)];
    
    return UIGraphicsGetImageFromCurrentImageContext();
}

- (IBAction)restore:(id)sender {
    self.photo.image = self.originImg;
    
    UIImage *originalImage = self.originImg;
    
    [self fixOrientation:originalImage];
    
}


@end
