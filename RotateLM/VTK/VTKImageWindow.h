//
//  VTKImageWindow.h
//  RotateLM
//
//  Created by Alexander Kozlov on 28.02.2018.
//  Copyright © 2018 eCozy. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class BasicVTKView;
#import "vtkSmartPointer.h"
#import "vtkImageData.h"

@interface VTKImageWindow : NSWindowController
@property (weak) IBOutlet BasicVTKView *vtkView;

-(void)showImages:(vtkSmartPointer<vtkImageData>*)inData withSize:(int)size;

@end
