//
//  ViewController.h
//  PerformancePaint
//
//  Created by T. Andrew Binkowski on 5/1/13.
//  Copyright (c) 2013 UChicago Mobi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaintView.h"

@interface ViewController : UIViewController <PaintViewDelegate>

- (void)paintView:(PaintView*)paintView finishedTrackingPath:(CGPathRef)path inRect:(CGRect)painted;

@end
