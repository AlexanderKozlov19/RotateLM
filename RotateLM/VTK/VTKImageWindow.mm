//
//  VTKImageWindow.m
//  RotateLM
//
//  Created by Alexander Kozlov on 28.02.2018.
//  Copyright © 2018 eCozy. All rights reserved.
//

#import "VTKImageWindow.h"
#import "BasicVTKView.h"

#import "vtkInteractorStyleSwitch.h"
#import "vtkCocoaRenderWindowInteractor.h"
#import "vtkConeSource.h"
#import "vtkCylinderSource.h"
#import "vtkPolyDataMapper.h"
#include "vtkOBJReader.h"
#include "vtkPlane.h"
#include "vtkClipDataSet.h"
#include "vtkDataSetMapper.h"
#include "vtkCamera.h"
#include "vtkTransform.h"
#include "vtkTransformFilter.h"
#include "vtkPNGWriter.h"
#include "vtkWindowToImageFilter.h"
#include "vtkDecimatePro.h"
#include "vtkAlgorithmOutput.h"

#include "vtkJPEGReader.h"

#import "vtkSmartPointer.h"
#import "vtkDebugLeaks.h"
#include "vtkImageMapper.h"
#include "vtkActor2D.h"
#include "vtkRenderer.h"
#include "vtkRenderWindow.h"
#include "vtkImageData.h"



@interface VTKImageWindow ()

@end

const int countSlices = 16;

@implementation VTKImageWindow {
    vtkSmartPointer<vtkImageMapper> mapper;
    vtkSmartPointer<vtkActor2D> actor;
    
    vtkSmartPointer<vtkImageData> imageData[countSlices];
    int currentImageNum;
    
    NSTimer *timerUpdate;
    
    BOOL isMapped;
    NSLock *lockImages;
}


- (void)windowDidLoad {
    [super windowDidLoad];
    [self.vtkView initializeVTKSupport];
    lockImages = [[NSLock alloc] init];
    isMapped = NO;
    mapper = vtkSmartPointer<vtkImageMapper>::New();
    actor = vtkSmartPointer<vtkActor2D>::New();

    mapper->SetColorWindow(255); // width of the color range to map to
    mapper->SetColorLevel(127.5); // c
    mapper->SetRenderToRectangle( 1 );
    
    
    for ( int i = 0; i < countSlices; i++ )
        imageData[i] = vtkSmartPointer<vtkImageData>::New();
    
    timerUpdate = nil;

    //actor->SetMapper(mapper);
    
 //   [self.vtkView getRenderer]->AddActor(actor);
    
 //   [self.vtkView setNeedsDisplay:YES];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

-(void)showImages:(vtkSmartPointer<vtkImageData>*)inData withSize:(int)size {
    
    [lockImages lock];
    for ( int i = 0; i < countSlices; i++)
        imageData[i]->ShallowCopy( inData[i]);
    [lockImages unlock];
    //vtkSmartPointer<vtkJPEGReader> reader = vtkSmartPointer<vtkJPEGReader>::New();
   // reader->SetFileName("/Users/AlexanderKozlov/Downloads/26639.jpg");
    //reader->Update(); // why is this necessary? shouldn't the VTK pipeline take care of this automatically?
    
   // mapper->SetInputData( reader->GetOutput());
 //   mapper->SetInputData( inData[3]);
 //   mapper->SetColorWindow(255); // width of the color range to map to
 //   mapper->SetColorLevel(127.5); // c
    
    if ( !isMapped ) {
        actor->SetMapper(mapper);
        [self.vtkView getRenderer]->AddActor(actor);
        isMapped = YES;
        
        NSTimeInterval timeInterval = 1.0 / countSlices;
        currentImageNum = 0;
        // actor->SetPosition( 30, 30);
        actor->SetWidth( 1.0);
        actor->SetHeight( 1.0);
        double * position = actor->GetPosition();
        NSLog(@"pos %f, %f", position[0], position[1]);
        double * positioncoords = actor->GetPosition2();
        NSLog(@"coord %f, %f", positioncoords[0], positioncoords[1]);
        double width = actor->GetWidth();
        double heigth = actor->GetHeight();
        NSLog(@"width :%f, heigth: %f", width, heigth);
        // actor->SetWidth( self.vtkView.frame.size.width );
        //   actor->SetHeight( self.vtkView.frame.size.height);
        //    actor->SetPosition2( 0, 0 );
        
        timerUpdate = [NSTimer scheduledTimerWithTimeInterval: timeInterval
                                                       target: self
                                                     selector:@selector(onTick:)
                                                     userInfo: nil repeats:YES];
        

    }
     /*
    if ( timerUpdate != nil ) {
       
        [timerUpdate invalidate];
        timerUpdate = nil;
    }
 
    NSTimeInterval timeInterval = 1.0 / countSlices;
    currentImageNum = 0;
   // actor->SetPosition( 30, 30);
    actor->SetWidth( 1.0);
    actor->SetHeight( 1.0);
    double * position = actor->GetPosition();
    NSLog(@"pos %f, %f", position[0], position[1]);
    double * positioncoords = actor->GetPosition2();
    NSLog(@"coord %f, %f", positioncoords[0], positioncoords[1]);
    double width = actor->GetWidth();
    double heigth = actor->GetHeight();
    NSLog(@"width :%f, heigth: %f", width, heigth);
   // actor->SetWidth( self.vtkView.frame.size.width );
 //   actor->SetHeight( self.vtkView.frame.size.height);
//    actor->SetPosition2( 0, 0 );

    timerUpdate = [NSTimer scheduledTimerWithTimeInterval: timeInterval
                                                   target: self
                                                 selector:@selector(onTick:)
                                                 userInfo: nil repeats:YES];
     */
   // [self.vtkView setNeedsDisplay:YES];
}

-(void)onTick:(NSTimer*)timer {
    [lockImages lock];
    mapper->SetInputData( imageData[currentImageNum]);
    [lockImages unlock];
    [self.vtkView setNeedsDisplay:YES];
    
    currentImageNum++;
    if ( currentImageNum >= countSlices )
        currentImageNum = 0;
    
}

@end
