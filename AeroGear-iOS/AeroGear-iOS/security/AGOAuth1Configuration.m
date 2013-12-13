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

#import "AGOAuth1Configuration.h"

@implementation AGOAuth1Configuration

// private getters...
@synthesize baseURL = _baseURL;
@synthesize requestTokenEndpoint = _requestTokenEndpoint;
@synthesize authEndpoint = _authEndpoint;
@synthesize callbackAuthEndpoint = _callbackAuthEndpoint;
@synthesize accessTokenEndpoint = _accessTokenEndpoint;
@synthesize timeout = _timeout;

@synthesize name = _name;
@synthesize type = _type;

- (id)init {
    self = [super init];
    if (self) {
        // default values:
        _type = @"AG_OAUTH1";
        _requestTokenEndpoint = @"oauth/request_token";
        _authEndpoint = @"oauth/authorize";
        _callbackAuthEndpoint = @"callback://auth";
        _accessTokenEndpoint = @"oauth/access_token";
        _timeout = 60; // the default timeout interval of NSMutableURLRequest (60 secs)
    }

    return self;
}

@end