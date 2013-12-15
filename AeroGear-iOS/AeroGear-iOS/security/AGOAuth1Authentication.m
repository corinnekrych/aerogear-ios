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

#import "AGOAuth1Authentication.h"
#import "AFOAuth1Client.h"
#import "AGOAuth1Config.h"

@implementation AGOAuth1Authentication {
    AFOAuth1Client* _httpClient;

}
// =====================================================
// ======== public API (AGOAuth1AuthenticationModule) ==
// =====================================================
@synthesize type = _type;
@synthesize baseURL = _baseURL;
@synthesize key = _key;
@synthesize secret = _secret;
@synthesize requestTokenEndpoint = _requestTokenEndpoint;
@synthesize callbackAuthEndpoint = _callbackAuthEndpoint;
@synthesize authEndpoint = _authEndpoint;
@synthesize accessMethod = _accessMethod;
@synthesize accessTokenEndpoint = _accessTokenEndpoint;


-(id) initWithConfig:(id<AGConfig>) authConfig {
    if(self = [super init]) {
        id<AGOAuth1Config> conf = (id<AGOAuth1Config>)authConfig;
        _type = conf.type;
        _baseURL = conf.baseURL.absoluteString;
        _key = conf.key;
        _secret = conf.secret;
        _requestTokenEndpoint = conf.requestTokenEndpoint;
        _callbackAuthEndpoint = conf.callbackAuthEndpoint;
        _authEndpoint = conf.authEndpoint;
        _accessTokenEndpoint = conf.accessTokenEndpoint;
        _accessMethod = @"POST";
        
        _httpClient = [[AFOAuth1Client alloc] initWithBaseURL:[[NSURL alloc] initWithString:_baseURL] key:_key secret:_secret];
    }
    return self;
}

+(id) moduleWithConfig:(id<AGConfig>) authConfig {
    return [[self alloc] initWithConfig:authConfig];
}

-(void)dealloc {
    _httpClient = nil;
}


// =====================================================
// ======== public API (AGAuthenticationModule) ========
// =====================================================
-(void) authorize:(NSDictionary*) userData
          success:(void (^)(id token, id object))success
          failure:(void (^)(NSError *error))failure {
    [_httpClient authorizeUsingOAuthWithRequestTokenPath:_requestTokenEndpoint
                                  userAuthorizationPath:_authEndpoint
                                            callbackURL:[NSURL URLWithString:_callbackAuthEndpoint]
                                        accessTokenPath:_accessTokenEndpoint
                                           accessMethod:_accessMethod
                                                  scope:nil
                                                success:success
                                                failure:failure];

}
//-(void) enroll:(NSDictionary*) userData
//       success:(void (^)(id object))success
//       failure:(void (^)(NSError *error))failure {
//    
//    
//    [_restClient postPath:_enrollEndpoint parameters:userData success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//        // stash the auth token...:
//        [self readAndStashToken:operation];
//        
//        if (success) {
//            //TODO: NSLog(@"Invoking successblock....");
//            success(responseObject);
//        }
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        
//        if (failure) {
//            //TODO: NSLog(@"Invoking failure block....");
//            failure(error);
//        }
//    }];
//    
//}

@end