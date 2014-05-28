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

-(id<AGOAuth2AuthzModuleAdapter>) authz:(void (^)(id<AGAuthzConfig> conf))config {
    
    AGAuthorizer* authz = [AGAuthorizer authorizer];
    // InitializeauthzModule with config
    id<AGOAuth2AuthzModuleAdapter> adapter = (id<AGOAuth2AuthzModuleAdapter>)[authz authz:config];
    
    // look into storage for existing account with accountId
    AGOAuth2AuthzSession* account = [_oauthAccountStorage read:adapter.accountId];
    if (account == nil) {
        // create a new account with a generaed account id
        account = [[AGOAuth2AuthzSession alloc] init];
        NSMutableDictionary* accountDictionnary = [NSMutableDictionary mutableCopy];
        [_oauthAccountStorage save:accountDictionnary error:nil]; //TODO
        account.accountId = accountDictionnary[@"id"];
        // assign newly created accountId
        adapter.accountId = account.accountId;
    }
   
    // initialize authzModule with stored tokens
    adapter.sessionStorage.clientId = account.clientId;
    adapter.sessionStorage.accessToken = account.accessToken;
    adapter.sessionStorage.accessTokenExpirationDate = account.accessTokenExpirationDate;
    adapter.sessionStorage.refreshToken = account.refreshToken;
    
    // register to ne notifeid when token get refreshed to store them in AccountMgr
    [adapter.sessionStorage addObserver:self forKeyPath:@"accessToken" options:NSKeyValueObservingOptionNew context:(__bridge void *)(account.accountId)];
    
    return adapter;
}

#pragma mark - implement KVO callback
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"accessToken"]){
        NSString* oldValue = [change objectForKey:NSKeyValueChangeOldKey];
        NSString* newValue = [change objectForKey:NSKeyValueChangeNewKey];
        NSLog(@"NewValue==%@ context=%@", newValue, context);
    }
}

#pragma mark - implement public interface
//-(void)addAccount:(AGOAuth2AuthzSession*)account error:(NSError**) error {
//    [_oauthAccountStorage save:account error:error];
//        
//}
//
//-(BOOL)hasAccount:(NSString*)searchAccountId {
//    if ([_oauthAccountStorage read:searchAccountId] == nil)
//        return NO;
//    return YES;
//}
//
//-(AGOAuth2AuthzSession*)account:(NSString*)accountId {
//    return [_oauthAccountStorage read:accountId];
//}
//
//-(NSArray*)accounts {
//    return [_oauthAccountStorage readAll];
//}
@end
