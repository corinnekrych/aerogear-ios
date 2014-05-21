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
        NSLog(@">>>%@", responseString);
        
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
@end
