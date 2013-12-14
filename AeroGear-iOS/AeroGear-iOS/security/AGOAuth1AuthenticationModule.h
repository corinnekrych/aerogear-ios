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
#import "AGBaseAuthenticationModule.h"

@protocol AGOAuth1AuthenticationModule <AGBaseAuthenticationModule>

@property (nonatomic, readonly) NSString* key;
@property (nonatomic, readonly) NSString* secret;
@property (nonatomic, readonly) NSString* requestTokenEndpoint;
@property (nonatomic, readonly) NSString* authEndpoint;
@property (nonatomic, readonly) NSString* callbackAuthEndpoint;
@property (nonatomic, readonly) NSString* accessTokenEndpoint;

@property (nonatomic, readonly) NSString* accessMethod;

-(void) authorize:(NSDictionary*) userData
       success:(void (^)(id token, id object))success
       failure:(void (^)(NSError *error))failure;

@end
