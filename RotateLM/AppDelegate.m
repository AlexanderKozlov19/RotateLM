//
//  AppDelegate.m
//  RotateLM
//
//  Created by Alexander Kozlov on 12.02.2018.
//  Copyright © 2018 eCozy. All rights reserved.
//



#import "AppDelegate.h"
#import "VTKRendererWindow.h"

@implementation AppDelegate {
     VTKRendererWindow *windowVTK;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    windowVTK = [[VTKRendererWindow alloc] initWithWindowNibName:@"VTKRendererWindow"];
    [windowVTK showWindow:self];
    [windowVTK drawModel];
    

}

@end
