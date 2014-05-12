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

#import <UIKit/UIKit.h>
#import "AGRestOAuth2Module.h"
#import "AGAuthzConfiguration.h"
#import "AGHttpClient.h"

NSString * const AGAppLaunchedWithURLNotification = @"AGAppLaunchedWithURLNotification";

@implementation AGRestOAuth2Module {
    // ivars
    AGHttpClient* _restClient;
    id _applicationLaunchNotificationObserver;
}

// =====================================================
// ======== public API (AGAuthzModule) ========
// =====================================================
@synthesize type = _type;
@synthesize baseURL = _baseURL;
@synthesize authzEndpoint = _authzEndpoint;
@synthesize accessTokenEndpoint = _accessTokenEndpoint;
@synthesize redirectURL = _redirectURL;
@synthesize clientId = _clientId;
@synthesize clientSecret = _clientSecret;
@synthesize scopes = _scopes;

// ==============================================================
// ======== internal API (AGAuthzModuleAdapter) ========
// ==============================================================
@synthesize session = _session;

// ==============================================
// ======== 'factory' and 'init' section ========
// ==============================================

+(instancetype) moduleWithConfig:(id<AGAuthzConfig>) authzConfig {
    return [[[self class] alloc] initWithConfig:authzConfig];
}

-(instancetype) init {
    self = [super init];
    if (self) {
        _session = [[AGOAuth2AuthzSession alloc] init];
    }
    return self;
}

-(instancetype) initWithConfig:(id<AGAuthzConfig>) authzConfig {
    self = [super init];
    if (self) {
        // set all the things:
        AGAuthzConfiguration* config = (AGAuthzConfiguration*) authzConfig;
        _baseURL = config.baseURL.absoluteString;
        _type = config.type;
        _authzEndpoint = config.authzEndpoint;
        _accessTokenEndpoint = config.accessTokenEndpoint;
        _redirectURL = config.redirectURL;
        _clientId = config.clientId;
        _clientSecret = config.clientSecret;
        _scopes = config.scopes;

        _restClient = [AGHttpClient clientFor:config.baseURL timeout:config.timeout];

        // default to url serialization
        _restClient.requestSerializer = [AFHTTPRequestSerializer serializer];
        _session = [[AGOAuth2AuthzSession alloc] init];
    }

    return self;
}

-(void)dealloc {
    _restClient = nil;
}

// =====================================================
// ======== public API (AGAuthenticationModule) ========
// =====================================================
-(void) requestAccessSuccess:(void (^)(id object))success
              failure:(void (^)(NSError *error))failure {
    if (self.session.accessTokens != nil && [self.session tokenIsNotExpired]) {
        if (success) {
            success(self.session.accessTokens);
        }
    } else if (self.session.refreshTokens != nil) { // need to refresh token
        [self refreshAccessTokenSuccess:success failure:failure];
    } else {
        [self requestAuthorizationCodeSucess:success failure:failure];
    }
}


// ==============================================================
// ======== internal API (AGAuthenticationModuleAdapter) ========
// ==============================================================
-(void)requestAuthorizationCodeSucess:(void (^)(id object))success
                              failure:(void (^)(NSError *error))failure {
    // Form the URL string.
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@?scope=%@&redirect_uri=%@&client_id=%@&response_type=code",
                                       self.baseURL,
                                       self.authzEndpoint,
                                       [self scope],
                                       [self urlEncodeString:_redirectURL],
                                       _clientId]];
    
    // register with the notification system in order to be notified when the 'authorisation' process completes in the
    // external browser, and the oauth code is available so that we can then proceed to request the 'access_token'
    // from the server.
    _applicationLaunchNotificationObserver = [[NSNotificationCenter defaultCenter] addObserverForName:AGAppLaunchedWithURLNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
        NSURL *url = [[notification userInfo] valueForKey:UIApplicationLaunchOptionsURLKey];
        NSString* code = [[self parametersFromQueryString:[url query]] valueForKey:@"code"];
        [self exchangeAuthorizationCodeForAccessToken:code success:success failure:failure];
    }];
    
    [[UIApplication sharedApplication] openURL:url];
}

-(void)exchangeAuthorizationCodeForAccessToken:(NSString*)code
                                       success:(void (^)(id object))success
                                       failure:(void (^)(NSError *error))failure {
    NSMutableDictionary* paramDict = [[NSMutableDictionary alloc] initWithDictionary:@{@"code":code, @"client_id":_clientId, @"redirect_uri": _redirectURL, @"grant_type":@"authorization_code"}];
    if (_clientSecret) {
        paramDict[@"client_secret"] = _clientSecret;
    }

    [_restClient POST:self.accessTokenEndpoint parameters:paramDict success:^(NSURLSessionDataTask *task, id responseObject) {

        [self.session saveAccessToken:responseObject[@"access_token"] refreshToken:responseObject[@"refresh_token"] expiration:responseObject[@"expires_in"]];
        
        if (success) {
            success(responseObject[@"access_token"]);
        }

    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

-(void)refreshAccessTokenSuccess:(void (^)(id object))success
                         failure:(void (^)(NSError *error))failure {
    NSMutableDictionary* paramDict = [[NSMutableDictionary alloc] initWithDictionary:@{@"refresh_token":self.session.refreshTokens, @"client_id":_clientId, @"grant_type":@"refresh_token"}];
    if (_clientSecret) {
        paramDict[@"client_secret"] = _clientSecret;
    }
    
    [_restClient POST:self.accessTokenEndpoint parameters:paramDict success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [self.session saveAccessToken:responseObject[@"access_token"] refreshToken:self.session.refreshTokens expiration:responseObject[@"expires_in"]];
        
        if (success) {
            success(responseObject[@"access_token"]);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

-(NSDictionary*) getAuthorizationFields {
    return @{@"Authorization":[NSString stringWithFormat:@"Bearer %@", self.session.accessTokens]};
}

-(NSDictionary *) parametersFromQueryString:(NSString *)queryString {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (queryString) {
        NSScanner *parameterScanner = [[NSScanner alloc] initWithString:queryString];
        NSString *name = nil;
        NSString *value = nil;

        while (![parameterScanner isAtEnd]) {
            name = nil;
            [parameterScanner scanUpToString:@"=" intoString:&name];
            [parameterScanner scanString:@"=" intoString:NULL];

            value = nil;
            [parameterScanner scanUpToString:@"&" intoString:&value];
            [parameterScanner scanString:@"&" intoString:NULL];

            if (name && value) {
                parameters[[name stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] = [value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            }
        }
    }

    return parameters;
}

- (NSString*) scope {
    // Create a string to concatenate all scopes existing in the _scopes array.
    NSString *scope = @"";
    for (int i=0; i<[_scopes count]; i++) {
        scope = [scope stringByAppendingString:[self urlEncodeString:_scopes[i]]];

        // If the current scope is other than the last one, then add the "+" sign to the string to separate the scopes.
        if (i < [_scopes count] - 1) {
            scope = [scope stringByAppendingString:@"+"];
        }
    }
    return scope;
}

-(NSString *)urlEncodeString:(NSString *)stringToURLEncode{
    CFStringRef encodedURL = CFURLCreateStringByAddingPercentEscapes(NULL,
            (__bridge CFStringRef) stringToURLEncode,
            NULL,
            (__bridge CFStringRef)@"!@#$%&*'();:=+,/?[]",
            kCFStringEncodingUTF8);
    return (NSString *)CFBridgingRelease(encodedURL);
}


- (BOOL)isAuthorized {
    return self.session.accessTokens != nil && [self.session tokenIsNotExpired];
}

- (void)deauthorize {
    //TODO AGIOS-146
    //_accessTokens = nil;
}

@end
