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

#import "AGOAuth2AuthzSession.h"

@implementation AGOAuth2AuthzSession
@synthesize accessToken = _accessToken;
@synthesize accessTokenExpirationDate = _accessTokenExpirationDate;
@synthesize refreshToken = _refreshToken;
@synthesize accountId = _accountId;

- (BOOL)tokenIsNotExpired {
    return [_accessTokenExpirationDate timeIntervalSinceDate:[NSDate date]] > 0 ;
}

- (void) saveAccessToken:(NSString*)accessToken refreshToken:(NSString*) refreshToken expiration:(NSString*) expiration {
    self.accessToken = accessToken;
    self.refreshToken = refreshToken;
    NSDate *now = [NSDate date];
    self.accessTokenExpirationDate = [now dateByAddingTimeInterval:[expiration integerValue]];
}

/**
 * Serialize into NSDictionary instance an AGOAuth2AuthzSession object.
 */
-(NSDictionary*)toDictionary {
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    if (_accountId) {
        dict[@"id"] = _accountId;
    }
    if (_accessToken) {
        dict[@"accessToken"] = _accessToken;
    }
    if (_accessTokenExpirationDate) {
        dict[@"accessTokenExpirationDate"] = _accessTokenExpirationDate;
    }
    if (_refreshToken) {
        dict[@"refreshToken"] = _refreshToken;
    }
    
    return dict;
}
/**
 * Deerialize into AGOAuth2AuthzSession object from a NSDictionary.
 */
-(instancetype)init:(NSDictionary*)dictionary {
    self = [self init];
    if (self) {
        _accessToken = dictionary[@"accessToken"];
        _accessTokenExpirationDate = dictionary[@"accessTokenExpirationDate"];
        _refreshToken = dictionary[@"refreshToken"];
        _accountId = dictionary[@"id"];
    }
    return self;
}

@end
