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
#import "AGHTTPMockHelper.h"
#import "AGHttpClient.h"
#import "AGAuthzConfiguration.h"
#import "AGRestOAuth2Module.h"
#import "AGRestOAuth2FacebookModule.h"
#import <OCMock/OCMock.h>

SPEC_BEGIN(AGRestOAuth2ModuleSpec)

describe(@"AGRestAuthzModule", ^{
    context(@"when newly created", ^{

        __block NSString *ACCESS_TOKEN_RESPONSE = nil;

        __block AGRestOAuth2Module* restAuthzModule = nil;

        __block BOOL finishedFlag;
        
        __block AGAuthzConfiguration* config;

        beforeAll(^{
            ACCESS_TOKEN_RESPONSE =  @"ACCESS_TOKEN";
        });

        beforeEach(^{

            // setup REST Authenticator
            config = [[AGAuthzConfiguration alloc] init];
            config.name = @"restAuthMod";
            config.baseURL = [[NSURL alloc] initWithString:@"https://accounts.google.com"];
            config.authzEndpoint = @"/o/oauth2/auth";
            config.accessTokenEndpoint = @"/o/oauth2/token";
            config.revokeTokenEndpoint = @"/o/oauth2/revoke";
            config.clientId = @"XXXXX";
            config.redirectURL = @"org.aerogear.GoogleDrive";
            config.scopes = @[@"https://www.googleapis.com/auth/drive"];
            config.timeout = 1; // this is just for testing of timeout methods
            restAuthzModule = [AGRestOAuth2Module moduleWithConfig:config];
            
        });

        afterEach(^{
            // remove all handlers installed by test methods
            // to avoid any interference
            [AGHTTPMockHelper clearAllMockedRequests];

            finishedFlag = NO;
        });

        it(@"should not be nil", ^{
            [restAuthzModule shouldNotBeNil];
        });

        it(@"should successfully request authorization code when no access token", ^{
            
            void (^callbackSuccess)(id obj) = ^ void (id object) {};
            void (^callbackFailure)(NSError *error) = ^ void (NSError *error) {};
            
            // Create a partial mock of restAuthzModule
            id mock = [OCMockObject partialMockForObject:restAuthzModule];

            [[mock expect] requestAuthorizationCodeSuccess:[OCMArg any] failure:[OCMArg any]];
            
            [restAuthzModule requestAccessSuccess:callbackSuccess failure:callbackFailure];
            
            [mock verify];
            [mock stopMocking];
        });
        
        it(@"should issue a refresh request when access token has expired", ^{
            
            void (^callbackSuccess)(id obj) = ^ void (id object) {};
            void (^callbackFailure)(NSError *error) = ^ void (NSError *error) {};
            
            restAuthzModule.sessionStorage.accessToken = @"ACCESS_TOKEN";
            restAuthzModule.sessionStorage.refreshToken = @"REFRESH_TOKEN";
            restAuthzModule.sessionStorage.accessTokenExpirationDate = 0;
            
            // Create a partial mock of restAuthzModule
            id mock = [OCMockObject partialMockForObject:restAuthzModule];
            
            [[mock expect] refreshAccessTokenSuccess:[OCMArg any] failure:[OCMArg any]];
            
            [restAuthzModule requestAccessSuccess:callbackSuccess failure:callbackFailure];
            
            [mock verify];
            [mock stopMocking];
        });
        
        it(@"should just run success block if access token are still valid", ^{
            __block BOOL wasSuccessCallbackCalled = NO;
            void (^callbackSuccess)(id obj) = ^ void (id object) {wasSuccessCallbackCalled = YES;};
            void (^callbackFailure)(NSError *error) = ^ void (NSError *error) {};
            
            restAuthzModule.sessionStorage.accessToken = @"ACCESS_TOKEN";
            restAuthzModule.sessionStorage.refreshToken = @"REFRESH_TOKEN";
            restAuthzModule.sessionStorage.accessTokenExpirationDate = [[NSDate date] dateByAddingTimeInterval:15000];
            
            [restAuthzModule requestAccessSuccess:callbackSuccess failure:callbackFailure];
            [[theValue(wasSuccessCallbackCalled) should] equal:theValue(YES)];
        });
        
        it(@"should run authz access token well formatted for pipe call", ^{
            
            restAuthzModule.sessionStorage.accessToken = @"ACCESS_TOKEN";
            
            NSDictionary* accessToken = [restAuthzModule authorizationFields];
            
            [[accessToken should] equal:@{@"Authorization": @"Bearer ACCESS_TOKEN"}];
        });
        
        it(@"should issue a request for authz code when no previous access grant was requested before", ^{
            __block BOOL wasSuccessCallbackCalled = NO;
            void (^callbackSuccess)(id obj) = ^ void (id object) {wasSuccessCallbackCalled = YES;};
            void (^callbackFailure)(NSError *error) = ^ void (NSError *error) {};
            
            //given a mock UIApplication
            id mockApplication = [OCMockObject niceMockForClass:[UIApplication class]];
            [[[mockApplication stub] andReturn:mockApplication] sharedApplication];
            [[mockApplication expect] openURL:[OCMArg any]];
            
            AGRestOAuth2Module* myRestAuthzModule = [[AGRestOAuth2Module alloc] initWithConfig:config];
            [myRestAuthzModule requestAuthorizationCodeSuccess:callbackSuccess failure:callbackFailure];

            [mockApplication verify];
            [mockApplication stopMocking];
        });
        
        it(@"should run success when a user approved authz", ^{

            NSNotification* notification = [NSNotification notificationWithName:@"AGAppLaunchedWithURLNotification" object:nil userInfo:@{UIApplicationLaunchOptionsURLKey:[NSURL URLWithString:@"fb240176532852375://authorize/?code=AQQ#_=_"]}];

            // Create a partial mock of restAuthzModule
            id mock = [OCMockObject partialMockForObject:restAuthzModule];
            [[mock expect] exchangeAuthorizationCodeForAccessToken:[OCMArg any] success:[OCMArg any] failure:[OCMArg any]];
            
            [mock extractCode:notification success:[OCMArg any] failure:[OCMArg any]];
            
            [mock verify];
            [mock stopMocking];

        });
        
        it(@"should run failure when a user cancel authz", ^{
            __block BOOL wasSuccessCallbackCalled = NO;
            __block BOOL wasFailureCallbackCalled = NO;
            void (^callbackSuccess)(id obj) = ^ void (id object) {wasSuccessCallbackCalled = YES;};
            void (^callbackFailure)(NSError *error) = ^ void (NSError *error) {wasFailureCallbackCalled = YES;};
            NSNotification* notification = [NSNotification notificationWithName:@"AGAppLaunchedWithURLNotification" object:nil userInfo:@{UIApplicationLaunchOptionsURLKey:[NSURL URLWithString:@"org.aerogear.shoot:/oauth2Callback?error=access_denied"]}];
            
            AGRestOAuth2Module* myRestAuthzModule = [[AGRestOAuth2Module alloc] initWithConfig:config];
            
            [myRestAuthzModule extractCode:notification success:callbackSuccess failure:callbackFailure];
            
            [[theValue(wasFailureCallbackCalled) should] equal:theValue(YES)];
        });
        
        it(@"should issue a request for exchanging authz code for access token when no previous access grant was requested before", ^{
            __block BOOL wasSuccessCallbackCalled = NO;
            void (^callbackSuccess)(id obj) = ^ void (id object) {wasSuccessCallbackCalled = YES;};
            void (^callbackFailure)(NSError *error) = ^ void (NSError *error) {};
            
            id mockAGHTTPClient = [OCMockObject mockForClass:[AGHttpClient class]];
            NSString* code = @"CODE";
            
            AGRestOAuth2Module* myRestAuthzModule = [[AGRestOAuth2Module alloc] initWithConfig:config client:mockAGHTTPClient];
            
            NSDictionary* paramDict = @{@"code":code, @"client_id":config.clientId, @"redirect_uri": config.redirectURL, @"grant_type":@"authorization_code"};
            
            [[mockAGHTTPClient expect] POST:config.accessTokenEndpoint parameters:paramDict success:[OCMArg any] failure:[OCMArg any]];
            
            [myRestAuthzModule exchangeAuthorizationCodeForAccessToken:code success:callbackSuccess failure:callbackFailure];
            
            [mockAGHTTPClient verify];
            [mockAGHTTPClient stopMocking];
        });
        
        it(@"should issue a request for refreshing access token with refresh token as param", ^{
            __block BOOL wasSuccessCallbackCalled = NO;
            void (^callbackSuccess)(id obj) = ^ void (id object) {wasSuccessCallbackCalled = YES;};
            void (^callbackFailure)(NSError *error) = ^ void (NSError *error) {};
            
            id mockAGHTTPClient = [OCMockObject mockForClass:[AGHttpClient class]];
            
            AGRestOAuth2Module* myRestAuthzModule = [[AGRestOAuth2Module alloc] initWithConfig:config client:mockAGHTTPClient];
            myRestAuthzModule.sessionStorage.refreshToken = @"REFRESH_TOKEN";
            
            NSDictionary* paramDict = @{@"refresh_token":@"REFRESH_TOKEN", @"client_id":config.clientId, @"grant_type":@"refresh_token"};
            
            [[mockAGHTTPClient expect] POST:config.accessTokenEndpoint parameters:paramDict success:[OCMArg any] failure:[OCMArg any]];
            
            [myRestAuthzModule refreshAccessTokenSuccess:callbackSuccess failure:callbackFailure];
            
            [mockAGHTTPClient verify];
            [mockAGHTTPClient stopMocking];
        });
        
        it(@"should issue a request to revoke access/refresh tokens", ^{
            __block BOOL wasSuccessCallbackCalled = NO;
            void (^callbackSuccess)(id obj) = ^ void (id object) {wasSuccessCallbackCalled = YES;};
            void (^callbackFailure)(NSError *error) = ^ void (NSError *error) {};
            
            id mockAGHTTPClient = [OCMockObject mockForClass:[AGHttpClient class]];
            
            AGRestOAuth2Module* myRestAuthzModule = [[AGRestOAuth2Module alloc] initWithConfig:config client:mockAGHTTPClient];
            myRestAuthzModule.sessionStorage.refreshToken = @"REFRESH_TOKEN";
            myRestAuthzModule.sessionStorage.accessToken = @"ACCESS_TOKEN";
            
            NSDictionary* paramDict = @{@"token":@"ACCESS_TOKEN"};
            
            [[mockAGHTTPClient expect] POST:config.revokeTokenEndpoint parameters:paramDict success:[OCMArg any] failure:[OCMArg any]];
            
            [myRestAuthzModule revokeAccessSuccess:callbackSuccess failure:callbackFailure];
            
            [mockAGHTTPClient verify];
            [mockAGHTTPClient stopMocking];
        });
        
        it(@"should issue a request to revoke access/refresh tokens with DELETE for facebook adapter", ^{
            
            // setup REST Authenticator
            config = [[AGAuthzConfiguration alloc] init];
            config.name = @"restAuthMod";
            config.baseURL = [[NSURL alloc] init];
            config.authzEndpoint = @"https://www.facebook.com/dialog/oauth";
            config.accessTokenEndpoint = @"https://graph.facebook.com/oauth/access_token";
            config.clientId = @"765891443445434";
            config.clientSecret = @"e489a7b0a034df9e57bf8c2a9d74fd26";
            config.redirectURL = @"fb765891443445434://authorize/";
            config.scopes = @[@"user_friends, photo_upload, publish_actions"];
            config.type = @"AG_OAUTH2_FACEBOOK";
            config.revokeTokenEndpoint = @"https://www.facebook.com/me/permissions";
            restAuthzModule = [AGRestOAuth2Module moduleWithConfig:config];
            
            __block BOOL wasSuccessCallbackCalled = NO;
            void (^callbackSuccess)(id obj) = ^ void (id object) {wasSuccessCallbackCalled = YES;};
            void (^callbackFailure)(NSError *error) = ^ void (NSError *error) {};
            
            id mockAGHTTPClient = [OCMockObject mockForClass:[AGHttpClient class]];
            
            AGRestOAuth2FacebookModule* myRestAuthzModule = [[AGRestOAuth2FacebookModule alloc] initWithConfig:config client:mockAGHTTPClient];
            myRestAuthzModule.sessionStorage.refreshToken = @"REFRESH_TOKEN";
            myRestAuthzModule.sessionStorage.accessToken = @"ACCESS_TOKEN";
            
            NSDictionary* paramDict = @{@"access_token":@"ACCESS_TOKEN"};
            
            [[mockAGHTTPClient expect] DELETE:config.revokeTokenEndpoint parameters:paramDict success:[OCMArg any] failure:[OCMArg any]];
            
            [myRestAuthzModule revokeAccessSuccess:callbackSuccess failure:callbackFailure];
            
            [mockAGHTTPClient verify];
            [mockAGHTTPClient stopMocking];
        });

    });
});

SPEC_END