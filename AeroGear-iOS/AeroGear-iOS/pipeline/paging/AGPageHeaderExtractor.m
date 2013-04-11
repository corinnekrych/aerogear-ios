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

#import "AGPageHeaderExtractor.h"

@implementation AGPageHeaderExtractor

- (NSDictionary*) parse:(id)response
                headers:(NSDictionary*)headers
                   next:(NSString*)nextIdentifier
                   prev:(NSString*)prevIdentifier {
    
    return [super parse:headers headers:headers next:nextIdentifier prev:prevIdentifier];
}

@end