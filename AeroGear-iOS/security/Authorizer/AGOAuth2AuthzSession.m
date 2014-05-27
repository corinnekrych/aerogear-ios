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
@synthesize accountId = _accountId;
@synthesize clientId = _clientId;
@synthesize type = _type;
@synthesize accessToken = _accessToken;
@synthesize accessTokenExpirationDate = _accessTokenExpirationDate;
@synthesize refreshToken = _refreshToken;

- (BOOL)tokenIsNotExpired {
    return [_accessTokenExpirationDate timeIntervalSinceDate:[NSDate date]] > 0 ;
}

- (void) saveAccessToken:(NSString*)accessToken refreshToken:(NSString*) refreshToken expiration:(NSString*) expiration {
    self.accessToken = accessToken;
    self.refreshToken = refreshToken;
    NSDate *now = [NSDate date];
    self.accessTokenExpirationDate = [now dateByAddingTimeInterval:[expiration integerValue]];
}
@end
