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

#import "AGAuthenticator.h"
#import "AGRestAuthentication.h"
#import "AGAuthConfiguration.h"
#import "AGOAuth1Configuration.h"
#import "AGOAuth1AuthenticationModule.h"
#import "AGOAuth1Authentication.h"

@implementation AGAuthenticator {
    NSMutableDictionary* _modules;
}

- (id)init {
    self = [super init];
    if (self) {
        _modules = [NSMutableDictionary dictionary];
    }
    return self;
}

+(id) authenticator {
    return [[self alloc] init];
}

-(id<AGBaseAuthenticationModule>) auth:(void (^)(id<AGConfig> config)) config {
    
    if (config && [config conformsToProtocol:@protocol(AGAuthConfig)]) {
        AGAuthConfiguration* authConfig =[[AGAuthConfiguration alloc] init];
        config(authConfig);
        AGRestAuthentication* module = [AGRestAuthentication moduleWithConfig:authConfig];
        [_modules setValue:module forKey:[authConfig name]];
        return module;
    } else if (config && [config conformsToProtocol:@protocol(AGAuthConfig)]) {
        AGOAuth1Configuration* authConfig =[[AGOAuth1Configuration alloc] init];
        config(authConfig);
        AGOAuth1Authentication* module = [AGOAuth1Authentication moduleWithConfig:authConfig];
        [_modules setValue:module forKey:[authConfig name]];
        return module;
    } else {
        return nil;
    }
}

-(id<AGAuthenticationModule>)remove:(NSString*) moduleName {
    id<AGAuthenticationModule> module = [self authModuleWithName:moduleName];
    [_modules removeObjectForKey:moduleName];
    return module;
}

-(id<AGAuthenticationModule>)authModuleWithName:(NSString*) moduleName {
    return [_modules valueForKey:moduleName];
}

-(NSString *) description {
    return [NSString stringWithFormat: @"%@ %@", self.class, _modules];
}

@end