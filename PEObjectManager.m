//
//  PEObjectManager.m
//  pecolly
//
//  Created by 利辺羅 on 2014/05/06.
//  Copyright (c) 2014年 CyberAgent Inc. All rights reserved.
//

#import "PEObjectManager.h"
#import <RestKit/CoreData.h>
#import <RestKit/RestKit.h>

@implementation PEObjectManager

+ (instancetype)sharedManager
{
    // Initialization
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        // Initialize manager
        RKObjectManager * objectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://restkit.org"]];
        
        // Initialize Core Data
        // NOTE: Due to an iOS 5 bug, the managed object model returned is immutable.
        NSURL *modelURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"MainModel"
                                                                                 ofType:@"momd"]];
        NSManagedObjectModel * managedObjectModel = [[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL] mutableCopy];
        RKManagedObjectStore * managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
        objectManager.managedObjectStore = managedObjectStore;
        
        // Persistency
        NSError * error;
        NSString * persistentPath = [UIApplication.sharedApplication.documentsDirectory.path stringByAppendingPathComponent:@"Cache.sqlite"];
        [managedObjectStore addSQLitePersistentStoreAtPath:persistentPath
                                    fromSeedDatabaseAtPath:nil
                                         withConfiguration:nil
                                                   options:nil
                                                     error:&error];

        // Mappings
        
    });
    
    return super.sharedManager;
}

@end

