## obj-c
This tiny class can convert .mov file into .gif with params.

#Example of use

<pre><code>NSOperationQueue* queue = [NSOperationQueue new];
VRIGifConverterOperation* op = [VRIGifConverterOperation new];
op.path = @"video_path";
op.finishPath = @"saving_path";
op.fps = 15; // fps value from 1 to max movie fps
op.quality = // gif quality from 1 to 100. Where 100 is source quality
op.size = ...; // width and height of movie
op.maxPixels = (int)size.width*(int)size.height;
op.T1 = ... ; //trimmer start value. [0,1] double
op.T2 = ... ; //trimmer finish value. [0,1] double
[queue addOperation:op];
</code></pre>




