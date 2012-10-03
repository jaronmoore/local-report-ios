//
//  DIYCam.m
//  DIYCam
//
//  Created by Andrew Sliwinski on 5/29/12.
//  Copyright (c) 2012 DIY, Co. All rights reserved.
//

#import "DIYCam.h"

//

@interface DIYCam () <AVCaptureVideoDataOutputSampleBufferDelegate>
@property (nonatomic, assign) AVCaptureDeviceInput *videoCameraInput;
@property (atomic, retain) AVCaptureVideoDataOutput *movieOutput;
@property (atomic, retain) AVAssetImageGenerator *thumbnailGenerator;
@property (strong, nonatomic) AVAssetWriter *assetWriter;
@property (strong, nonatomic) AVAssetWriterInput *videoInput;
@property (atomic, retain) ALAssetsLibrary *library;

@property (atomic, retain) NSOperationQueue *queue;
@property (nonatomic) dispatch_queue_t queue_t;
@end

//

@implementation DIYCam

@synthesize delegate;
@synthesize session;
@synthesize preview;
@synthesize isRecording;
@synthesize videoCameraInput;
@synthesize movieOutput;
@synthesize thumbnailGenerator;
@synthesize assetWriter = _assetWriter;
@synthesize videoInput = _videoInput;
@synthesize library;
@synthesize queue;
@synthesize queue_t = _queue_t;
@synthesize frameRate = _frameRate;

#pragma mark - Init

-(dispatch_queue_t)queue_t
{
    if(!_queue_t){
        _queue_t = dispatch_queue_create("MyQueue", NULL);
    }
    return _queue_t;
}
-(NSNumber *)frameRate
{
    if(!_frameRate){
        _frameRate = [[NSNumber alloc]init];
    }
    return _frameRate;
}
- (AVAssetWriter *)assetWriter
{
    if(!_assetWriter){
        // Create URL to record to
        NSString *assetPath         = [self createAssetFilePath:@"mov"];
        NSURL *outputURL            = [[NSURL alloc] initFileURLWithPath:assetPath];
        NSFileManager *fileManager  = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:assetPath])
        {
            NSError *error;
            if ([fileManager removeItemAtPath:assetPath error:&error] == NO)
            {
                [[self delegate] camDidFail:self withError:error];
            }
        }
        
        _assetWriter =[[AVAssetWriter alloc]initWithURL:outputURL fileType:AVFileTypeMPEG4 error:nil];
    }
    return _assetWriter;
}

- (id)init
{
    self = [super init];
    if (self != nil) 
    {
        library     = [[ALAssetsLibrary alloc] init];
        queue       = [NSOperationQueue mainQueue];
        self.queue.maxConcurrentOperationCount = 2;
    }
    
    return self;
}

/**
 * Instanciates session and camera IO.
 *
 * @return  void
 */
- (void)setup
{
    if ([self isVideoCameraAvailable])
    {
        // Create session state
        // ---------------------------------
        session         = [[AVCaptureSession alloc] init];
        [self setIsRecording:false];
        
        // Flash & torch support
        // ---------------------------------
        if ([[self camera] hasFlash]) 
        {
            if ([[self camera] lockForConfiguration:nil]) 
            {
                if (DEVICE_FLASH) 
                {
                    if ([[self camera] isFlashModeSupported:AVCaptureFlashModeAuto]) {
                        [[self camera] setFlashMode:AVCaptureFlashModeAuto];
                    }
                } else {
                    if ([[self camera] isFlashModeSupported:AVCaptureFlashModeOff]) {
                        [[self camera] setFlashMode:AVCaptureFlashModeOff];
                    }
                }
                [[self camera] unlockForConfiguration];
            }
        }
        if ([[self camera] hasTorch]) 
        {
            if ([[self camera] lockForConfiguration:nil]) 
            {
                if (DEVICE_FLASH)
                {
                    if ([[self camera] isTorchModeSupported:AVCaptureTorchModeAuto]) 
                    {
                        [[self camera] setTorchMode:AVCaptureTorchModeAuto];
                    }
                } else {
                    if ([[self camera] isTorchModeSupported:AVCaptureTorchModeOff]) 
                    {
                        [[self camera] setTorchMode:AVCaptureTorchModeOff];
                    }
                }
                [[self camera] unlockForConfiguration];
            }
        }
        
        // Inputs
        // ---------------------------------
        AVCaptureDevice *videoDevice    = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if (videoDevice)
        {
            NSError *error;
            videoInput                  = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
            if (!error)
            {
                if ([session canAddInput:videoInput])
                {
                    [session addInput:videoInput];
                } else {
                    NSLog(@"Error: Couldn't add video input");
                }
            } else {
                [[self delegate] camDidFail:self withError:error];
            }
        } else {
            NSLog(@"Error: Couldn't create video capture device");
        }
        
        AVCaptureDevice *audioDevice    = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        if (audioDevice)
        {
            NSError *error              = nil;
            audioInput                  = nil;
            if (!error)
            {
                //[session addInput:audioInput];
            } else {
                [[self delegate] camDidFail:self withError:error];
            }
        }
        
        // Outputs
        // ---------------------------------
        self.movieOutput = [[AVCaptureVideoDataOutput alloc] init];
        self.movieOutput.alwaysDiscardsLateVideoFrames = NO;
        self.movieOutput.videoSettings =
        [NSDictionary dictionaryWithObject:
         [NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];     
        
        [session addOutput:self.movieOutput];
        [self setOutputProperties];
        
        // Preset
        // ---------------------------------
        [session setSessionPreset:VIDEO_PRESET];

      
        // Preview
        // ---------------------------------
        preview = [AVCaptureVideoPreviewLayer layerWithSession:session];
        preview.videoGravity    = AVLayerVideoGravityResizeAspectFill;
        //if (ORIENTATION_FORCE) {
        //[preview setVideoOrientation: ORIENTATION_OVERRIDE];
        //} else {
        //    preview.orientation = [[UIDevice currentDevice] orientation];
        //}
        
        // Start session
        // ---------------------------------
        [self startSession];
        [[self delegate] camReady:self];
        
        [self.movieOutput setSampleBufferDelegate:self queue:self.queue_t];

    }
}

- (void)startSession
{
    if (session != nil)
    {
        [session startRunning];
    }
}

- (void)stopSession
{
    if (session != nil)
    {
        [session stopRunning];
    }
}


#pragma mark - Video

- (BOOL)setupWriter
{
    NSDictionary *codecSettings = [[NSDictionary alloc] initWithObjectsAndKeys:self.frameRate, AVVideoAverageBitRateKey, nil];
    
    NSDictionary *videoOutputSettings       = [[NSDictionary alloc] initWithObjectsAndKeys:VIDEO_CODEC, AVVideoCodecKey, [NSNumber numberWithInt:VIDEO_HEIGHT], AVVideoWidthKey, [NSNumber numberWithInt:VIDEO_WIDTH], AVVideoHeightKey, codecSettings, AVVideoCompressionPropertiesKey, nil];
    self.videoInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo outputSettings:videoOutputSettings];
    self.videoInput.expectsMediaDataInRealTime = YES;
    
    [self.assetWriter addInput:self.videoInput];
    
    return YES;
}

/**
 * Start a video capture session.
 *
 * @return  void
 */
- (void)startVideoCapture
{    
    if (session != nil)
    {
        if ([self setupWriter]) {
            [self setIsRecording:true];
            [[self delegate] camCaptureStarted:self];
            return;
        }
    }
}

/**
 * Stop video capture session and save to disk.
 *
 * @return  void
 */
- (void)stopVideoCapture
{
    if (session != nil && self.isRecording)
    {
        [self setIsRecording:false];
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0) {
            [self.assetWriter finishWritingWithCompletionHandler:^{
                [self writeVideoToFileSystem:self.assetWriter.outputURL]; 
            }];
        } else {
            dispatch_queue_t writingQueue= dispatch_queue_create("finish writing queue", NULL);
            dispatch_async(writingQueue,^{
            [self.assetWriter finishWriting];
            [self writeVideoToFileSystem:self.assetWriter.outputURL];
            });
            dispatch_release(writingQueue);
        }
    }
}

/**
 * Persist video to asset library.
 *
 * @param  NSURL  Asset path
 *
 * @return  void
 */
- (void)writeVideoToAssetLibrary:(NSURL *)video
{
    // Asset library
    [library writeVideoAtPathToSavedPhotosAlbum:video completionBlock:^(NSURL *assetURL, NSError *error) {
        NSLog(@"Asset written to library: %@", assetURL);
    }];
}

/**
 * Return the video asset information.
 *
 * @param  NSURL  Asset path
 *
 * @return  void
 */
- (void)writeVideoToFileSystem:(NSURL *)video
{    
    [self stopSession];
    [self generateVideoThumbnail:[video absoluteString] success:^(UIImage *image, NSURL *thumbnail) {
        [[self delegate] camCaptureComplete:self withAsset:[NSDictionary dictionaryWithObjectsAndKeys:
                                                            [video absoluteString], @"path",
                                                            @"video", @"type",
                                                            [thumbnail absoluteString], @"thumbnail",
                                                            nil]];
    } failure:^(NSException *exception) {
        [[self delegate] camDidFail:self withError:[NSError errorWithDomain:@"com.diy.cam" code:0 userInfo:nil]];
    }];
}

#pragma mark - Utilities

- (NSString *)createAssetFilePath:(NSString *)extension
{
    NSArray *paths                  = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory    = [paths objectAtIndex:0];
    NSString *assetName             = [NSString stringWithFormat:@"%@.%@", [[NSProcessInfo processInfo] globallyUniqueString], extension];
    NSString *assetPath             = [documentsDirectory stringByAppendingPathComponent:assetName];
    
    return assetPath;
}

#pragma mark - Private methods

- (void) setOutputProperties
{
	AVCaptureConnection *CaptureConnection = [self.movieOutput connectionWithMediaType:AVMediaTypeVideo];
    
	// Set landscape (if required)
	if ([CaptureConnection isVideoOrientationSupported])
	{
		AVCaptureVideoOrientation orientation = ORIENTATION_DEFAULT;
		[CaptureConnection setVideoOrientation:orientation];
	}
    
	// Set frame rate (if requried)
	CMTimeShow(CaptureConnection.videoMinFrameDuration);
	CMTimeShow(CaptureConnection.videoMaxFrameDuration);
    
	if (CaptureConnection.supportsVideoMinFrameDuration)
    {
        CaptureConnection.videoMinFrameDuration = CMTimeMake(1, VIDEO_FPS);
    }
	if (CaptureConnection.supportsVideoMaxFrameDuration)
    {
        CaptureConnection.videoMaxFrameDuration = CMTimeMake(1, VIDEO_FPS);
    }
    
	CMTimeShow(CaptureConnection.videoMinFrameDuration);
	CMTimeShow(CaptureConnection.videoMaxFrameDuration);
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition) position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

- (AVCaptureDevice *)camera
{
    return [self cameraWithPosition:DEVICE_PRIMARY];
}

- (BOOL)isVideoCameraAvailable
{
	UIImagePickerController *picker     = [[UIImagePickerController alloc] init];
	NSArray *sourceTypes                = [UIImagePickerController availableMediaTypesForSourceType:picker.sourceType];
	[picker release];
    
	if (![sourceTypes containsObject:(NSString *)kUTTypeMovie])
    {
		return false;
	}
    
	return true;
}

#pragma mark - Operations

- (void)generateVideoThumbnail:(NSString*)url success:(void (^)(UIImage *image, NSURL *path))success failure:(void (^)(NSException *exception))failure
{
    // Setup
    AVURLAsset *asset                   = [[AVURLAsset alloc] initWithURL:[NSURL URLWithString:url] options:nil];
    Float64 durationSeconds             = CMTimeGetSeconds([asset duration]);
    CMTime thumbTime                    = CMTimeMakeWithSeconds(durationSeconds / 2.0, 600);

    // Generate
    self.thumbnailGenerator             = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    thumbnailGenerator.maximumSize      = CGSizeMake(VIDEO_THUMB_WIDTH, VIDEO_THUMB_HEIGHT);
    [thumbnailGenerator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:thumbTime]] completionHandler:^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error) {
        NSString *requestedTimeString = (NSString *)CMTimeCopyDescription(NULL, requestedTime);
        NSString *actualTimeString = (NSString *)CMTimeCopyDescription(NULL, actualTime);
        NSLog(@"Requested: %@; actual %@", requestedTimeString, actualTimeString);
        [requestedTimeString release];
        [actualTimeString release];
        
        //
        
        if (result != AVAssetImageGeneratorSucceeded) 
        {
            failure([NSException exceptionWithName:@"" reason:@"Could not generate video thumbnail" userInfo:nil]);
        } else {
            UIImage *sim = [UIImage imageWithCGImage:im];
            success(sim, [sim saveToCache]);
        }
        
        [asset release];
    }];
}

#pragma mark - AVCaptureFileOutputRecordingDelegate

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    BOOL RecordedSuccessfully = true;
    
    if ([error code] != noErr)
	{
        id value = [[error userInfo] objectForKey:AVErrorRecordingSuccessfullyFinishedKey];
        if (value)
		{
            RecordedSuccessfully = [value boolValue];
        }
    }
    
	if (RecordedSuccessfully)
	{
        [[self delegate] camCaptureProcessing:self];
        if (ASSET_LIBRARY) 
        {
            NSInvocationOperation *aOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(writeVideoToAssetLibrary:) object:outputFileURL];
            [queue addOperation:aOperation];
            [aOperation release];
        }
        NSInvocationOperation *fOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(writeVideoToFileSystem:) object:outputFileURL];
        [queue addOperation:fOperation];
        [fOperation release];
	} else {
        [[self delegate] camDidFail:self withError:error];
    }
}


- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    if( !CMSampleBufferDataIsReady(sampleBuffer) )
    {
        NSLog( @"sample buffer is not ready. Skipping sample" );
        return;
    }
    
    
    if(self.isRecording == YES )
    {
        CMTime lastSampleTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
        if( self.assetWriter.status != AVAssetWriterStatusWriting  )
        {
            [self.assetWriter startWriting];
            [self.assetWriter startSessionAtSourceTime:lastSampleTime];
        }
        
        if( captureOutput ==  self.movieOutput )
            [self newVideoSample:sampleBuffer];
        
    }
}

-(void) newVideoSample:(CMSampleBufferRef)sampleBuffer
{     
    if( self.isRecording )
    {
        if( self.assetWriter.status > AVAssetWriterStatusWriting )
        {
            NSLog(@"Warning: writer status is %d", self.assetWriter.status);
            if(self.assetWriter.status == AVAssetWriterStatusFailed )
                NSLog(@"Error: %@", self.assetWriter.error);
            return;
        }
        while (self.videoInput.readyForMoreMediaData == FALSE) {
            NSDate *maxDate = [NSDate dateWithTimeIntervalSinceNow:0.1];
            [[NSRunLoop currentRunLoop] runUntilDate:maxDate];
        }

        if( ![self.videoInput appendSampleBuffer:sampleBuffer] )
            NSLog(@"Unable to write to video input");
        
    }
    
}




#pragma mark - Dealloc

- (void)releaseObjects
{
    [[self session] stopRunning];
    
    delegate = nil;
    
    [session release]; session = nil;
    [stillImageOutput release]; stillImageOutput = nil;
    [movieFileOutput release]; movieFileOutput = nil;
    [thumbnailGenerator release]; thumbnailGenerator = nil;
    [library release]; library = nil;
    self.assetWriter = nil;
    self.videoInput = nil;
}

- (void)dealloc
{
    [self releaseObjects];
    [super dealloc];
}

@end