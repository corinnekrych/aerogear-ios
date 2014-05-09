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
 *  Id of the app, also used as id of the session.
 */
@property (nonatomic, strong) NSString* clientId;

/**
 *  The authorization code. this code will need to be exchange to obtain an access token.
 */
@property (nonatomic, strong) NSString* authorizationCode;

/**
 *  The access token which expires.
 */
@property (nonatomic, strong) NSString* accessTokens;

/**
 *  The access token's expiration date.
 */
@property (nonatomic, strong) NSDate* accessTokensExpirationDate;

/**
 *  The refresh tokens. Does not expire.
 */
@property (nonatomic, strong) NSString* refreshTokens;

- (BOOL) tokenIsNotExpired;
- (void) saveAccessToken:(NSString*)accessToken refreshToken:(NSString*) refreshToken expiration:(NSString*) expiration;
@end
