//
//  VTKRendererWindow.m
//  
//
//  Created by Alexander Kozlov on 26.02.2018.
//
#import <Foundation/Foundation.h>

#import "VTKRendererWindow.h"
#import "BasicVTKView.h"
#import "VTKImageWindow.h"

#import "vtkInteractorStyleSwitch.h"
#import "vtkCocoaRenderWindowInteractor.h"
#import "vtkConeSource.h"
#import "vtkCylinderSource.h"
#import "vtkPolyDataMapper.h"
#import "vtkSmartPointer.h"
#import "vtkDebugLeaks.h"
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



@interface VTKRendererWindow ()



@end

const int countSlices = 16;

@implementation VTKRendererWindow
{
    VTKImageWindow *imageWindow;
    
    vtkSmartPointer<vtkActor> actor;
    vtkSmartPointer<vtkCamera> camera;
    vtkSmartPointer<vtkPlane> plane;
    vtkSmartPointer<vtkClipDataSet> clipDataSet;
    vtkSmartPointer<vtkPlane> plane2;
    vtkSmartPointer<vtkClipDataSet> clipDataSet2;
    vtkSmartPointer<vtkTransformFilter> transformFilter;
    vtkSmartPointer<vtkPolyDataMapper> coneMapper;
    vtkSmartPointer<vtkDataSetMapper> clipperMapper;
    
    vtkSmartPointer<vtkClipDataSet> clipDataSets[ countSlices ];
    vtkSmartPointer<vtkPlane> planes[ countSlices ];
    vtkSmartPointer<vtkDataSetMapper> graphicMappers[countSlices];
    vtkSmartPointer<vtkActor> graphicActors[countSlices];
    vtkSmartPointer<vtkRenderer> graphicRenderers[countSlices];
    vtkSmartPointer<vtkRenderWindow> graphicRenderWindows[countSlices];
    vtkSmartPointer<vtkWindowToImageFilter> windowToImageFilters[countSlices];
    
    
    vtkSmartPointer<vtkDataSetMapper> graphicMapper;
    vtkSmartPointer<vtkActor> graphicActor;
    vtkSmartPointer<vtkRenderer> graphicRenderer;
    vtkSmartPointer<vtkRenderWindow> graphicRenderWindow;
    vtkSmartPointer<vtkWindowToImageFilter> windowToImageFilter;
    vtkSmartPointer<vtkPNGWriter> writer;
    vtkSmartPointer<vtkImageData> arrayImages[ countSlices];
    
    BOOL isInit;
    BOOL isThreadRunning;
    
}


- (id)init
{
    isInit = false;
    isThreadRunning = false;
    
    self = [super init];
    //[super init];
    
    if (self != nil)
    {
        
    }
    
    return self;
}


- (void)windowDidLoad {
    isInit = false;
    
    [super windowDidLoad];
    imageWindow = [[VTKImageWindow alloc] initWithWindowNibName:@"VTKImageWindow"];
    [imageWindow showWindow:self];
    
     [vtkView initializeVTKSupport];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(onPositionMoved:)
                                                 name: @"onPositionMoved"
                                               object: nil];

    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(onRotation:)
                                                 name: @"onRotation"
                                               object: nil];
}

-(void)drawModel {
    
  //  dispatch_async(dispatch_get_main_queue(),
  //                 ^{
                       NSBundle* myBundle = [NSBundle mainBundle];
                       
                       
                       NSString* objectPath = [myBundle pathForResource:@"work" ofType:@"obj"];
                       
                       std::string filename = std::string([objectPath UTF8String]);
                       
                       vtkSmartPointer<vtkOBJReader> reader = vtkSmartPointer<vtkOBJReader>::New();
                       reader->SetFileName(filename.c_str());
                       reader->Update();
                       
                       vtkSmartPointer<vtkTransform> transform = vtkSmartPointer<vtkTransform>::New();
                       transform->Scale(0.1,0.1,0.1);
    
      /*vtkSmartPointer<vtkPolyData> polydata2 = reader->GetOutput();
    
    vtkSmartPointer<vtkDecimatePro> decimate =
    vtkSmartPointer<vtkDecimatePro>::New();

    decimate->SetInputConnection( reader->GetOutputPort());

    //decimate->SetTargetReduction(.99); //99% reduction (if there was 100 triangles, now there will be 1)
    decimate->SetTargetReduction(.99); //10% reduction (if there was 100 triangles, now there will be 90)
    decimate->Update();
    */
                       
                       transformFilter = vtkSmartPointer<vtkTransformFilter>::New();
                       transformFilter->SetInputConnection(reader->GetOutputPort());
                       transformFilter->SetTransform(transform);
    
                        transformFilter->Update();
    
    
                        vtkSmartPointer<vtkPointSet> pointSet = transformFilter->GetOutput();
    
                       vtkSmartPointer<vtkPolyData> polydata = reader->GetOutput();
                       
                       double bounds[6];
                       polydata->GetBounds( bounds);
                        pointSet->GetBounds( bounds );
                       
                       plane = vtkSmartPointer<vtkPlane>::New();
                       plane->SetOrigin(0,0.0,0.0);
                       plane->SetNormal(0,0,1);
                       
                       clipDataSet = vtkSmartPointer<vtkClipDataSet>::New();
                       clipDataSet->SetClipFunction(plane);
                        clipDataSet->SetInputConnection( transformFilter->GetOutputPort() );//transformFilter->GetOutputPort());
                       clipDataSet->SetValue(0.0);
                       clipDataSet->InsideOutOn();
                       //clipDataSet->GenerateClippedOutputOn();
                       
                       
                       clipDataSet->Update();
    /*
                        plane2 = vtkSmartPointer<vtkPlane>::New();
                        plane2->SetOrigin(0.0,0.0,-5.0);
                        plane2->SetNormal(0,0,1);
                       
                        clipDataSet2 = vtkSmartPointer<vtkClipDataSet>::New();
                        clipDataSet2->SetClipFunction(plane2);
                        clipDataSet2->SetInputConnection( clipDataSet->GetOutputPort(0));
                        clipDataSet2->SetValue(0.0);
                        clipDataSet2->InsideOutOff();
                        // clipDataSet2->GenerateClippedOutputOn();
                        clipDataSet2->Update();
                       */
                       clipperMapper = vtkSmartPointer<vtkDataSetMapper>::New();
                       clipperMapper->SetInputConnection(clipDataSet->GetOutputPort(0));
                       clipperMapper->ScalarVisibilityOff();
                       
                       
                       coneMapper = vtkSmartPointer<vtkPolyDataMapper>::New();
                       coneMapper->SetInputConnection(transformFilter->GetOutputPort() );// clipperMapper->GetOutputPort());
    
                       
                       
                       actor = vtkSmartPointer<vtkActor>::New();
                       actor->SetMapper(clipperMapper);
                       //    actor->GetMapper()->Update();
                       
                       
                       
                       
                       camera = vtkSmartPointer<vtkCamera>::New();
                       camera->SetPosition(000, -00, 40);
                       camera->SetFocalPoint(0, 0, 0);
                       
                    //   [vtkView getRenderer]->SetActiveCamera(camera);
                       
                    //   [vtkView getRenderer]->AddActor(actor);
                       
                       //    [vtkView getRenderer]->GetRenderWindow()->Render();
                       
                       // Tell the system that the view needs to be redrawn
                     //  [vtkView setNeedsDisplay:YES];
    
                        [self splitCurrentModel];
                       // Some code
                //   });
   
    for ( int i = 0; i < countSlices; i++) {
        planes[i] = vtkSmartPointer<vtkPlane>::New();
        planes[i]->SetNormal(0, 0, 1);
        planes[i]->SetOrigin(0, 0, 0);
        
        clipDataSets[i] = vtkSmartPointer<vtkClipDataSet>::New();
        clipDataSets[i]->SetClipFunction(planes[i]);
        if ( i == 0 )
            clipDataSets[i]->SetInputConnection( transformFilter->GetOutputPort() );
        else
            clipDataSets[i]->SetInputConnection( clipDataSets[i -1 ]->GetOutputPort(0));
        clipDataSets[i]->SetValue(0.0);
        clipDataSets[i]->InsideOutOn();
        clipDataSets[i]->GenerateClippedOutputOn();
        clipDataSets[i]->Update();
        
        arrayImages[i] = vtkSmartPointer<vtkImageData>::New();
        
        graphicMappers[i] = vtkSmartPointer<vtkDataSetMapper>::New();
        graphicMappers[i]->SetInputConnection(clipDataSets[i]->GetOutputPort(0));
        graphicMappers[i]->ScalarVisibilityOff();
        
        graphicActors[i] = vtkSmartPointer<vtkActor>::New();
        graphicActors[i]->SetMapper(graphicMappers[i]);
        
        graphicRenderers[i] = vtkSmartPointer<vtkRenderer>::New();
        graphicRenderWindows[i] = vtkSmartPointer<vtkRenderWindow>::New();
        graphicRenderWindows[i]->SetSize(1920, 1080);
        graphicRenderWindows[i]->SetOffScreenRendering(1);
        graphicRenderWindows[i]->AddRenderer(graphicRenderers[i]);
        
        // add the actors to the scene
        graphicRenderers[i]->AddActor(graphicActors[i]);
        graphicRenderers[i]->SetActiveCamera( camera );
        
        graphicRenderWindows[i]->Render();
        
        windowToImageFilters[i] = vtkSmartPointer<vtkWindowToImageFilter>::New();
        windowToImageFilters[i]->SetInput(graphicRenderWindows[i]);
       // windowToImageFilter->SetMagnification(3);
        windowToImageFilters[i]->Update();
        
    }
    
    graphicMapper = vtkSmartPointer<vtkDataSetMapper>::New();
    graphicMapper->SetInputConnection(clipDataSets[0]->GetOutputPort(0));
    graphicMapper->ScalarVisibilityOff();
    
    graphicActor = vtkSmartPointer<vtkActor>::New();
    graphicActor->SetMapper(graphicMapper);
    
    graphicRenderer = vtkSmartPointer<vtkRenderer>::New();
    graphicRenderWindow = vtkSmartPointer<vtkRenderWindow>::New();
    graphicRenderWindow->SetSize(1920, 1080);
    graphicRenderWindow->SetOffScreenRendering(1);
    graphicRenderWindow->AddRenderer(graphicRenderer);
    
    // add the actors to the scene
    graphicRenderer->AddActor(graphicActor);
    graphicRenderer->SetActiveCamera( camera );
    
    graphicRenderWindow->Render();
    
    windowToImageFilter = vtkSmartPointer<vtkWindowToImageFilter>::New();
    windowToImageFilter->SetInput(graphicRenderWindow);
  //  windowToImageFilter->SetMagnification(3);
    windowToImageFilter->Update();
    
    writer =  vtkSmartPointer<vtkPNGWriter>::New();
    writer->SetInputConnection(windowToImageFilter->GetOutputPort());
    
    isInit = true;
}

-(void)onRotation:(NSNotification*)data {

    if ( isThreadRunning ) return;

  //  dispatch_async(dispatch_get_main_queue(),
  //                 ^{
                       NSDictionary *dictionary = data.object;
                       int axe = [dictionary[@"axe"] intValue];
                       float value = [dictionary[@"value"] floatValue];
                       
                       
                       const float moveDiscreet = 1;
                       
                       
                       switch ( axe ) {
                           case 0:
                               if ( value > 0 ) {
                                   actor->RotateX( -moveDiscreet );
                                   graphicActor->RotateX( -moveDiscreet );
                                   
                                   for ( int i = 0; i < countSlices; i++ )
                                     graphicActors[i]->RotateX( -moveDiscreet );
                               }
                               else {
                                   actor->RotateX( moveDiscreet);
                                   graphicActor->RotateX( moveDiscreet );
                                   
                                   for ( int i = 0; i < countSlices; i++ )
                                    graphicActors[i]->RotateX( moveDiscreet );
                               }
                               break;
                               
                           case 1:
                               if ( value > 0 ) {
                                   actor->RotateZ( moveDiscreet );
                                   graphicActor->RotateZ( moveDiscreet );
                                   
                                   for ( int i = 0; i < countSlices; i++ )
                                    graphicActors[i]->RotateZ( moveDiscreet );
                               }
                               else {
                                   actor->RotateZ( -moveDiscreet);
                                   graphicActor->RotateZ( -moveDiscreet );
                                   
                                   for ( int i = 0; i < countSlices; i++ )
                                     graphicActors[i]->RotateZ( -moveDiscreet );
                               }
                               break;
                               
                           case 2:
                               if ( value > 0 ) {
                                   actor->RotateY( moveDiscreet );
                                   graphicActor->RotateY( moveDiscreet );
                                   
                                   for ( int i = 0; i < countSlices; i++ )
                                    graphicActors[i]->RotateY( moveDiscreet );
                               }
                               else {
                                   actor->RotateY( -moveDiscreet);
                                   graphicActor->RotateY( -moveDiscreet );
                                   
                                   for ( int i = 0; i < countSlices; i++ )
                                    graphicActors[i]->RotateY( -moveDiscreet );
                               }
                               break;
                               
                           default:
                               break;
                       }
                       
                       
 //     [vtkView setNeedsDisplay:YES];
    
    [self splitCurrentModel];
       //            });
    

   
    
}

-(void)onPositionMoved:(NSNotification*)data {
    
    if ( isThreadRunning ) return;
    
    NSDictionary *dictionary = data.object;
    int axe = [dictionary[@"axe"] intValue];
    float value = [dictionary[@"value"] floatValue];
    
    const float moveDiscreet = 0.5;
    double x, y, z;
    double *pos = actor->GetPosition();
    x = pos[0];
    y = pos[1];
    z = pos[2];
    
    double bounds[6];// = actor->GetBounds();
    vtkSmartPointer<vtkPointSet> pointSet = transformFilter->GetOutput();
    pointSet->GetBounds( bounds );
    NSLog(@"%f", bounds[0]);
        
        switch ( axe ) {
            case 0:
                if ( value >= 0)
             
                    x += moveDiscreet;
                else
                    x += -moveDiscreet;
                break;
                
            case 2:
                if ( value >= 0)
                    z += moveDiscreet;
                else
                    z += -moveDiscreet;
                break;
                
            case 1:
                if ( value >= 0)
                    y += moveDiscreet;
                else
                    y += -moveDiscreet;
                break;
                
            default:
                break;
        }
    
    actor->SetPosition( x, y, z);
    graphicActor->SetPosition( x, y, z);
    
    for ( int i = 0; i < countSlices; i++ )
        graphicActors[i]->SetPosition( x, y, z);
  //  [vtkView setNeedsDisplay:YES];
    [self splitCurrentModel];
}

-(void)splitCurrentModel {
    
    
    //double *bounds = actor->GetBounds();
    if ( !isInit ) return;
    if ( isThreadRunning ) return;
    
    isThreadRunning = true;
    [NSThread detachNewThreadSelector: @selector(splitCurrentModelInThread) toTarget:self withObject:nil];
    return;
    
    
    
    double bounds[6];// = actor->GetBounds();
    vtkSmartPointer<vtkPointSet> pointSet = transformFilter->GetOutput();
    pointSet->GetBounds( bounds );
    
    double divX = ( bounds[1] - bounds[0] ) / countSlices;
    double divY = ( bounds[3] - bounds[2] ) / countSlices;
    double divZ = ( bounds[5] - bounds[4] ) / countSlices;
    
    double middleX = bounds[0] + divX;
    double middleY = bounds[2] + divY;
    double startZ = bounds[5] - divZ;
    double endZ = bounds[4];
    NSLog(@"%f - %f, %f - %f, %f - %f, %f", bounds[0], bounds[1], bounds[2], bounds[3], bounds[4], bounds[5], divZ);
  //  vtkSmartPointer<vtkAlgorithmOutput> source =  transformFilter->GetOutputPort();
   
    
    //actor->SetMapper(clipperMapper);
    // [vtkView setNeedsDisplay:YES];
    
    
    /*
    vtkSmartPointer<vtkClipDataSet> clipDataSetPrev;
    
    int iNum = 0;
    NSLog( @"1" );
    while ( startZ > ( bounds[4] ) ) {
        NSLog( @"2" );
        plane->SetOrigin( middleX, middleY, startZ);
          NSLog( @"21" );
        vtkSmartPointer<vtkClipDataSet> clipDataSetLoc = vtkSmartPointer<vtkClipDataSet>::New();
          NSLog( @"22" );
        clipDataSetLoc->SetClipFunction(plane);
          NSLog( @"23" );

        clipDataSetLoc->SetInputConnection( source );//transformFilter->GetOutputPort());
          NSLog( @"24" );
        clipDataSetLoc->SetValue(0.0);
          NSLog( @"25" );
        clipDataSetLoc->InsideOutOn();
          NSLog( @"26" );
        clipDataSetLoc->GenerateClippedOutputOn();
          NSLog( @"27" );
        
        clipDataSetLoc->Update();
          NSLog( @"28" );
        
        clipDataSetLoc->GetOutput();
        source = clipDataSetLoc->GetOutputPort(1);
          NSLog( @"29" );
        clipDataSetPrev = clipDataSetLoc;
        
        
     //   NSLog( @"4" );
     //   plane2->SetOrigin( middleX, middleY, startZ - divZ );
     //   NSLog( @"5" );
     //   clipDataSet2->Update();
        
        /*NSString *filename = [[NSString alloc] initWithFormat:@"/users/alexanderkozlov/downloads/Slice/slice%d.png", iNum];
         vtkSmartPointer<vtkPNGWriter> writer =  vtkSmartPointer<vtkPNGWriter>::New();
        writer->SetInputConnection(clipDataSet2->GetOutputPort(0));
        writer->SetFileName([filename UTF8String]);
        writer->Write();
        */
       /*
      
        startZ -= divZ;
        iNum++;
    }
    */
    
   
   
    
    NSLog(@"start");
    
   dispatch_group_t d_group = dispatch_group_create();
    dispatch_queue_t bg_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    
    for ( int i = 0; i < countSlices; i++ ) {
     
        planes[i]->SetOrigin( middleX, middleY, startZ);
        //   NSLog(@"2");
        clipDataSets[i]->Update();
        //    NSLog(@"3");
        graphicMappers[i]->SetInputConnection(clipDataSets[i]->GetOutputPort(1));
        
        graphicRenderWindows[i]->Render();
        /*
        
        windowToImageFilters[i]->Modified();
        windowToImageFilters[i]->Update();
        
         arrayImages[i]->ShallowCopy( windowToImageFilters[i]->GetOutput());
        */
        dispatch_group_async(d_group, bg_queue, ^{
            [self doSlice:i forX:middleX forY:middleY forZ:startZ];
        });
        
        
       /*
    //    NSLog(@"1");
        planes[i]->SetOrigin( middleX, middleY, startZ);
      //   NSLog(@"2");
        clipDataSets[i]->Update();
     //    NSLog(@"3");
        graphicMappers[i]->SetInputConnection(clipDataSets[i]->GetOutputPort(1));
        
        //graphicRenderWindow->Render();
        windowToImageFilters[i]->Modified();
        windowToImageFilters[i]->Update();
        
     //   NSLog(@"4");
        //arrayImages[i] = vtkSmartPointer<vtkImageData>::New();
        //arrayImages[i] = windowToImageFilter->GetOutput();
        arrayImages[i]->ShallowCopy( windowToImageFilters[i]->GetOutput());
       // graphicRenderWindow->Render();
       /*
        windowToImageFilter->Modified();
         NSLog(@"5");
        NSString *filename = [[NSString alloc] initWithFormat:@"/users/alexanderkozlov/downloads/Slice/slice%d.png", i];
       NSLog(@"6");
          writer->SetInputConnection(windowToImageFilter->GetOutputPort());
         NSLog(@"7");
        writer->SetFileName([filename UTF8String]);
         NSLog(@"8");
        writer->Write();
         NSLog(@"9");
        */
        startZ -= divZ;
        
    }
    dispatch_group_wait(d_group, DISPATCH_TIME_FOREVER);
 
    NSLog(@"finish");
    
     clipperMapper->SetInputConnection(clipDataSets[countSlices / 2 ]->GetOutputPort(1));
    int *dims = arrayImages[0]->GetDimensions();
    NSLog(@"dim %d %d", dims[0], dims[1]);
    
//     [vtkView setNeedsDisplay:YES];
    [imageWindow showImages:&arrayImages[0] withSize:countSlices];
    

    
  //  actor->SetMapper(coneMapper);
  //   [vtkView setNeedsDisplay:YES];
    
    

    
}

-(void)splitCurrentModelInThread {
   
    double bounds[6];// = actor->GetBounds();
    
    vtkSmartPointer<vtkPointSet> pointSet = transformFilter->GetOutput();
    pointSet->GetBounds( bounds );
    
    double divX = ( bounds[1] - bounds[0] ) / countSlices;
    double divY = ( bounds[3] - bounds[2] ) / countSlices;
    double divZ = ( bounds[5] - bounds[4] ) / countSlices;
    
    double middleX = bounds[0] + divX;
    double middleY = bounds[2] + divY;
    double startZ = bounds[5] - divZ;
    double endZ = bounds[4];
    NSLog(@"%f - %f, %f - %f, %f - %f, %f", bounds[0], bounds[1], bounds[2], bounds[3], bounds[4], bounds[5], divZ);
    
    NSLog(@"start");
    
    dispatch_group_t d_group = dispatch_group_create();
    dispatch_queue_t bg_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    
    for ( int i = 0; i < countSlices; i++ ) {
        
        planes[i]->SetOrigin( middleX, middleY, startZ);
        //   NSLog(@"2");
        clipDataSets[i]->Update();
        //    NSLog(@"3");
        graphicMappers[i]->SetInputConnection(clipDataSets[i]->GetOutputPort(1));
        
        graphicRenderWindows[i]->Render();
        /*
         
         windowToImageFilters[i]->Modified();
         windowToImageFilters[i]->Update();
         
         arrayImages[i]->ShallowCopy( windowToImageFilters[i]->GetOutput());
         */
        dispatch_group_async(d_group, bg_queue, ^{
            [self doSlice:i forX:middleX forY:middleY forZ:startZ];
        });

        startZ -= divZ;
        
    }
    dispatch_group_wait(d_group, DISPATCH_TIME_FOREVER);
    
    NSLog(@"finish");
    
   // clipperMapper->SetInputConnection(clipDataSets[countSlices / 2 ]->GetOutputPort(1));
    //int *dims = arrayImages[0]->GetDimensions();
    //NSLog(@"dim %d %d", dims[0], dims[1]);
    
   dispatch_async(dispatch_get_main_queue(), ^{
      //  [vtkView setNeedsDisplay:YES];
        [imageWindow showImages:&arrayImages[0] withSize:countSlices];
    });
    
    isThreadRunning = false;
    
}

-(void)doSlice:(int)index forX:(double)middleX forY:(double)middleY forZ:(double)middleZ {
  /* planes[index]->SetOrigin( middleX, middleY, middleZ);
    clipDataSets[index]->Update();
    graphicMappers[index]->SetInputConnection(clipDataSets[index]->GetOutputPort(1));
   
    graphicRenderWindows[index]->Render();
   */
 //    windowToImageFilters[index]->SetMagnification( 1 );
   windowToImageFilters[index]->Modified();
     windowToImageFilters[index]->Update();

    arrayImages[index]->ShallowCopy( windowToImageFilters[index]->GetOutput());
}

@end
