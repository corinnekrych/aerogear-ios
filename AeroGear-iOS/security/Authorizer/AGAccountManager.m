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

#import "AGAccountManager.h"
#import "AGStore.h"
#import "AGAuthorizer.h"
#import "AGDataManager.h"
#import "AGOAuth2AuthzModuleAdapter.h"

@implementation AGAccountManager {
    id<AGStore> _oauthAccountStorage;
    AGAuthorizer *_authz;
}

-(instancetype)init:(id<AGStore>)store {
    self = [super init];
    if(self) {
        _oauthAccountStorage = store;
        _authz = [AGAuthorizer authorizer];
    }
    
    return self;
}

+(instancetype) manager {
    id<AGStore> memStore = [[AGDataManager manager] store:^(id<AGStoreConfig> config) {
        config.name = @"AccountManager";
        config.type = @"MEMORY";
    }];
    
    return [[AGAccountManager alloc] init:memStore];
}

+(instancetype) manager:(id<AGStore>)store {
    return [[AGAccountManager alloc] init:store];
}

-(id<AGOAuth2AuthzModuleAdapter>) authz:(void (^)(id<AGAuthzConfig>))config {
    // initialize authzModule with config
    id<AGOAuth2AuthzModuleAdapter> adapter = (id<AGOAuth2AuthzModuleAdapter>)[_authz authz:config];
    
    // check if a stored config exists for this account
    NSString *accountId = adapter.accountId;
    if (accountId) {
        AGOAuth2AuthzSession *account = [self read:accountId];
    
        if (account) { // found one, replace with stored session
            adapter.sessionStorage = account;
        } else {
            // set the accountId, so it will be saved alongside with the other session params
            adapter.sessionStorage.accountId = accountId;
        }
        
        // register to be notified when token get refreshed to store them in AccountMgr
        [adapter.sessionStorage addObserver:self forKeyPath:NSStringFromSelector(@selector(accessToken))
                                    options:NSKeyValueObservingOptionNew context:NULL];
        [adapter.sessionStorage addObserver:self forKeyPath:NSStringFromSelector(@selector(accessTokenExpirationDate))
                                    options:NSKeyValueObservingOptionNew context:NULL];
        [adapter.sessionStorage addObserver:self forKeyPath:NSStringFromSelector(@selector(refreshToken))
                                    options:NSKeyValueObservingOptionNew context:NULL];
    }

    return adapter;
}

#pragma mark - Utility methods

-(AGOAuth2AuthzSession*)read:(NSString*)accountId {
    NSDictionary* dict = [_oauthAccountStorage read:accountId];
    if (dict) { // found
        return [[AGOAuth2AuthzSession alloc] init:dict];
    }
    
    return nil;
}

-(BOOL)save:(AGOAuth2AuthzSession*)account {
    return [_oauthAccountStorage save:[[account toDictionary] mutableCopy] error:nil];
}

#pragma mark - implement KVO callback
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    // update local store
    [self save:object];
}

@end
