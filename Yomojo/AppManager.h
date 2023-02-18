//
//  AppManager.h
//  Yomojo
//
//  Created by Suren Poghosyan on 2/12/20.
//  Copyright © 2020 AcquireBPO. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppManager : NSObject

+ (AppManager*)sharedManager;

@property (nonatomic, assign) BOOL shouldRemoveSavedLoginAndPassword;

-(void)removeSavedLoginAndPasswordIfNeeded;
@end

NS_ASSUME_NONNULL_END
