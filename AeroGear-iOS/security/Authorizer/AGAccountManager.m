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

@implementation AGAccountManager {
    id<AGStore> _oauthAccountStorage;
}

-(instancetype)init {
    self = [super init];
    if(self) {
        _oauthAccountStorage = [[AGDataManager manager] store:^(id<AGStoreConfig> config) {
            config.name = @"AccountManager";
        }];
    }
    return self;
}


+(instancetype) manager {
    return [[[self class] alloc] init];
}

-(id<AGOAuth2AuthzModuleAdapter>) authz:(void (^)(id<AGAuthzConfig> conf))config account:(AGOAuth2AuthzSession*)account {
    AGAuthorizer* authz = [AGAuthorizer authorizer];
    
    id<AGOAuth2AuthzModuleAdapter> adapter = (id<AGOAuth2AuthzModuleAdapter>)[authz authz:config];
    
    adapter.sessionStorage.accountId = account.accountId;
    adapter.sessionStorage.clientId = account.clientId;
    adapter.sessionStorage.accessToken = account.accessToken;
    adapter.sessionStorage.accessTokenExpirationDate = account.accessTokenExpirationDate;
    adapter.sessionStorage.refreshToken = account.refreshToken;
    adapter.sessionStorage.type = [adapter class];
    [adapter.sessionStorage addObserver:self forKeyPath:@"accessToken" options:NSKeyValueObservingOptionNew context:nil];

    [self addAccount:account error:nil]; //TODO deal with error case
    return adapter;
}

-(id<AGOAuth2AuthzModuleAdapter>) authz:(void (^)(id<AGAuthzConfig> conf))config accountId:(NSString*)accountId {
    return [self authz:config account:[_oauthAccountStorage read:accountId]];
}

#pragma mark - implement KVO callback
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"accessToken"]){
        NSString* oldValue = [change objectForKey:NSKeyValueChangeOldKey];
        NSString* newValue = [change objectForKey:NSKeyValueChangeNewKey];
        
    }
}

#pragma mark - implement public interface
-(void)addAccount:(AGOAuth2AuthzSession*)account error:(NSError**) error {
    [_oauthAccountStorage save:account error:error];
        
}

-(BOOL)hasAccount:(NSString*)searchAccountId {
    if ([_oauthAccountStorage read:searchAccountId] == nil)
        return NO;
    return YES;
}

-(AGOAuth2AuthzSession*)account:(NSString*)accountId {
    return [_oauthAccountStorage read:accountId];
}

-(NSArray*)accounts {
    return [_oauthAccountStorage readAll];
}
@end
