//
//  OcrCaptureSession.m
//  instaoverlay
//
//  Created by Kevin Li on 2013-10-18.
//  Copyright (c) 2012 Centling co,. ltd. All rights reserved.
//

#import "OcrCaptureSession.h"
#import <ImageIO/ImageIO.h>

@implementation OcrCaptureSession

@synthesize captureSession = _captureSession;
@synthesize previewLayer = _previewLayer;
@synthesize stillImageOutput = _stillImageOutput;
@synthesize stillImage = _stillImage;

- (id)init
{
	if ((self = [super init]))
    {
		[self setCaptureSession:[[AVCaptureSession alloc] init]];
	}
	return self;
}

- (void)addVideoPreviewLayer
{
	[self setPreviewLayer:[[AVCaptureVideoPreviewLayer alloc] initWithSession:[self captureSession]]];
	[_previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
}

- (void)makeAndApplyAffineTransform
{
	// translate, then scale, then rotate
    CGPoint effectiveTranslation = CGPointMake(0.0, 0.0);
	CGAffineTransform affineTransform = CGAffineTransformMakeTranslation(effectiveTranslation.x, effectiveTranslation.y);
#define effectiveScale 2.0f
	affineTransform = CGAffineTransformScale(affineTransform, effectiveScale, effectiveScale);
//	affineTransform = CGAffineTransformRotate(affineTransform, effectiveRotationRadians);
	[CATransaction begin];
	[CATransaction setAnimationDuration:.025];
	[_previewLayer setAffineTransform:affineTransform];
	[CATransaction commit];
}

- (void)addVideoInputFromCamera
{
    AVCaptureDevice *backCamera;
    
    NSArray *devices = [AVCaptureDevice devices];
    
    for (AVCaptureDevice *device in devices)
    {
        if ([device hasMediaType:AVMediaTypeVideo])
        {
            if ([device position] == AVCaptureDevicePositionBack)
            {
                backCamera = device;
                [self toggleFlash];
            }
        }
    }
    
    NSError *error = nil;
    
    AVCaptureDeviceInput *backFacingCameraDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:&error];
    
    if (!error)
    {
        if ([_captureSession canAddInput:backFacingCameraDeviceInput])
        {
            [_captureSession addInput:backFacingCameraDeviceInput];
        }
    }
}

- (void)setFlashOn:(BOOL)boolWantsFlash
{
    flashOn = boolWantsFlash;
    [self toggleFlash];
}

- (void)toggleFlash
{
    NSArray *devices = [AVCaptureDevice devices];
    
    for (AVCaptureDevice *device in devices)
    {
        if (device.flashAvailable) {
            if (flashOn)
            {
                [device lockForConfiguration:nil];
                device.flashMode = AVCaptureFlashModeOn;
                [device unlockForConfiguration];
            }
            else
            {
                [device lockForConfiguration:nil];
                device.flashMode = AVCaptureFlashModeOff;
                [device unlockForConfiguration];
            }
        }
    }
}

- (void)addStillImageOutput
{
    [self setStillImageOutput:[[AVCaptureStillImageOutput alloc] init]];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey,nil];
    [[self stillImageOutput] setOutputSettings:outputSettings];
    
    AVCaptureConnection *videoConnection = nil;
    
    for (AVCaptureConnection *connection in [_stillImageOutput connections])
    {
        for (AVCaptureInputPort *port in [connection inputPorts])
        {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] )
            {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection)
        {
            break;
        }
    }
    [_captureSession setSessionPreset:AVCaptureSessionPresetPhoto];
    [_captureSession addOutput:[self stillImageOutput]];
}

- (void)captureStillImage
{
	AVCaptureConnection *videoConnection = nil;
	for (AVCaptureConnection *connection in [[self stillImageOutput] connections])
    {
		for (AVCaptureInputPort *port in [connection inputPorts])
        {
			if ([[port mediaType] isEqual:AVMediaTypeVideo])
            {
				videoConnection = connection;
				break;
			}
		}
        
		if (videoConnection)
        {
            break;
        }
	}
    
	[_stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection
                                                         completionHandler:
     ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
         
         if (imageSampleBuffer)
         {
             CFDictionaryRef exifAttachments = CMGetAttachment(imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
             if (exifAttachments)
             {
                 //NSLog(@"attachements: %@", exifAttachments);
             } else
             {
                 //NSLog(@"no attachments");
             }
             NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
             UIImage *image = [[UIImage alloc] initWithData:imageData];
             [self setStillImage:image];
             
//            UIImage *image = [self addMetaDataWithMageSampleBuffer:imageSampleBuffer];
             UIImage *center = [self imageByCropping:image toSize:CGSizeMake(image.size.width/effectiveScale,  image.size.height/effectiveScale)];
            [self setStillImage:center];
             
             [[NSNotificationCenter defaultCenter] postNotificationName:kImageCapturedSuccessfully object:nil];
         }
     }];
}

- (UIImage *)imageByCropping:(UIImage *)image toSize:(CGSize)size
{
    double x = (image.size.width - size.width) / 2.0;
    double y = (image.size.height - size.height) / 2.0;
    
    CGRect cropRect = CGRectMake(x, y, size.height, size.width);
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
    
    UIImage *cropped = [UIImage imageWithCGImage:imageRef scale:1.0f orientation:UIImageOrientationRight];
    CGImageRelease(imageRef);
    
    return cropped;
}

-(UIImage*) addMetaDataWithMageSampleBuffer: (CMSampleBufferRef) imageSampleBuffer{
    NSData *imageNSData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
    
    CGImageSourceRef imgSource = CGImageSourceCreateWithData((__bridge_retained CFDataRef)imageNSData, NULL);
    
    //get all the metadata in the image
    NSDictionary *metadata = (__bridge NSDictionary *)CGImageSourceCopyPropertiesAtIndex(imgSource, 0, NULL);
    
    //make the metadata dictionary mutable so we can add properties to it
    NSMutableDictionary *metadataAsMutable = [metadata mutableCopy];
    
    NSMutableDictionary *EXIFDictionary = [[metadataAsMutable objectForKey:(NSString *)kCGImagePropertyExifDictionary]mutableCopy];
    NSMutableDictionary *GPSDictionary = [[metadataAsMutable objectForKey:(NSString *)kCGImagePropertyGPSDictionary]mutableCopy];
    NSMutableDictionary *RAWDictionary = [[metadataAsMutable objectForKey:(NSString *)kCGImagePropertyRawDictionary]mutableCopy];
    
    if(!EXIFDictionary)
        EXIFDictionary = [[NSMutableDictionary dictionary] init];
    
    if(!GPSDictionary)
        GPSDictionary = [[NSMutableDictionary dictionary] init];
    
    if(!RAWDictionary)
        RAWDictionary = [[NSMutableDictionary dictionary] init];
    
    
    [GPSDictionary setObject:[NSNumber numberWithFloat:37.795]
                      forKey:(NSString*)kCGImagePropertyGPSLatitude];
    
    [GPSDictionary setObject:@"N" forKey:(NSString*)kCGImagePropertyGPSLatitudeRef];
    
    [GPSDictionary setObject:[NSNumber numberWithFloat:122.410]
                      forKey:(NSString*)kCGImagePropertyGPSLongitude];
    
    [GPSDictionary setObject:@"W" forKey:(NSString*)kCGImagePropertyGPSLongitudeRef];
    
    [GPSDictionary setObject:@"2012:10:18"
                      forKey:(NSString*)kCGImagePropertyGPSDateStamp];
    
    [GPSDictionary setObject:[NSNumber numberWithFloat:300]
                      forKey:(NSString*)kCGImagePropertyGPSImgDirection];
    
    [GPSDictionary setObject:[NSNumber numberWithFloat:37.795]
                      forKey:(NSString*)kCGImagePropertyGPSDestLatitude];
    
    [GPSDictionary setObject:@"N" forKey:(NSString*)kCGImagePropertyGPSDestLatitudeRef];
    
    [GPSDictionary setObject:@(200.0001)
                      forKey:(NSString*)kCGImagePropertyGPSDestLongitude];
    
    [GPSDictionary setObject:@"W" forKey:(NSString*)kCGImagePropertyGPSDestLongitudeRef];
    
    [EXIFDictionary setObject:@"[S.D.] kCGImagePropertyExifUserComment"
                       forKey:(NSString *)kCGImagePropertyExifUserComment];
    
    [EXIFDictionary setObject:[NSNumber numberWithFloat:69.999]
                       forKey:(NSString*)kCGImagePropertyExifSubjectDistance];
    
    
    [EXIFDictionary setValue:[NSNumber numberWithFloat:400] forKey:(NSString *)kCGImagePropertyDPIWidth];
    [EXIFDictionary setValue:@"400" forKey:(NSString *)kCGImagePropertyDPIHeight];
    
    
    //Add the modified Data back into the image’s metadata
    [metadataAsMutable setObject:EXIFDictionary forKey:(NSString *)kCGImagePropertyExifDictionary];
    [metadataAsMutable setObject:GPSDictionary forKey:(NSString *)kCGImagePropertyGPSDictionary];
    [metadataAsMutable setObject:RAWDictionary forKey:(NSString *)kCGImagePropertyRawDictionary];
    [metadataAsMutable setObject:@(350) forKey:(NSString *)kCGImagePropertyDPIWidth];

    [metadataAsMutable setObject:@(350) forKey:(NSString *)kCGImagePropertyDPIHeight];

    
    
    CFStringRef UTI = CGImageSourceGetType(imgSource); //this is the type of image (e.g., public.jpeg)
    
    //this will be the data CGImageDestinationRef will write into
    NSMutableData *newImageData = [NSMutableData data];
    
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)newImageData, UTI, 1, NULL);
    
    if(!destination)
        NSLog(@"***Could not create image destination ***");
    
    //add the image contained in the image source to the destination, overidding the old metadata with our modified metadata
    CGImageDestinationAddImageFromSource(destination, imgSource, 0, (__bridge CFDictionaryRef) metadataAsMutable);
    
    //tell the destination to write the image data and metadata into our data object.
    //It will return false if something goes wrong
    BOOL success = NO;
    success = CGImageDestinationFinalize(destination);
    
    if(!success)
        NSLog(@"***Could not create data from image destination ***");
    
    CIImage *testImage = [CIImage imageWithData:newImageData];
    NSDictionary *propDict = [testImage properties];
    NSLog(@"Final properties %@", propDict);
    return [[UIImage alloc] initWithCIImage:testImage];
}


- (void)dealloc {
    
	[[self captureSession] stopRunning];
    
	_previewLayer = nil;
	_captureSession = nil;
    _stillImageOutput = nil;
    _stillImage = nil;
}

@end
