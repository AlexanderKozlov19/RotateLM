//
//  GameViewController.m
//  RotateLM
//
//  Created by Alexander Kozlov on 12.02.2018.
//  Copyright © 2018 eCozy. All rights reserved.
//

#import "GameViewController.h"
#import <SpriteKit/SpriteKit.h>
#import <Foundation/Foundation.h>




@implementation GameViewController {
    LeapListenerClass *leapListener;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // create a new scene
    SCNScene *scene = [SCNScene sceneNamed:@"art.scnassets/TIE3.scn"];
    
    /* // create and add a camera to the scene
    SCNNode *cameraNode = [SCNNode node];
   // cameraNode.camera = [SCNCamera camera];
    //[scene.rootNode addChildNode:cameraNode];
    
    // place the camera
    //cameraNode.position = SCNVector3Make(0, 20, 10);
    
    // create and add a light to the scene
    SCNNode *lightNode = [SCNNode node];
    lightNode.light = [SCNLight light];
    lightNode.light.type = SCNLightTypeOmni;
    lightNode.position = SCNVector3Make(0, 10, 10);
    [scene.rootNode addChildNode:lightNode];
    
    // create and add an ambient light to the scene
    SCNNode *ambientLightNode = [SCNNode node];
    ambientLightNode.light = [SCNLight light];
    ambientLightNode.light.type = SCNLightTypeAmbient;
    ambientLightNode.light.color = [NSColor darkGrayColor];
    [scene.rootNode addChildNode:ambientLightNode];
    
    // retrieve the ship node
    SCNNode *ship = [scene.rootNode childNodeWithName:@"TIE.dae" recursively:YES];
    
    // animate the 3d object
    [ship runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:2 z:0 duration:1]]];
    */
    SKScene *spriteScene = [[SKScene alloc] initWithSize:self.view.bounds.size];
    
    /*  NSArray *arrayLabels = @[ @"X:", @"-", @"+", @"Y:", @"-", @"+", @"Z:", @"-", @"+"];
    NSInteger xPos = 10;
    NSInteger yPos = self.view.bounds.size.height - 20;
    NSInteger counter = 0;
    
    for ( NSString *label in arrayLabels ) {
        SKLabelNode *labelNode = [SKLabelNode labelNodeWithText:label];
        labelNode.fontColor = [NSColor whiteColor];
        labelNode.fontName = @"Arial";
        labelNode.fontSize = 16;
        if ( ( counter % 3 ) == 1 )
            labelNode.position = CGPointMake( xPos, yPos + 1);
        else
            labelNode.position = CGPointMake( xPos, yPos);
        if ( (counter % 3 ) != 0 ) {
            
            SKShapeNode *round = [[SKShapeNode alloc] init];
            
            CGMutablePathRef myPath = CGPathCreateMutable();
            CGPathAddArc(myPath, NULL, xPos + 1, yPos + 7, 7, 0, M_PI*2, YES);
            round.path = myPath;
            
            round.lineWidth = 0.1;
            round.fillColor = [SKColor blackColor];
            round.strokeColor = [SKColor whiteColor];
            round.glowWidth = 0.0;

            
            
            labelNode.userInteractionEnabled = YES;
            labelNode.name = [arrayLabels[ counter % 3] stringByAppendingString:[NSString stringWithFormat:@"%ld", ( counter / 3 )]];
            
            round.name = labelNode.name;
            
            [spriteScene addChild:round];
        }
        
        
        
        [spriteScene addChild:labelNode];
        
        counter++;
        if ( (counter % 3 ) == 0 ) {
            xPos = 10;
            yPos -= 20;
        }
        else {
            xPos += 20;
        }
            
            
    }
    */
    NSClickGestureRecognizer *clicker = [[NSClickGestureRecognizer alloc] initWithTarget:self action:@selector(onClick:)];
    
    NSMutableArray *gestureRecognizers2 = [NSMutableArray array];
    [gestureRecognizers2 addObject:clicker];
    [gestureRecognizers2 addObjectsFromArray:spriteScene.view.gestureRecognizers];
    spriteScene.view.gestureRecognizers = gestureRecognizers2;
    
    //[spriteScene.view addGestureRecognizer:clicker];
    

    
    // retrieve the SCNView
    SCNView *scnView = (SCNView *)self.view;
    
    scnView.overlaySKScene = spriteScene;
    scnView.overlaySKScene.userInteractionEnabled = NO;
    
    
    
    // set the scene to the view
    scnView.scene = scene;
    
    // allows the user to manipulate the camera
    scnView.allowsCameraControl = YES;
    
    // show statistics such as fps and timing information
    scnView.showsStatistics = YES;
    
    // configure the view
    scnView.backgroundColor = [NSColor blackColor];
    
    // Add a click gesture recognizer
    NSClickGestureRecognizer *clickGesture = [[NSClickGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    NSMutableArray *gestureRecognizers = [NSMutableArray array];
    [gestureRecognizers addObject:clickGesture];
    [gestureRecognizers addObjectsFromArray:scnView.gestureRecognizers];
    scnView.gestureRecognizers = gestureRecognizers;
    
    //-------- Notification
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(onPositionMoved:)
                                                 name: @"onPositionMoved"
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(onRotation:)
                                                 name: @"onRotation"
                                               object: nil];
    
    //-------- Leap Motion
    leapListener = [[LeapListenerClass alloc] init];
    [leapListener run];
    
    
}

-(void)onClick:(NSGestureRecognizer*)gestureRecognizer {
    NSLog(@"tap");
}

- (void)handleTap:(NSGestureRecognizer *)gestureRecognizer {
    // retrieve the SCNView
    SCNView *scnView = (SCNView *)self.view;
    NSLog(@"click");
    
    // check what nodes are tapped
    CGPoint p = [gestureRecognizer locationInView:scnView];
    NSArray *hitResults = [scnView hitTest:p options:nil];
    
    
    
    // check that we clicked on at least one object
    if ([hitResults count] > 0) {
        // retrieved the first clicked object
        SCNHitTestResult *result = [hitResults objectAtIndex:0];
        
        // get its material
        SCNMaterial *material = result.node.geometry.firstMaterial;
        
        // highlight it
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:0.5];
        
        // on completion - unhighlight
        [SCNTransaction setCompletionBlock:^{
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.5];
            
            material.emission.contents = [NSColor blackColor];
            
            [SCNTransaction commit];
        }];
        
        material.emission.contents = [NSColor redColor];
        
        [SCNTransaction commit];
    }
    
    SKView *spriteView = scnView.overlaySKScene.view;
    CGPoint p2 = [gestureRecognizer locationInView:spriteView];
    
    SCNNode *node = [scnView.overlaySKScene nodeAtPoint:p2];
    
    if ( ( node != nil ) && ( node.name != nil ) ) {
        if ( [node.name length] == 2 ) { // изменение по X,Y,Z
            BOOL increment = [node.name characterAtIndex:0] == '+';
            unichar axe = [node.name characterAtIndex:1];
            [self moveCameraForAxe:axe inDirection:increment];
        }
    }
    /*
    NSArray *clickResults = [spriteView hitTest:p2];
    NSLog(@"%@", clickResults);
     */
}

-(void)moveCameraForAxe:(unichar)axe inDirection:(BOOL)isIncrement {
    SCNView *scnView = (SCNView *)self.view;
    SCNNode *node = [scnView.scene.rootNode childNodeWithName:@"TIE-fighter_obj" recursively:YES];
    if ( node != nil ) {
        
        
        SCNVector3 vectorMin, vectorMax;
        [node getBoundingBoxMin:&vectorMin max:&vectorMax];
        SCNMatrix4 matrixOld = node.pivot;
        SCNVector3 center = node.position;
        node.pivot = SCNMatrix4MakeTranslation( 1,
                                               1,
                                              1 );
        SCNMatrix4 matrixNew = node.pivot;
        SCNVector4 currentPosition = node.rotation;
        NSLog(@"%f", currentPosition.x);
        switch (axe) {
            case '0':
                if ( isIncrement )
                    [node runAction:[SCNAction rotateByAngle:0.2 aroundAxis:SCNVector3Make(1, 0, 0) duration:0.1]];//:0.0 y:1 z:0 duration:1]];
                else
                    [node runAction:[SCNAction rotateByAngle:-0.2 aroundAxis:SCNVector3Make(1, 0, 0) duration:0.1]];
                    //[node runAction:[SCNAction rotateByX:0.0 y:-1 z:0 duration:1]];
                break;
                
            case '1':
                if ( isIncrement )
                    [node runAction:[SCNAction rotateByAngle:0.2 aroundAxis:SCNVector3Make(0, 1, 0) duration:0.1]];//:0.0 y:1 z:0 duration:1]];
                else
                    [node runAction:[SCNAction rotateByAngle:-0.2 aroundAxis:SCNVector3Make(0, 1, 0) duration:0.1]];
                break;
                
            case '2':
                if ( isIncrement )
                    [node runAction:[SCNAction rotateByAngle:0.2 aroundAxis:SCNVector3Make(0, 0, 1) duration:0.1]];//:0.0 y:1 z:0 duration:1]];
                else
                    [node runAction:[SCNAction rotateByAngle:-0.2 aroundAxis:SCNVector3Make(0, 0, 1) duration:0.1]];
                break;
                
            default:
                break;
        }
        
        /*currentPosition.w = 0.5;
        
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:0.5];
        
        // on completion - unhighlight
        [SCNTransaction setCompletionBlock:^{
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.5];
            
            node.rotation = currentPosition;
            
            [SCNTransaction commit];
        }];
        
      
        
        [SCNTransaction commit];
*/
    }
}

-(void)onRotation:(NSNotification*)data {
    NSDictionary *dictionary = data.object;
    int axe = [dictionary[@"axe"] intValue];
    float value = [dictionary[@"value"] floatValue];
    SCNView *scnView = (SCNView *)self.view;
    SCNNode *node = [scnView.scene.rootNode childNodeWithName:@"TIE-fighter_obj" recursively:YES];
    
    const float moveDiscreet = 0.01;
    
    if ( node != nil ) {
        SCNVector3 currentPosition = node.position;
        
        switch ( axe ) {
            case 0:
                if ( value > 0 )
                    [node runAction:[SCNAction rotateByAngle:-moveDiscreet aroundAxis:SCNVector3Make(1, 0, 0) duration:0.1]];//:0.0 y:1 z:0 duration:1]];
                else
                    [node runAction:[SCNAction rotateByAngle:moveDiscreet aroundAxis:SCNVector3Make(1, 0, 0) duration:0.1]];
                //[node runAction:[SCNAction rotateByX:0.0 y:-1 z:0 duration:1]];
                break;
                
            case 1:
                if ( value > 0 )
                    [node runAction:[SCNAction rotateByAngle:moveDiscreet aroundAxis:SCNVector3Make(0, 1, 0) duration:0.1]];//:0.0 y:1 z:0 duration:1]];
                else
                    [node runAction:[SCNAction rotateByAngle:-moveDiscreet aroundAxis:SCNVector3Make(0, 1, 0) duration:0.1]];
                break;
                
            case 2:
                if ( value < 0 )
                    [node runAction:[SCNAction rotateByAngle:moveDiscreet aroundAxis:SCNVector3Make(0, 0, 1) duration:0.1]];//:0.0 y:1 z:0 duration:1]];
                else
                    [node runAction:[SCNAction rotateByAngle:-moveDiscreet aroundAxis:SCNVector3Make(0, 0, 1) duration:0.1]];
                break;
                
            default:
                break;
        }
        

    }
    
    
}

-(void)onPositionMoved:(NSNotification*)data {
    NSDictionary *dictionary = data.object;
    int axe = [dictionary[@"axe"] intValue];
    float value = [dictionary[@"value"] floatValue];
    SCNView *scnView = (SCNView *)self.view;
    SCNNode *node = [scnView.scene.rootNode childNodeWithName:@"Camera" recursively:YES];
    
    const float moveDiscreet = 0.3;
    
    if ( node != nil ) {
        SCNVector3 currentPosition = node.position;
        
        switch ( axe ) {
            case 0:
                if ( value >= 0)
                    currentPosition.x += -moveDiscreet;
                else
                    currentPosition.x += moveDiscreet;
                break;
                
            case 1:
                if ( value >= 0)
                    currentPosition.z += moveDiscreet;
                else
                    currentPosition.z += -moveDiscreet;
                break;
                
            case 2:
                if ( value >= 0)
                    currentPosition.y += -moveDiscreet;
                else
                    currentPosition.y += moveDiscreet;
                break;
                
            default:
                break;
        }
        
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:0.5];
        
        // on completion - unhighlight
        [SCNTransaction setCompletionBlock:^{
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.5];
            
            node.position = currentPosition;
            
            [SCNTransaction commit];
        }];
        
        
        
        [SCNTransaction commit];
    }
    
    
}



@end
