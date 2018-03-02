//
//  VTKRendererWindow.h
//  
//
//  Created by Alexander Kozlov on 26.02.2018.
//

#import <Cocoa/Cocoa.h>
@class BasicVTKView;

@interface VTKRendererWindow : NSWindowController {
    IBOutlet BasicVTKView *vtkView;
}

-(void)drawModel;


@end
