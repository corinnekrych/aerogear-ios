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
#import "AGAuthzConfig.h"
#import "AGOAuth2AuthzModuleAdapter.h"

/**
 An internal AGAuthorization module implementation that uses REST as the auth transport.

 *IMPORTANT:* Users are not required to instantiate this class directly, instead an instance of this class is returned
 automatically when an Authorizer with default configuration is constructed or with the _type_ config option set to
 _"REST"_. See AGAuthorizer and AGAuthzModule class documentation for more information.

 */
@interface AGRestOAuth2Module : NSObject <AGOAuth2AuthzModuleAdapter>

-(instancetype) initWithConfig:(id<AGAuthzConfig>) authzConfig;
+(instancetype) moduleWithConfig:(id<AGAuthzConfig>) authzConfig;


@end
