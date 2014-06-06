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

@interface AGOAuth2AuthzSession : NSObject

/**
 * The account id. 
 */
@property (nonatomic, strong) NSString* accountId;

/**
 * The access token which expires.
 */
@property (nonatomic, strong) NSString* accessToken;

/**
 * The access token's expiration date.
 */
@property (nonatomic, strong) NSDate* accessTokenExpirationDate;

/**
 * The refresh tokens. This toke does not expire and should be used to renew access token when expired.
 */
@property (nonatomic, strong) NSString* refreshToken;

/**
 * Check validity of accessToken. return true if still valid, false when expired.
 */
- (BOOL) tokenIsNotExpired;

/**
 * Save in memory tokens information. Saving tokens allow you to refresh accesstoken transparently for the user without prompting
 * for grant access.
 */
- (void) saveAccessToken:(NSString*)accessToken refreshToken:(NSString*) refreshToken expiration:(NSString*) expiration;

/**
 * Serialize into NSDictionary instance an AGOAuth2AuthzSession object.
 */
-(NSDictionary*)toDictionary;

/**
 * Deerialize into AGOAuth2AuthzSession object from a NSDictionary.
 */
-(instancetype)init:(NSDictionary*)dictionary;

@end
