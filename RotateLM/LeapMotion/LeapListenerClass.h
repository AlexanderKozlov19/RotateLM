//
//  LeapListener.h
//  RotateLM
//
//  Created by Alexander Kozlov on 13.02.2018.
//  Copyright © 2018 eCozy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LeapObjectiveC.h"

@interface LeapListenerClass: NSObject<LeapListener>

-(void)run;

@end
