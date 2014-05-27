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

#import <Kiwi/Kiwi.h>
#import "AGAuthorizer.h"

SPEC_BEGIN(AGAuthorizerSpec)

describe(@"AGAuthorizer", ^{
    context(@"when newly created", ^{

        __block AGAuthorizer *authorizer = nil;

        beforeEach(^{
            authorizer = [AGAuthorizer authorizer];
        });

        it(@"should not be nil", ^{
            [authorizer shouldNotBeNil];
        });
    });

    context(@"when adding a new module", ^{

        __block AGAuthorizer *authorizer = nil;

        beforeEach(^{
            authorizer = [AGAuthorizer authorizer];
        });

        it(@"should have default endpoints if not specified", ^{
            id<AGAuthzModule> module = [authorizer authz:^(id<AGAuthzConfig> config) {
                [config setName:@"SomeModule"];
                [config setBaseURL:[NSURL URLWithString:@"https://server:8080/application/"]];
            }];

            [(id)module shouldNotBeNil];

            [[module.authzEndpoint should] equal:@"oauth2/auth"];
            [[module.accessTokenEndpoint should] equal:@"oauth2/access/codes"];
        });

        it(@"should respect user-configured endpoints", ^{
            id<AGAuthzModule> module =  [authorizer authz:^(id<AGAuthzConfig> config) {
                [config setName:@"SomeModule"];
                [config setBaseURL:[NSURL URLWithString:@"https://server:8080/application/subcontext/"]];
                [config setAccessTokenEndpoint:@"auth/in"];
                [config setAuthzEndpoint:@"auth/out"];
            }];

            [(id)module shouldNotBeNil];

            [[module.accessTokenEndpoint should] equal:@"auth/in"];
            [[module.authzEndpoint should] equal:@"auth/out"];
        });
        
        it(@"should respect user-configured endpoints wether prefixed or not with slash", ^{
            id<AGAuthzModule> module =  [authorizer authz:^(id<AGAuthzConfig> config) {
                [config setName:@"SomeModule"];
                [config setBaseURL:[NSURL URLWithString:@"https://server:8080/application/subcontext/"]];
                [config setAccessTokenEndpoint:@"/auth/in"];
                [config setAuthzEndpoint:@"/auth/out"];
            }];
            
            [(id)module shouldNotBeNil];
            
            [[module.accessTokenEndpoint should] equal:@"auth/in"];
            [[module.authzEndpoint should] equal:@"auth/out"];
        });

        it(@"should have a default type if not specified", ^{
            id<AGAuthzModule> module = [authorizer authz:^(id<AGAuthzConfig> config) {
                [config setName:@"SomeModule"];
                [config setBaseURL:[NSURL URLWithString:@"https://server:8080/application/"]];
            }];

            [(id)module shouldNotBeNil];

            [[module.type should] equal:@"AG_OAUTH2"];
        });
        
        it(@"should detect facebook OAuth2", ^{
            id<AGAuthzModule> module = [authorizer authz:^(id<AGAuthzConfig> config) {
                [config setName:@"SomeModule"];
                [config setAuthzEndpoint:@"https://www.facebook.com/dialog/oauth"];
                [config setBaseURL:nil];
            }];
            
            [(id)module shouldNotBeNil];
            
            [[module.type should] equal:@"AG_OAUTH2_FACEBOOK"];
        });

        it(@"should not allow an invalid type", ^{
            id<AGAuthzModule> module = [authorizer authz:^(id<AGAuthzConfig> config) {
                [config setName:@"SomeModule"];
                [config setBaseURL:[NSURL URLWithString:@"https://server:8080/application/"]];
                [config setType:@"INVALID"];
            }];

            [(id)module shouldBeNil];
        });
    });

    context(@"when adding and removing modules", ^{

        __block AGAuthorizer *authorizer = nil;

        beforeEach(^{
            authorizer = [AGAuthorizer authorizer];
        });

        it(@"should successfully remove previously added modules", ^{
            id<AGAuthzModule> module = [authorizer authz:^(id<AGAuthzConfig> config) {
                [config setName:@"SomeModule"];
                [config setBaseURL:[NSURL URLWithString:@"https://server:8080/application/"]];
            }];

            [(id)module shouldNotBeNil];

            id<AGAuthzModule> otherModule = [authorizer authz:^(id<AGAuthzConfig> config) {
                [config setName:@"OtherModule"];
                [config setBaseURL:[NSURL URLWithString:@"https://server:8080/another-application/"]];
            }];

            [(id)otherModule shouldNotBeNil];

            // look em up:
            [(id)[authorizer authzModuleWithName:@"SomeModule"] shouldNotBeNil];
            [(id)[authorizer authzModuleWithName:@"OtherModule"] shouldNotBeNil];

            // remove module
            [authorizer remove:@"SomeModule"];
            // look it up:
            [(id)[authorizer authzModuleWithName:@"SomeModule"] shouldBeNil];

            // remove module
            [authorizer remove:@"OtherModule"];
            // look it up:
            [(id)[authorizer authzModuleWithName:@"OtherModule"] shouldBeNil];
        });

        it(@"should not remove a non existing module", ^{
            id<AGAuthzModule> module = [authorizer authz:^(id<AGAuthzConfig> config) {
                [config setName:@"SomeModule"];
                [config setBaseURL:[NSURL URLWithString:@"https://server:8080/application/"]];
            }];

            [(id)module shouldNotBeNil];

            // remove non existing module
            id<AGAuthzModule> fooModule = [authorizer remove:@"FOO"];
            [(id)fooModule shouldBeNil];

            // should contain the first module
            module = [authorizer authzModuleWithName:@"SomeModule"];
            [(id)module shouldNotBeNil];
        });

        it(@"should not fail when you lookup a non existing module", ^{
            // lookup non existing module
            id<AGAuthzModule> fooModule = [authorizer authzModuleWithName:@"FOO"];
            [(id)fooModule shouldBeNil];
        });
    });
});

SPEC_END