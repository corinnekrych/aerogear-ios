/*
 * JBoss, Home of Professional Open Source.
 * Copyright Red Hat, Inc., and individual contributors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <Foundation/Foundation.h>
#import "AGStore.h"
#import "AGAuthzModule.h"
#import "AGAuthzConfig.h"

/**
 * AGAccountManager allows you to store your tokens under an account. When creating AGAccountManager
 * you need to specify what kind of storage you want. To have the benefit of AGAccountManager, a permanent storage
 * is preferred. You app will ask for grant permission only when lauched the first time. But be aware, of sensitive 
 * nature of access and refresh tokens. Choose an encrypted storage for a secured app.
 */
@interface AGAccountManager : NSObject

/**
 * A factory method to instantiate the AGAccountManager object.
 * Note: the AccountManager will use an in-memory store for storing accounts.
 *
 * @return the AGAccountManager object.
 */
+(instancetype) manager;

/**
 * Initialization of AGAccountManager with a persistence type: PLIST, MEMORY, SQLITE, and its encrypted variants.
 * Note it is recommended to store tokens in ecrypted storage.
 *
 * @param store the permanent store that this AccountManager will use for storing accounts.
 *
 * @return the AGAccountManager object.
 */
+(instancetype) manager:(id<AGStore>)store;

/**
 * Adds a new AGAuthzModule object, based on the given configuration object.
 *
 * @param config A block object which passes in an implementation of the AGAuthzConfig protocol.
 * the object is used to configure the AGAuthzModule object.
 *
 * @return the newly created AGAuthzModule object.
 */
-(id<AGAuthzModule>) authz:(void (^)(id<AGAuthzConfig>)) config;

@end
