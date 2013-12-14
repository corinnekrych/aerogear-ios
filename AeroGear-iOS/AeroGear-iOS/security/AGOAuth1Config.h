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
#import "AGConfig.h"

/**
 * Represents the public API to configure AGOAuth1AuthenticationModule, AGOAuth2AuthenticationModule objects.
 */
@protocol AGOAuth1Config <AGConfig>

/**
 * Applies the baseURL to the configuration.
 */
@property (strong, nonatomic) NSURL* baseURL;

/**
 * TODO key to identify app id.
 */
@property (strong, nonatomic) NSString* key;

/**
 * TODO Secret.
 */
@property (strong, nonatomic) NSString* secret;

/**
 * Applies the "request token endpoint" to the configuration. This URL is used to start the OAuth dance, requesting
 * access tokens.
 */
@property (copy, nonatomic) NSString* requestTokenEndpoint;

/**
 * Applies the "auth endpoint" to the configuration. This URL is used for the user to
 * login/grant access third party app.
 */
@property (copy, nonatomic) NSString* authEndpoint;

/**
 * Applies the "callback auth endpoint" to the configuration. This URL is used after
 * the user has been successfully authorized.
 */
@property (copy, nonatomic) NSString* callbackAuthEndpoint;

/**
 * Applies the exchange your request token with "access token endpoint" to the configuration.
 */
@property (copy, nonatomic) NSString* accessTokenEndpoint;

/**
 * The timeout interval for a request to complete.
 */
@property (assign, nonatomic) NSTimeInterval timeout;


@end
