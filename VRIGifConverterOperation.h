//
//  VRIGifConverterOperation.h
//  Monosnap
//
//  Created by kirill on 22/05/14.
//  Copyright (c) 2014 Monosnap. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VRIGifConverterOperation : NSOperation
@property  NSURL* path;
@property  NSURL* finishPath;
@property int fps;
@property int quality;
@property double T1;
@property double T2;
@property NSSize size;

@end
