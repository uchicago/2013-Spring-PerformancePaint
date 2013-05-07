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
@property (strong, nonatomic) UIImageView *backgroundView;
@property (strong, nonatomic) PaintView *paintView;
@property (strong, nonatomic) NSMutableArray *localImageCache;
@end

////////////////////////////////////////////////////////////////////////////////
@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
          
    //[self playVideo:@"NxeT_GDKv9g" frame:CGRectMake(5, 20, 200,200)];
    _localImageCache = [[NSMutableArray alloc] init];
}

- (void)viewDidAppear:(BOOL)animated
{
    // Create a background view to add image to
    _backgroundView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    _backgroundView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.backgroundView];
    
    // Create a painting view
    _paintView = [[PaintView alloc] initWithFrame:self.view.bounds];
    self.paintView.lineColor = [UIColor grayColor];
    self.paintView.delegate = self;
    self.paintView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.paintView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [self.localImageCache removeAllObjects];
    
}

/*******************************************************************************
 * @method          motionEnded:withEvent
 * @abstract
 * @description
 ******************************************************************************/
- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    
    // Test what kind of UIEventt type is recognized
    if (motion == UIEventTypeMotion && event.type == UIEventSubtypeMotionShake) {
        self.backgroundView.image = nil;
    }
}

#pragma mark - Paint View Delegagte Protocol Methods
/*******************************************************************************
 * @method          paintView:
 * @abstract
 * @description
 *******************************************************************************/
- (void)paintView:(PaintView*)paintView finishedTrackingPath:(CGPathRef)path inRect:(CGRect)painted
{
#ifdef OPTIMIZATION2
    [self mergePaintToBackgroundView:painted];
#else
    [self.paintView erase];
#endif
    
}

/*******************************************************************************
 * @method          mergePaintToBackgroundView
 * @abstract        Combine the last painted image into the current background image
 * @description
 *******************************************************************************/
- (void)mergePaintToBackgroundView:(CGRect)painted
{
    NSLog(@"Merging Paint");
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

#ifdef FEATURE_SCREENSHOT
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
    
    // This is only to show off instruments
    //[self.localImageCache addObject:image];
    //NSLog(@"local:%@",self.localImageCache);
}

- (BOOL)willAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

#pragma mark - Video
/*
 - (void)playVideo:(NSString *)urlString frame:(CGRect)frame
 {
 
 [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(youTubeStarted:) name:@"UIMoviePlayerControllerDidEnterFullscreenNotification" object:nil];
 [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(youTubeFinished:) name:@"UIMoviePlayerControllerDidExitFullscreenNotification" object:nil];
 [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemEnded:) name:@"AVPlayerItemDidPlayToEndTimeNotification" object:nil];
 
 NSString *embedHTML = @"<body style=\"margin:0\"> <iframe  webkit-playsinline height=\"200\" width=\"200\"  "
 "src=\"http://www.youtube.com/embed/%@\?feature=player_detailpage&playsinline=1\"   frameborder=\"0\"/></iframe></body> ";
 NSString *html = [NSString stringWithFormat:embedHTML, urlString, frame.size.width,        frame.size.height];
 
 
 UIWebView *videoView = [[UIWebView alloc] initWithFrame:frame];
 [videoView loadHTMLString:html baseURL:nil];
 [self.view addSubview:videoView];
 videoView.allowsInlineMediaPlayback = YES;
 videoView.layer.borderColor = [UIColor whiteColor].CGColor;
 videoView.layer.borderWidth = 5.0f;
 videoView.scrollView.scrollEnabled = NO;
 
 
 }
 -(void)youTubeStarted:(NSNotification *)notification{
 // your code here
 NSLog(@">>>>>>>>>> You tube full screen");
 }
 
 -(void)youTubeFinished:(NSNotification *)notification{
 // your code here
 NSLog(@">>>>>>>>>>>>>> You tube small screen");
 }
 - (void)playerItemEnded:(NSNotification *)notification
 {
 NSLog(@"Player ended");
 }
 */

@end