//
//  CTLViewController.m
//  CripOCR
//
//  Created by Zhaoyu Li on 10/16/13.
//  Copyright (c) 2013 Zhaoyu Li. All rights reserved.
//

#import "CTLViewController.hpp"
#import <TesseractOCR/TesseractOCR.h>
#import <dispatch/dispatch.h>
#import "MBProgressHUD.h"
#import "UIImage+OpenCV.h"
#import "ImageProcessingImplementation.h"

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
    
 }
- (IBAction)textRecg:(id)sender {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.resultText animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"照片识别中";
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        Tesseract* tesseract = [[Tesseract alloc] initWithDataPath:@"tessdata" language:@"chi_sim"];
        [tesseract setImage:self.photo.image];
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
    cv::Mat grayMat = [self.originImg CVGrayscaleMat];
    self.photo.image = [[UIImage alloc] initWithCVMat:grayMat];
}

- (IBAction)cropPaper:(id)sender {
    cv::Mat inputMat = [self.originImg CVMat];
    std::vector<std::vector<cv::Point> > rect = [self findSquaresInImage:inputMat];
    cv::Mat paperMat = debugSquares(rect, inputMat);
    self.photo.image = [[UIImage alloc] initWithCVMat:paperMat];
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

double angle( cv::Point pt1, cv::Point pt2, cv::Point pt0 ) {
    double dx1 = pt1.x - pt0.x;
    double dy1 = pt1.y - pt0.y;
    double dx2 = pt2.x - pt0.x;
    double dy2 = pt2.y - pt0.y;
    return (dx1*dx2 + dy1*dy2)/sqrt((dx1*dx1 + dy1*dy1)*(dx2*dx2 + dy2*dy2) + 1e-10);
}

- (std::vector<std::vector<cv::Point> >)findSquaresInImage:(cv::Mat)_image
{
    std::vector<std::vector<cv::Point> > squares;
    cv::Mat pyr, timg, gray0(_image.size(), CV_8U), gray;
    int thresh = 50, N = 11;
    cv::pyrDown(_image, pyr, cv::Size(_image.cols/2, _image.rows/2));
    cv::pyrUp(pyr, timg, _image.size());
    std::vector<std::vector<cv::Point> > contours;
    for( int c = 0; c < 3; c++ ) {
        int ch[] = {c, 0};
        mixChannels(&timg, 1, &gray0, 1, ch, 1);
        for( int l = 0; l < N; l++ ) {
            if( l == 0 ) {
                cv::Canny(gray0, gray, 0, thresh, 5);
                cv::dilate(gray, gray, cv::Mat(), cv::Point(-1,-1));
            }
            else {
                gray = gray0 >= (l+1)*255/N;
            }
            cv::findContours(gray, contours, CV_RETR_LIST, CV_CHAIN_APPROX_SIMPLE);
            std::vector<cv::Point> approx;
            for( size_t i = 0; i < contours.size(); i++ )
            {
                cv::approxPolyDP(cv::Mat(contours[i]), approx, arcLength(cv::Mat(contours[i]), true)*0.02, true);
                if( approx.size() == 4 && fabs(contourArea(cv::Mat(approx))) > 1000 && cv::isContourConvex(cv::Mat(approx))) {
                    double maxCosine = 0;
                    
                    for( int j = 2; j < 5; j++ )
                    {
                        double cosine = fabs(angle(approx[j%4], approx[j-2], approx[j-1]));
                        maxCosine = MAX(maxCosine, cosine);
                    }
                    
                    if( maxCosine < 0.3 ) {
                        squares.push_back(approx);
                    }
                }
            }
        }
    }
    return squares;
}

cv::Mat debugSquares( std::vector<std::vector<cv::Point> > squares, cv::Mat image )
{
    for ( int i = 0; i< squares.size(); i++ ) {
        // draw contour
        cv::drawContours(image, squares, i, cv::Scalar(255,0,0), 1, 8, std::vector<cv::Vec4i>(), 0, cv::Point());
        
        // draw bounding rect
        cv::Rect rect = boundingRect(cv::Mat(squares[i]));
        cv::rectangle(image, rect.tl(), rect.br(), cv::Scalar(0,255,0), 2, 8, 0);
        
        // draw rotated rect
        cv::RotatedRect minRect = minAreaRect(cv::Mat(squares[i]));
        cv::Point2f rect_points[4];
        minRect.points( rect_points );
        for ( int j = 0; j < 4; j++ ) {
            cv::line( image, rect_points[j], rect_points[(j+1)%4], cv::Scalar(0,0,255), 1, 8 ); // blue
        }
    }
    
    return image;
}

void find_squares(cv::Mat& image, std::vector<std::vector<cv::Point> >& squares)
{
    // blur will enhance edge detection
    cv::Mat blurred(image);
    medianBlur(image, blurred, 9);
    
    cv::Mat gray0(blurred.size(), CV_8U), gray;
    std::vector<std::vector<Point> > contours;
    
    // find squares in every color plane of the image
    for (int c = 0; c < 3; c++)
    {
        int ch[] = {c, 0};
        mixChannels(&blurred, 1, &gray0, 1, ch, 1);
        
        // try several threshold levels
        const int threshold_level = 2;
        for (int l = 0; l < threshold_level; l++)
        {
            // Use Canny instead of zero threshold level!
            // Canny helps to catch squares with gradient shading
            if (l == 0)
            {
                Canny(gray0, gray, 10, 20, 3); //
                
                // Dilate helps to remove potential holes between edge segments
                dilate(gray, gray, cv::Mat(), cv::Point(-1,-1));
            }
            else
            {
                gray = gray0 >= (l+1) * 255 / threshold_level;
            }
            
            // Find contours and store them in a list
            findContours(gray, contours, CV_RETR_LIST, CV_CHAIN_APPROX_SIMPLE);
            
            // Test contours
            std::vector<cv::Point> approx;
            for (size_t i = 0; i < contours.size(); i++)
            {
                // approximate contour with accuracy proportional
                // to the contour perimeter
                approxPolyDP(cv::Mat(contours[i]), approx, arcLength(cv::Mat(contours[i]), true)*0.02, true);
                
                // Note: absolute value of an area is used because
                // area may be positive or negative - in accordance with the
                // contour orientation
                if (approx.size() == 4 &&
                    fabs(contourArea(cv::Mat(approx))) > 1000 &&
                    isContourConvex(cv::Mat(approx)))
                {
                    double maxCosine = 0;
                    
                    for (int j = 2; j < 5; j++)
                    {
                        double cosine = fabs(angle(approx[j%4], approx[j-2], approx[j-1]));
                        maxCosine = MAX(maxCosine, cosine);
                    }
                    
                    if (maxCosine < 0.3){
                        squares.push_back(approx);
                    }
                    
                }
            }
        }
    }
}

@end
