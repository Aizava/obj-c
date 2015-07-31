//
//  VRIGifConverterOperation.m
//  Monosnap
//
//  Created by kirill on 22/05/14.
//  Copyright (c) 2014 Monosnap. All rights reserved.
//

#import "VRIGifConverterOperation.h"
#import <AVFoundation/AVFoundation.h>
#import "VRIVideoViewer.h"
#import "MSAppDelegate.h"

@interface oneGifImageOperation : NSOperation
@property int quality;
@property int i;
@property CMTime kFrameCount;
@property AVAsset* asset;
@property AVAssetImageGenerator* imageGenerator;
@property CGImageDestinationRef destination;
@property NSDictionary *frameProperties;



@end
@implementation oneGifImageOperation
@synthesize quality,i,kFrameCount,asset,imageGenerator,destination,frameProperties;

-(void)main
{
    CGImageRef image;
    
    NSError* err;
    CMTime actualTime;
    CMTime requestedTime = CMTimeConvertScale(CMTimeMake(i, kFrameCount.timescale), asset.duration.timescale, kCMTimeRoundingMethod_RoundHalfAwayFromZero);
    image = [imageGenerator copyCGImageAtTime:requestedTime actualTime:&actualTime error:&err];
    CGImageDestinationAddImage(destination, image, (__bridge CFDictionaryRef)frameProperties);
    if (image != NULL)
        CGImageRelease(image);
}

@end


@implementation VRIGifConverterOperation
@synthesize path,finishPath,sender,fps,hideAfterFinish,maxPixels,quality;

+(unsigned long long)getFirstImageSize:(NSURL*)urlPath
{
    
    AVAsset* asset = [AVURLAsset URLAssetWithURL:urlPath options:nil];
    CMTime kFrameCount = CMTimeMakeWithSeconds(CMTimeGetSeconds(asset.duration), 10);
    AVAssetImageGenerator* imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
    imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    NSError* err;
    CMTime actualTime;
    CMTime requestedTime = CMTimeConvertScale(CMTimeMake(0, kFrameCount.timescale), asset.duration.timescale, kCMTimeRoundingMethod_RoundHalfAwayFromZero);
    CGImageRef image = [imageGenerator copyCGImageAtTime:requestedTime actualTime:&actualTime error:&err];
    
    
    
    NSDictionary *fileProperties = @{
                                     (__bridge id)kCGImagePropertyGIFDictionary: @{
                                             (__bridge id)kCGImagePropertyGIFLoopCount: @0,
                                             }
                                     };
    
    NSNumber* num = [NSNumber numberWithFloat:1.f/10];
    
    NSDictionary *frameProperties = @{
                                      (__bridge id)kCGImagePropertyGIFDictionary: @{
                                              (__bridge id)kCGImagePropertyGIFDelayTime: num,
                                              (__bridge id)kCGImagePropertyGIFUnclampedDelayTime: num
                                              }
                                      };
    
    NSString* filePath = [[MSSettingsManager instance] tmpDir]; // add your temp dir here
    filePath = [NSString stringWithFormat:@"%@/test.gif",filePath];
    
    NSFileManager* fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:filePath])
    {
        NSError* err;
        [fm removeItemAtPath:filePath error:&err];
    }
    
    NSURL* finishPath = [NSURL fileURLWithPath:filePath];
    
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)finishPath, kUTTypeGIF, 1, NULL);
    CGImageDestinationSetProperties(destination, (__bridge CFDictionaryRef)fileProperties);
    
    CGImageDestinationAddImage(destination, image, (__bridge CFDictionaryRef)frameProperties);
    if (!CGImageDestinationFinalize(destination)) {
        NSLog(@"failed to convert video to gif");
    }
    
    if (image != NULL)
        CGImageRelease(image);
    if (destination != NULL)
        CFRelease(destination);
    NSDictionary *attrs = [fm attributesOfItemAtPath: filePath error: NULL];
    NSUInteger sizeVal = [attrs fileSize]*kFrameCount.value;

    return sizeVal;
    NSImage* im = [[NSImage alloc] initWithCGImage:image size:NSMakeSize(CGImageGetWidth(image), CGImageGetHeight(image))];
    NSData* d = [im TIFFRepresentationUsingCompression:NSTIFFCompressionLZW factor:1];
    
    return d.length*kFrameCount.value/5;
}

-(void)main
{
    AVAsset* asset = [AVURLAsset URLAssetWithURL:path options:nil];
    CMTime kFrameCount = CMTimeMakeWithSeconds(CMTimeGetSeconds(asset.duration), fps);
    
    AVAssetImageGenerator* imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
    imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    if (quality < 99)
    {
        NSSize mSize = _size;
        mSize.width *= (double)quality/100;
        mSize.height *= (double)quality/100;
        imageGenerator.maximumSize = mSize;
    }
    NSDictionary *fileProperties = @{
                                     (__bridge id)kCGImagePropertyGIFDictionary: @{
                                             (__bridge id)kCGImagePropertyGIFLoopCount: @0,
                                             }
                                     };
    
    NSNumber* num = [NSNumber numberWithFloat:1.f/fps];
    
    NSDictionary *frameProperties = @{
                                      (__bridge id)kCGImagePropertyGIFDictionary: @{
                                              (__bridge id)kCGImagePropertyGIFDelayTime: num,
                                              (__bridge id)kCGImagePropertyGIFUnclampedDelayTime: num
                                              }
                                      };
    
    NSUInteger ind1 = (int)(kFrameCount.value*_T1);
    NSUInteger ind2 = (int)(kFrameCount.value*_T2);
    if (_T1 == 0)
        ind1 = 1;
    if (_T1 == 1)
        ind2 = kFrameCount.value;
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)finishPath, kUTTypeGIF, (ind2+1-ind1), NULL);
    CGImageDestinationSetProperties(destination, (__bridge CFDictionaryRef)fileProperties);
    
    MSAppDelegate* app = (MSAppDelegate*)[NSApplication sharedApplication].delegate;
    
    [app changeConvertingProgress:0]; // notification about progress, can be deleted
    
    for (NSUInteger i = ind1; i <= ind2; i++) {
        NSOperationQueue* queue = [NSOperationQueue mainQueue];
        oneGifImageOperation* op = [oneGifImageOperation new];
        op.quality = quality;
        op.i = i;
        op.kFrameCount = kFrameCount;
        op.asset = asset;
        op.imageGenerator = imageGenerator;
        op.destination = *(&destination);
        op.frameProperties = frameProperties;
        [queue addOperation:op];
        [op waitUntilFinished];
        
        double prog = 100 - (double)(ind2 - i)/(double)(ind2 - ind1 + 1)*100;
        [app changeConvertingProgress:prog]; // notification about progress, can be deleted
    }
    
    [app showProgressMessage:@"Finishing processing..."]; // notification about progress, can be deleted
    
    if (!CGImageDestinationFinalize(destination)) {
        NSLog(@"failed to convert video to gif");
    }
    
    if (destination != NULL)
        CFRelease(destination);
    [app finishUploadingProgress]; // notification about progress, can be deleted
}

@end
