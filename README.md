# GifConverter
This tiny library provides a way to convert video file like .mov in .gif format. It is used in Monosnap application for OSX.

VRIGifConverterOperation - subclass of NSOperation and can be runned in NSOperationQueue object.

##Params

* path - movie path in local disk
* finishPath - movie saving path
* fps - frames per second, can't be more then video fps. Monosnap uses [1;15] values
* quality - quiality of single image. int value from 1 to 100. Where 100 is source quality
* size - the size of single frame in movie.
Also movie can be trimmed with T1 and T2 params. Where T1 always less then T2. 0 is the start of the movie file and 1 is end of the file. For example : we got movie which length is 60 seconds. T1 = 0.5 and T2 = 1 will trimm the movie from 30 seconds to 60 seconds.
* T1 - double value from 0 to 1. 
* T2 - double value from 0 to 1


##Example of use
<pre><code>NSOperationQueue* queue = [NSOperationQueue new];
VRIGifConverterOperation* op = [VRIGifConverterOperation new];
op.path = @"video_path";
op.finishPath = @"saving_path";
op.fps = 15;
op.quality = 100;
op.size = NSMakeSize(320, 480);
op.maxPixels = (int)op.size.width*(int)op.size.height;
op.T1 = 0.2;
op.T2 = 0.8;
[queue addOperation:op];
</code></pre>




