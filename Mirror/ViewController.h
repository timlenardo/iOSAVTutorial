//
//  ViewController.h
//  Mirror
//
//  Created by Tim Lenardo on 5/21/15.
//  Copyright (c) 2015 tldesign. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController : UIViewController {
    
    BOOL FrontCamera;
    
}

@property(nonatomic, retain) AVCaptureStillImageOutput *stillImageOutput;
@property (strong, nonatomic) IBOutlet UIView *imagePreview;
@property (strong, nonatomic) IBOutlet UIImageView *captureImage;
@property (strong, nonatomic) IBOutlet UISegmentedControl *cameraSwitch;

- (IBAction)snapImage:(id)sender;
- (IBAction)switchCamera:(id)sender;

@end

