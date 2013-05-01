//
//  ViewController.m
//  PaintPerformance
//
//  Created by T. Andrew Binkowski on 4/30/13.
//  Copyright (c) 2013 UChicago Mobi. All rights reserved.
//


#import "ViewController.h"
#import "PaintView.h"
#import <QuartzCore/QuartzCore.h>

////////////////////////////////////////////////////////////////////////////////
@interface ViewController ()
@property BOOL shouldMerge;
@property (strong, nonatomic) UIImageView *backgroundView;
@property (strong, nonatomic) PaintView *paintView;
@end

////////////////////////////////////////////////////////////////////////////////
@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Create a background view to add image to
    _backgroundView = [[UIImageView alloc] initWithFrame:self.view.frame];
    _backgroundView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.backgroundView];
    
    // Create a painting view
    _paintView = [[PaintView alloc] initWithFrame:self.view.bounds];
    self.paintView.lineColor = [UIColor grayColor];
    self.paintView.delegate = self;
    [self.view addSubview:self.paintView];
    
#ifdef PERFORMANCE2
    // Optimization Flags
    self.shouldMerge = NO;
#endif
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Paint View Delegagte Protocol Methods
/*******************************************************************************
 * @method          paintView:
 * @abstract
 * @description
 *******************************************************************************/
- (void)paintView:(PaintView*)paintView finishedTrackingPath:(CGPathRef)path inRect:(CGRect)painted
{
    if (self.shouldMerge) {
        [self mergePaintToBackgroundView:painted];
    }
}

/*******************************************************************************
 * @method          mergePaintToBackgroundView
 * @abstract        Combine the last painted image into the current background image
 * @description
 *******************************************************************************/
- (void)mergePaintToBackgroundView:(CGRect)painted
{
    // Create a new offscreen buffer that will be the UIImageView's image
    CGRect bounds = self.backgroundView.bounds;
    UIGraphicsBeginImageContextWithOptions(bounds.size, NO, self.backgroundView.contentScaleFactor);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Copy the previous background into that buffer.  Calling CALayer's renderInContext: will redraw the view if necessary
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    [self.backgroundView.layer renderInContext:context];
    
    // Now copy the painted contect from the paint view into our background image
    // and clear the paint view.  as an optimization we set the clip area so that we only copy the area of paint view
    // that was actually painted
    CGContextClipToRect(context, painted);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    [self.paintView.layer renderInContext:context];
    [self.paintView erase];
    
    // Create UIImage from the context
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    self.backgroundView.image = image;
    UIGraphicsEndImageContext();
    
#ifdef PERFORMANCE3
    // Save the image to the photolibrary
    NSData *data = UIImagePNGRepresentation(image);
    UIImageWriteToSavedPhotosAlbum([UIImage imageWithData:data], nil, nil, nil);
    
    // Save the image to the photolibrary in the background
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *data = UIImagePNGRepresentation(image);
        UIImageWriteToSavedPhotosAlbum([UIImage imageWithData:data], nil, nil, nil);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"\n>>>>> Done saving in background...");//update UI here
    });
    });
#endif
    
}


@end