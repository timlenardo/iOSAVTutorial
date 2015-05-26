//
//  ViewController.m
//  Mirror
//
//  Created by Tim Lenardo on 5/21/15.
//  Copyright (c) 2015 tldesign. All rights reserved.
//

#import "ViewController.h"

#define DegreesToRadians(x) ((x) * M_PI / 180.0)

@interface ViewController ()

@end

@implementation ViewController

@synthesize imagePreview, captureImage, stillImageOutput, cameraSwitch;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    FrontCamera = NO;
    cameraSwitch.selectedSegmentIndex = 1;
    captureImage.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [self initCamera];
}

- (void)initCamera {
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    session.sessionPreset = AVCaptureSessionPresetPhoto;

    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    [captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    captureVideoPreviewLayer.frame = self.imagePreview.bounds;
    [self.imagePreview.layer addSublayer:captureVideoPreviewLayer];
    
    UIView *view = [self imagePreview];
    CALayer *viewLayer = [view layer];
    [viewLayer setMasksToBounds:YES];
    
    CGRect bounds = [imagePreview bounds];
    [captureVideoPreviewLayer setFrame:bounds];
    
    NSArray *devices = [AVCaptureDevice devices];
    AVCaptureDevice *frontCamera;
    AVCaptureDevice *backCamera;
    
    for (AVCaptureDevice *device in devices) {
        if ([device hasMediaType:AVMediaTypeVideo]) {
            if ([device position] == AVCaptureDevicePositionBack) {
                backCamera = device;
            }
            if ([device position] == AVCaptureDevicePositionFront) {
                frontCamera = device;
            }
        }
    }

    NSError *error = nil;
    if (!FrontCamera) {
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:&error];
        [session addInput:input];
    } else {
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:frontCamera error:&error];
        [session addInput:input];

    }
    
    stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [stillImageOutput setOutputSettings:outputSettings];
    
    [session addOutput:stillImageOutput];
    [session startRunning];
}

- (IBAction)snapImage:(id)sender {
    // [capturedImage removeFromSuperview];
    [self capImage];
}

- (void) capImage {
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in stillImageOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
                videoConnection = connection;
                break;
            }
        }
        
        if (videoConnection) {
            break;
        }
    }
    
    [stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
        if (imageSampleBuffer != NULL) {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
            [self processImage:[UIImage imageWithData:imageData]];
        }
        
    }];
}

- (void) processImage:(UIImage *)image {

    // Device is iPad
    if ([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad) {
        UIGraphicsBeginImageContext(CGSizeMake(image.size.width, image.size.height));
        [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
        UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        // CHANGED FROM TUTORIAL
        // Instead of cropping to the ImagePreview width and height, we're square cropping based on the image width
        CGRect cropRect = CGRectMake(0, 0, image.size.width, image.size.width);
        CGImageRef imageRef = CGImageCreateWithImageInRect([smallImage CGImage], cropRect);
        
        [captureImage setImage:[UIImage imageWithCGImage:imageRef]];
        CGImageRelease(imageRef);
        
        captureImage.hidden = NO;
        imagePreview.hidden = YES;
    }
    
    // Device is iPhone
    if ([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone) {
        UIGraphicsBeginImageContext(CGSizeMake(image.size.width, image.size.height));
        [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
        UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        // CHANGED FROM TUTORIAL
        // Instead of cropping to the ImagePreview width and height, we're square cropping based on the image width
        CGRect cropRect = CGRectMake(0, 0, image.size.width, image.size.width);
        CGImageRef imageRef = CGImageCreateWithImageInRect([smallImage CGImage], cropRect);
        
        [captureImage setImage:
         [UIImage imageWithCGImage:imageRef]];
        CGImageRelease(imageRef);

        captureImage.hidden = NO;
        imagePreview.hidden = YES;
    }
    
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft) {
        [UIView beginAnimations:@"rotate" context:nil];
        [UIView setAnimationDuration:0.5];
        captureImage.transform = CGAffineTransformMakeRotation(DegreesToRadians(-90));
        [UIView commitAnimations];
    }
    
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) {
        [UIView beginAnimations:@"rotate" context:nil];
        [UIView setAnimationDuration:0.5];
        captureImage.transform = CGAffineTransformMakeRotation(DegreesToRadians(90));
        [UIView commitAnimations];
    }
    
    
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown) {
        [UIView beginAnimations:@"rotate" context:nil];
        [UIView setAnimationDuration:0.5];
        captureImage.transform = CGAffineTransformMakeRotation(DegreesToRadians(180));
        [UIView commitAnimations];
    }
    
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait) {
        [UIView beginAnimations:@"rotate" context:nil];
        [UIView setAnimationDuration:0.5];
        captureImage.transform = CGAffineTransformMakeRotation(DegreesToRadians(0));
        [UIView commitAnimations];
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)switchCamera:(id)sender {
    if (cameraSwitch.selectedSegmentIndex == 0) {
        FrontCamera = YES;
        [self initCamera];
    } else {
        FrontCamera = NO;
        [self initCamera];
    }
}

@end
