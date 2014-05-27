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

#import "AGOAuth2AuthzAccount.h"

@implementation AGOAuth2AuthzAccount {
    NSArray* _oauthAccounts;
}

-(void)addAccount:(AGOAuth2AuthzSession*)account {
}

-(BOOL)hasAccount:(NSString*)accountId {
    return NO;
}

-(AGOAuth2AuthzSession*)account:(NSString*)accountId {
    return nil;//sessionStore.read(accountId);
}

-(NSArray*)accounts {
    return nil;
//    return new ArrayList<String>(Collections2.<OAuth2AuthzSession, String> transform(sessionStore.readAll(), new Function<OAuth2AuthzSession, String>() {
//        
//        @Override
//        public String apply(OAuth2AuthzSession input) {
//            return input.getAccountId();
//        }
//    }));
}
@end
