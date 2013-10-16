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

@interface CTLViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextView *resultText;
@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (strong, nonatomic) UIImage *originImg;
@end

@implementation CTLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)takePhoto:(id)sender {
    UIImagePickerController *pikcer  = [[UIImagePickerController alloc] init];
    pikcer.allowsEditing = YES;
    pikcer.delegate = self;
    pikcer.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:pikcer animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if (!image) image = info[UIImagePickerControllerOriginalImage];
    self.photo.image = image;
    self.originImg = image;
    [self dismissViewControllerAnimated:YES completion:nil];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.resultText animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"照片识别中";
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        Tesseract* tesseract = [[Tesseract alloc] initWithDataPath:@"tessdata" language:@"chi_sim"];
        [tesseract setImage:image];
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

}

@end
