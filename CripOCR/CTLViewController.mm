//
//  CTLViewController.m
//  CripOCR
//
//  Created by Zhaoyu Li on 10/16/13.
//  Copyright (c) 2013 Zhaoyu Li. All rights reserved.
//

#import "CTLViewController.h"
#import <TesseractOCR/TesseractOCR.h>

@interface CTLViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextView *resultText;
@property (weak, nonatomic) IBOutlet UIImageView *photo;
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
    [self dismissViewControllerAnimated:YES completion:nil];
    
    Tesseract* tesseract = [[Tesseract alloc] initWithDataPath:@"tessdata" language:@"chi_sim"];
    //    [tesseract setVariableValue:@"0123456789" forKey:@"tessedit_char_whitelist"];
    [tesseract setImage:image];
    [tesseract recognize];
    NSString *recoText = [tesseract recognizedText];
    NSLog(@"%@", recoText);
    [tesseract clear];
    self.resultText.text =recoText;
}


@end
