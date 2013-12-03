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

- (IBAction)textRecg:(id)sender {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.resultText animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"照片识别中";
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
//        Tesseract* tesseract = [[Tesseract alloc] initWithDataPath:@"tessdata" language:@"chi_sim"];
        Tesseract* tesseract = [[Tesseract alloc] initWithDataPath:@"tessdata" language:@"eng"];
        [tesseract setVariableValue:@"0123456789" forKey:@"tessedit_char_whitelist"];
        UIImage *large = [CTLViewController imageWithImage:self.photo.image];
        [tesseract setImage:large];
        [tesseract recognize];
        NSString *recoText = [tesseract recognizedText];
        NSLog(@"%@", recoText);
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
    self.photo.image = [ip processHistogram:self.originImg];
}
- (IBAction)filter:(id)sender {
    ImageProcessingImplementation *ip = [[ImageProcessingImplementation alloc] init];
    self.photo.image = [ip processFilter:self.originImg];
}
- (IBAction)binarize:(id)sender {
    ImageProcessingImplementation *ip = [[ImageProcessingImplementation alloc] init];
    self.photo.image = [ip processBinarize:self.originImg];
}
- (IBAction)restore:(id)sender {
    self.photo.image = self.originImg;
}


@end
