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
#import "AGOAuth2AuthzSession.h"

@interface AGOAuth2AuthzAccount : NSObject

/**
 * Put a session into the store.
 *
 * @param account a new session
 */
-(void)addAccount:(AGOAuth2AuthzSession*)account;

/**
 * Will check if there is an account which has previously been granted an
 * authorization code and access code
 *
 * @param accountId
 * @return true if there is a session for the account.
 */
-(BOOL)hasAccount:(NSString*) accountId;

/**
 * Returns the OAuth2AuthzSession for accountId if any
 *
 * @param accountId the accountId to look up
 * @return an OAuth2AuthzSession or null
 */
-(AGOAuth2AuthzSession*)account:(NSString*) accountId;

/**
 * Fetches all OAuth2AuthzSessions in the system.
 *
 * @return all OAuth2AuthzSession's in the system
 */
-(NSArray*)accounts;
@end
