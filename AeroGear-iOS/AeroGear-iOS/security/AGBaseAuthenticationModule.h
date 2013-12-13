//
// Created by Corinne Krych on 12/13/13.
// Copyright (c) 2013 JBoss. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AGBaseAuthenticationModule <NSObject>
/**
 * Returns the type of the underlying 'auth module implementation'
 */
@property (nonatomic, readonly) NSString* type;

/**
 * Returns the baseURL string of the underlying 'auth module implementation'
 */
@property (nonatomic, readonly) NSString* baseURL;

@end