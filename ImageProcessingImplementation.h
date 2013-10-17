//
//  ImageProcessingImplementation.h
//  InfojobOCR
//
//  Created by Kevin Li on 2013-10-17
//  Copyright (c) 2012 Centling, co,. ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageProcessingProtocol.h"



@interface ImageProcessingImplementation : NSObject<ImageProcessingProtocol>


- (UIImage*) processImage:(UIImage*) src;
- (NSString*) pathToLangugeFIle;
- (UIImage*) processRotation:(UIImage*)src;
- (UIImage*) processHistogram:(UIImage*)src;
- (UIImage*) processFilter:(UIImage*)src;
- (UIImage*) processBinarize:(UIImage*)src;


@end
