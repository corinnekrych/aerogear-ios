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

#import "AGAuthorizer.h"
#import "AGRestOAuth2Module.h"
//TODO to be removed with extensible adapter feature
#import "AGRestOAuth2FacebookModule.h"
#import "AGAuthzConfiguration.h"

@implementation AGAuthorizer {
    NSMutableDictionary* _modules;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _modules = [NSMutableDictionary dictionary];
    }
    return self;
}

+(instancetype) authorizer {
    return [[[self class] alloc] init];
}

-(id<AGAuthzModule>) authz:(void (^)(id<AGAuthzConfig> config)) config {
    AGAuthzConfiguration* authzConfig = [[AGAuthzConfiguration alloc] init];
    
    if (config) {
        config(authzConfig);
    }
    
    if(![authzConfig.type isEqualToString:@"AG_OAUTH2_FACEBOOK"] && ![authzConfig.type isEqualToString:@"AG_OAUTH2"])
        return nil;
    
    authzConfig.type = [self oauth2Type:authzConfig];

    id<AGAuthzModule> module = nil;
    // TODO to be changed with AGIOS-154 with extensible OAuth adapter
    if ([authzConfig.type isEqualToString:@"AG_OAUTH2_FACEBOOK"]) {
        module = [AGRestOAuth2FacebookModule moduleWithConfig:authzConfig];
        [_modules setValue:module forKey:[authzConfig name]];
    } else  if ([authzConfig.type isEqualToString:@"AG_OAUTH2"]) {
        module = [AGRestOAuth2Module moduleWithConfig:authzConfig];
        [_modules setValue:module forKey:[authzConfig name]];
    }
    return module;
}

-(id<AGAuthzModule>)remove:(NSString*) moduleName {
    id<AGAuthzModule> module = [self authzModuleWithName:moduleName];
    [_modules removeObjectForKey:moduleName];
    return module;
}

-(id<AGAuthzModule>)authzModuleWithName:(NSString*) moduleName {
    return [_modules valueForKey:moduleName];
}

-(NSString *) description {
    return [NSString stringWithFormat: @"%@ %@", self.class, _modules];
}

- (NSString*)oauth2Type:(AGAuthzConfiguration*)config {
    if ([[config.baseURL host] rangeOfString:@"facebook"].location != NSNotFound) {
        return @"AG_OAUTH2_FACEBOOK";
    }
    return @"AG_OAUTH2";
}

@end