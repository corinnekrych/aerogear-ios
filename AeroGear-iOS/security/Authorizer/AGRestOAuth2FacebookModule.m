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
#import "AGRestOAuth2FacebookModule.h"

@implementation AGRestOAuth2FacebookModule

-(instancetype) initWithConfig:(id<AGAuthzConfig>) authzConfig {
    self = [super initWithConfig: authzConfig];
    if (self) {
        _restClient.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    
    return self;
}

-(void)exchangeAuthorizationCodeForAccessToken:(NSString*)code
                                       success:(void (^)(id object))success
                                       failure:(void (^)(NSError *error))failure {
    NSMutableDictionary* paramDict = [[NSMutableDictionary alloc] initWithDictionary:@{@"code":code, @"client_id":self.clientId, @"redirect_uri": [NSString stringWithFormat:@"%@", self.redirectURL ]}];
    if (self.clientSecret) {
        paramDict[@"client_secret"] = self.clientSecret;
    }
    
    
    [_restClient POST:self.accessTokenEndpoint parameters:paramDict success:^(NSURLSessionDataTask *task, id responseObject) {
        
        
        NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        NSMutableCharacterSet* charSet = [[NSMutableCharacterSet alloc] init];
        [charSet addCharactersInString:@"&="];
        __block NSString* accessToken;
        __block NSString* expiredIn;
        NSArray* array = [responseString componentsSeparatedByCharactersInSet:charSet];
        
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if([obj isEqualToString:@"access_token"]) {
                accessToken = array[idx+1];
            }
            if([obj isEqualToString:@"expires"]) {
                expiredIn = array[idx+1];
            }
        }];
        
        [self.sessionStorage saveAccessToken:accessToken refreshToken:nil expiration:expiredIn];
        
        if (success) {
            success(accessToken);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

-(void) revokeAccessSuccess:(void (^)(id object))success
                    failure:(void (^)(NSError *error))failure {
    // return if not yet initialized
    if (!self.sessionStorage.accessToken)
        return;
    NSDictionary* paramDict = @{@"access_token":self.sessionStorage.accessToken};
    [_restClient DELETE:self.revokeTokenEndpoint parameters:paramDict success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [self.sessionStorage saveAccessToken:nil refreshToken:nil expiration:nil];
        
        if (success) {
            success(nil);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}
@end
