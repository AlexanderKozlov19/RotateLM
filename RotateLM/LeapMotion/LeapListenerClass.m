//
//  LeapListener.m
//  RotateLM
//
//  Created by Alexander Kozlov on 13.02.2018.
//  Copyright © 2018 eCozy. All rights reserved.
//

#import "LeapListenerClass.h"

@implementation LeapListenerClass {
    LeapController *controller;
    NSArray *fingerNames;
    NSArray *boneNames;
}

- (id)init
{
    self = [super init];
    static const NSString *const fingerNamesInit[] = {
        @"Thumb", @"Index finger", @"Middle finger",
        @"Ring finger", @"Pinky"
    };
    static const NSString *const boneNamesInit[] = {
        @"Metacarpal", @"Proximal phalanx",
        @"Intermediate phalanx", @"Distal phalanx"
    };
    fingerNames = [[NSArray alloc] initWithObjects:fingerNamesInit count:5];
    boneNames = [[NSArray alloc] initWithObjects:boneNamesInit count:4];
    return self;
}

- (void)run
{
    controller = [[LeapController alloc] init];
    [controller addListener:self];
    NSLog(@"running");
}


#pragma mark - SampleListener Callbacks

- (void)onInit:(NSNotification *)notification
{
    NSLog(@"Initialized");
}

- (void)onConnect:(NSNotification *)notification
{
    NSLog(@"Connected");
    LeapController *aController = (LeapController *)[notification object];
    [aController enableGesture:LEAP_GESTURE_TYPE_CIRCLE enable:YES];
    [aController enableGesture:LEAP_GESTURE_TYPE_KEY_TAP enable:YES];
    [aController enableGesture:LEAP_GESTURE_TYPE_SCREEN_TAP enable:YES];
    [aController enableGesture:LEAP_GESTURE_TYPE_SWIPE enable:YES];
}

- (void)onDisconnect:(NSNotification *)notification
{
    //Note: not dispatched when running in a debugger.
    NSLog(@"Disconnected");
}

- (void)onServiceConnect:(NSNotification *)notification
{
    NSLog(@"Service Connected");
}

- (void)onServiceDisconnect:(NSNotification *)notification
{
    NSLog(@"Service Disconnected");
}

- (void)onDeviceChange:(NSNotification *)notification
{
    NSLog(@"Device Changed");
}

- (void)onExit:(NSNotification *)notification
{
    NSLog(@"Exited");
}

- (void)onFrame:(NSNotification *)notification
{
    LeapController *aController = (LeapController *)[notification object];
    
    // Get the most recent frame and report some basic information
    LeapFrame *frame = [aController frame:0];
    LeapFrame *frame1 = [aController frame:1];
   // if ( [frame.hands count ] == 1 ) {
    
        BOOL rightHandFrame1 = NO;
        LeapVector *rightVector1 = nil;
        
        BOOL leftHandFrame1 = NO;
        LeapVector *leftVector1 = nil;
    
        NSMutableArray *array1 = [[ NSMutableArray alloc] init];
        NSMutableArray *array2 = [[ NSMutableArray alloc] init];
    
        LeapVector *velocity1 = nil;
        LeapVector *normal1 = nil;
    
        LeapVector *stabilized1 = nil;

        
        for (LeapHand *hand in frame.hands) {
            if ( hand.isRight && ([[hand.fingers extended] count]  == 5 ) ) {
                rightHandFrame1 = YES;
                
                rightVector1 = hand.palmPosition;
                
            }
            
            if ( hand.isLeft && ([[hand.fingers extended] count]  == 5 ) ) {
                leftHandFrame1 = YES;
                
                //leftVector1 = ;
                velocity1 = hand.palmVelocity;
                normal1 = hand.palmNormal;
                stabilized1 = hand.stabilizedPalmPosition;
                
                float pitch = [hand.direction pitch] * 180.0 / M_PI;
                float roll = [hand.palmNormal roll] * 180.0 / M_PI;
                float yaw = [hand.direction yaw] * 180.0 / M_PI;
                
                [array1 addObject:[NSNumber numberWithFloat:pitch]];
                [array1 addObject:[NSNumber numberWithFloat:roll]];
                [array1 addObject:[NSNumber numberWithFloat:yaw]];
                
                
                
                NSArray *velocityArray = [velocity1 toNSArray];
                int i = 0;
                float max = [velocityArray[0] floatValue];
                float absMax = fabs( [velocityArray[0] floatValue] );
                
                for ( int z = 1; z <= 2; z++ ) {
                    float temp = fabs( [velocityArray[z] floatValue]);
                    if ( temp > absMax ) {
                        absMax = temp;
                        i = z;
                        max = [velocityArray[z] floatValue];
                    }
                }
                    
                //NSLog(@"stabilized :%@", stabilized1);
                
               // NSLog( @"velocity %@", velocity1);
                //if ( absMax > 30.0 ) NSLog( @"velocity max %d %f", i, max );
                
            }
        }
        
        BOOL rightHandFrame2 = NO;
        LeapVector *rightVector2 = nil;
        
        BOOL leftHandFrame2 = NO;
        LeapVector *leftVector2 = nil;
        
        for (LeapHand *hand in frame1.hands) {
            if ( hand.isRight && ([[hand.fingers extended] count] == 5 ) ){
                rightHandFrame2 = YES;
                rightVector2 = hand.palmPosition;
                
            }
            
            if ( hand.isLeft && ([[hand.fingers extended] count] == 5 ) ){
                leftHandFrame2 = YES;
                leftVector2 = hand.palmPosition;
                
                float pitch = [hand.direction pitch] * 180.0 / M_PI;
                float roll = [hand.palmNormal roll] * 180.0 / M_PI;
                float yaw = [hand.direction yaw] * 180.0 / M_PI;
                
                [array2 addObject:[NSNumber numberWithFloat:pitch]];
                [array2 addObject:[NSNumber numberWithFloat:roll]];
                [array2 addObject:[NSNumber numberWithFloat:yaw]];
                
            }
        }
        
        
        
        if ( rightHandFrame1 && rightHandFrame2 ) {
            LeapVector *minus = [rightVector1 minus:rightVector2];
            //NSLog(@"%@", minus);
            NSArray *dif = [minus toNSArray];
            float signedMax = [dif[0] floatValue];
            float max = fabsf([dif[0] floatValue]);
            float temp;
            int maxAxe = 0;
            for ( int i = 1; i <=2; i++ ) {
                temp = fabsf([dif[i] floatValue]);
                if ( temp > max) {
                    max = temp;
                    maxAxe = i;
                    signedMax = [dif[i] floatValue];
                }
            }
        
            if ( max > 1.5 ) {
                NSLog(@"max: %f, axe: %d", signedMax, maxAxe );
                NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithFloat:signedMax], @"value", [NSNumber numberWithInt:maxAxe], @"axe", nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"onPositionMoved" object:dictionary];
            }
        }
        
        if ( leftHandFrame1 && leftHandFrame2 ) {
    
            int maxNum = -1;
            float absMaxValue;
            float maxValue;
            
            for ( int i = 0; i < 3; i++ ) {
                float temp1 = [array1[i] floatValue];
                float temp2 = [array2[i] floatValue];
                
                float dif = temp1 - temp2;
                while ( dif < -180.0 ) dif += 360.0;
                while ( dif > 180.0 ) dif -= 360.0;

                
                if ( maxNum == -1 ) {
                    maxValue = dif;
                    absMaxValue = fabs( dif );
                    maxNum = i;
                }
                else
                    if ( fabs( dif ) > absMaxValue ) {
                        maxNum = i;
                        absMaxValue = fabs( dif );
                        maxValue = dif;
                    }
                    
                
            }
            if ( absMaxValue > 0.5 ) {
                NSLog(@"axe: %d, dif %f", maxNum, maxValue);
                NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithFloat:maxValue], @"value", [NSNumber numberWithInt:maxNum], @"axe", nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"onRotation" object:dictionary];
            }
            //NSLog(@"%@", minus);
            /*NSArray *dif = [minus toNSArray];
            float signedMax = [dif[0] floatValue];
            float max = fabsf([dif[0] floatValue]);
            float temp;
            int maxAxe = 0;
            for ( int i = 1; i <=2; i++ ) {
                temp = fabsf([dif[i] floatValue]);
                if ( temp > max) {
                    max = temp;
                    maxAxe = i;
                    signedMax = [dif[i] floatValue];
                }
                
              
                
            }
            
            if ( max > 1.5 ) {
                NSLog(@"max: %f, axe: %d", signedMax, maxAxe );
                NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithFloat:signedMax], @"value", [NSNumber numberWithInt:maxAxe], @"axe", nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"onRotation" object:dictionary];
            }
             */
        }
  //  }
    
  /*  if ( [frame.hands count ] == 2 ) {
        
        BOOL allFinger1 = YES;
        LeapVector *rightVector1 = nil;
        
        
        for (LeapHand *hand in frame.hands) {
            allFinger1 = allFinger1 && ([[hand.fingers extended] count]  == 5 );
           
        }
        
        BOOL allFinger2 = YES;
        LeapVector *rightVector2 = nil;
        
        for (LeapHand *hand in frame1.hands) {
            if ( hand.isRight && ([[hand.fingers extended] count] == 5 ) ){
                rightHandFrame2 = YES;
                rightVector2 = hand.palmPosition;
                
            }
        }
        
        
        
        if ( rightHandFrame1 && rightHandFrame2 ) {
            LeapVector *minus = [rightVector1 minus:rightVector2];
            //NSLog(@"%@", minus);
            NSArray *dif = [minus toNSArray];
            float signedMax = [dif[0] floatValue];
            float max = fabsf([dif[0] floatValue]);
            float temp;
            int maxAxe = 0;
            for ( int i = 1; i <=2; i++ ) {
                temp = fabsf([dif[i] floatValue]);
                if ( temp > max) {
                    max = temp;
                    maxAxe = i;
                    signedMax = [dif[i] floatValue];
                }
            }
            
            if ( max > 1.5 ) {
                NSLog(@"max: %f, axe: %d", signedMax, maxAxe );
                NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithFloat:signedMax], @"value", [NSNumber numberWithInt:maxAxe], @"axe", nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"onPositionMoved" object:dictionary];
            }
        }
    }*/
    
    /*
    NSLog(@"Frame id: %lld, timestamp: %lld, hands: %ld, extended fingers: %ld, tools: %ld, gestures: %ld",
          [frame id], [frame timestamp], [[frame hands] count],
          [[[frame fingers] extended] count], [[frame tools] count], [[frame gestures:nil] count]);
    
    // Get hands
    /*
    for (LeapHand *hand in frame.hands) {
        NSString *handType = hand.isLeft ? @"Left hand" : @"Right hand";
        NSLog(@"  %@, id: %i, palm position: %@",
              handType, hand.id, hand.palmPosition);
        
        // Get the hand's normal vector and direction
        const LeapVector *normal = [hand palmNormal];
        const LeapVector *direction = [hand direction];
        
        // Calculate the hand's pitch, roll, and yaw angles
        NSLog(@"  pitch: %f degrees, roll: %f degrees, yaw: %f degrees\n",
              [direction pitch] * LEAP_RAD_TO_DEG,
              [normal roll] * LEAP_RAD_TO_DEG,
              [direction yaw] * LEAP_RAD_TO_DEG);
       
        // Get the Arm bone
        LeapArm *arm = hand.arm;
        NSLog(@"    Arm direction: %@, wrist position: %@, elbow position: %@", arm.direction, arm.wristPosition, arm.elbowPosition);
        
        for (LeapFinger *finger in hand.fingers) {
            NSLog(@"    %@, id: %i, length: %fmm, width: %fmm",
                  [fingerNames objectAtIndex:finger.type],
                  finger.id, finger.length, finger.width);
            
            for (int boneType = LEAP_BONE_TYPE_METACARPAL; boneType <= LEAP_BONE_TYPE_DISTAL; boneType++) {
                LeapBone *bone = [finger bone:boneType];
                NSLog(@"      %@ bone, start: %@, end: %@, direction: %@",
                      [boneNames objectAtIndex:boneType], bone.prevJoint, bone.nextJoint, bone.direction);
            }
        
        }
        
    }*/
    /*
    
    for (LeapTool *tool in frame.tools) {
        NSLog(@"  Tool, id: %i, position: %@, direction: %@",
              tool.id, tool.tipPosition, tool.direction);
    }
    */
    /*
    NSArray *gestures = [frame gestures:nil];
    for (int g = 0; g < [gestures count]; g++) {
        LeapGesture *gesture = [gestures objectAtIndex:g];
        switch (gesture.type) {
            case LEAP_GESTURE_TYPE_CIRCLE: {
                LeapCircleGesture *circleGesture = (LeapCircleGesture *)gesture;
                
                NSString *clockwiseness;
                if ([[[circleGesture pointable] direction] angleTo:[circleGesture normal]] <= LEAP_PI/2) {
                    clockwiseness = @"clockwise";
                } else {
                    clockwiseness = @"counterclockwise";
                }
                
                // Calculate the angle swept since the last frame
                float sweptAngle = 0;
                if(circleGesture.state != LEAP_GESTURE_STATE_START) {
                    LeapCircleGesture *previousUpdate = (LeapCircleGesture *)[[aController frame:1] gesture:gesture.id];
                    sweptAngle = (circleGesture.progress - previousUpdate.progress) * 2 * LEAP_PI;
                }
                
                NSLog(@"  Circle id: %d, %@, progress: %f, radius %f, angle: %f degrees %@",
                      circleGesture.id, [LeapListenerClass stringForState:gesture.state],
                      circleGesture.progress, circleGesture.radius,
                      sweptAngle * LEAP_RAD_TO_DEG, clockwiseness);
                break;
            }
            case LEAP_GESTURE_TYPE_SWIPE: {
                LeapSwipeGesture *swipeGesture = (LeapSwipeGesture *)gesture;
                NSLog(@"  Swipe id: %d, %@, position: %@, direction: %@, speed: %f",
                      swipeGesture.id, [LeapListenerClass stringForState:swipeGesture.state],
                      swipeGesture.position, swipeGesture.direction, swipeGesture.speed);
                break;
            }
                
            case LEAP_GESTURE_TYPE_KEY_TAP: {
                LeapKeyTapGesture *keyTapGesture = (LeapKeyTapGesture *)gesture;
                NSLog(@"  Key Tap id: %d, %@, position: %@, direction: %@",
                      keyTapGesture.id, [LeapListenerClass stringForState:keyTapGesture.state],
                      keyTapGesture.position, keyTapGesture.direction);
                break;
            }
            case LEAP_GESTURE_TYPE_SCREEN_TAP: {
                LeapScreenTapGesture *screenTapGesture = (LeapScreenTapGesture *)gesture;
                NSLog(@"  Screen Tap id: %d, %@, position: %@, direction: %@",
                      screenTapGesture.id, [LeapListenerClass stringForState:screenTapGesture.state],
                      screenTapGesture.position, screenTapGesture.direction);
                break;
            }
            default:
            //    NSLog(@"  Unknown gesture type");
                break;
        }
    }
    
   /* if (([[frame hands] count] > 0) || [[frame gestures:nil] count] > 0) {
        NSLog(@" ");
    }*/
}

- (void)onFocusGained:(NSNotification *)notification
{
    NSLog(@"Focus Gained");
}

- (void)onFocusLost:(NSNotification *)notification
{
    NSLog(@"Focus Lost");
}

+ (NSString *)stringForState:(LeapGestureState)state
{
    switch (state) {
        case LEAP_GESTURE_STATE_INVALID:
            return @"STATE_INVALID";
        case LEAP_GESTURE_STATE_START:
            return @"STATE_START";
        case LEAP_GESTURE_STATE_UPDATE:
            return @"STATE_UPDATED";
        case LEAP_GESTURE_STATE_STOP:
            return @"STATE_STOP";
        default:
            return @"STATE_INVALID";
    }
}

@end
