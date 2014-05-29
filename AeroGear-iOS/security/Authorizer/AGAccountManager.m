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

-(instancetype)init:(NSString*)type {
    self = [super init];
    if(self) {
        _oauthAccountStorage = [[AGDataManager manager] store:^(id<AGStoreConfig> config) {
            config.name = @"AccountManager";
            config.type = type;
        }];
        
        _authz = [AGAuthorizer authorizer];
    }
    
    return self;
}

+(instancetype) manager {
    return [[AGAccountManager alloc] init:@"MEMORY"];
}
+(instancetype) manager:(NSString*)type {
    return [[AGAccountManager alloc] init:type];
}

-(id<AGOAuth2AuthzModuleAdapter>) authz:(void (^)(id<AGAuthzConfig>))config {
    
    // Initialize authzModule with config
    id<AGOAuth2AuthzModuleAdapter> adapter = (id<AGOAuth2AuthzModuleAdapter>)[_authz authz:config];
    
    // check if a stored config exists for this service
    NSString *serviceIdentifier = [adapter.baseURL host];
    AGOAuth2AuthzSession* account = [self read:serviceIdentifier];
    
    if (account == nil) { // nope
        account = [[AGOAuth2AuthzSession alloc] init];
    } else { // found one
        // initialize adapter
        adapter.sessionStorage.accessToken = account.accessToken;
        adapter.sessionStorage.accessTokenExpirationDate = account.accessTokenExpirationDate;
        adapter.sessionStorage.refreshToken = account.refreshToken;
    }
    
    adapter.sessionStorage.serviceIdentifier = serviceIdentifier;
    
    // register to be notified when token get refreshed to store them in AccountMgr
    [adapter.sessionStorage addObserver:self forKeyPath:NSStringFromSelector(@selector(accessToken))
                                options:NSKeyValueObservingOptionNew context:NULL];
    [adapter.sessionStorage addObserver:self forKeyPath:NSStringFromSelector(@selector(accessTokenExpirationDate))
                                options:NSKeyValueObservingOptionNew context:NULL];
    [adapter.sessionStorage addObserver:self forKeyPath:NSStringFromSelector(@selector(refreshToken))
                                options:NSKeyValueObservingOptionNew context:NULL];

    return adapter;
}

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
