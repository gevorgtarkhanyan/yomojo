//
//  AppManager.m
//  Yomojo
//
//  Created by Suren Poghosyan on 2/12/20.
//  Copyright © 2020 AcquireBPO. All rights reserved.
//

#import "AppManager.h"

@implementation AppManager

+ (AppManager *)sharedManager {
    static AppManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[AppManager alloc] init];
    });
    
    return sharedManager;
}

-(void)removeSavedLoginAndPasswordIfNeeded {
    if (self.shouldRemoveSavedLoginAndPassword == YES) {
        NSUserDefaults *userLogin = [NSUserDefaults standardUserDefaults];
        [userLogin removeObjectForKey:@"Username"];
        [userLogin removeObjectForKey:@"Password"];
        
        [userLogin removeObjectForKey:@"quickGlanceUsername"];
        [userLogin removeObjectForKey:@"quickGlancePassword"];
        [userLogin removeObjectForKey:@"quickGlanceIndex"];
        [userLogin removeObjectForKey:@"quickGlanceEnable"];
        [userLogin removeObjectForKey:@"quickGlancePhoneArray"];
        [userLogin removeObjectForKey:@"quickGlanceURLData"];
        [userLogin removeObjectForKey:@"quickGlanceStrID"];
        
        [userLogin removeObjectForKey:@"biometricLogin"];
    }
}

@end
