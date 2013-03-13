//
//  main.m
//  objc-libphonenumber Demo
//
//  Created by Kent Sutherland on 8/6/12.
//  Copyright 2012 Flexibits Inc.
//  
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//  
//     http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <Foundation/Foundation.h>
#import <objc-libphonenumber/libphonenumberFormatter.h>

int main(int argc, const char * argv[])
{
    @autoreleasepool {
        libphonenumberFormatter *formatter = [[libphonenumberFormatter alloc] init];
        
        [formatter setCountryCode:@"US"];
        [formatter setAlwaysUseInternationalFormat:YES];
        
        NSLog(@"Using PhoneNumberFormat");
        NSLog(@"%@", [formatter stringForObjectValue:@"3151234567"]);
        NSLog(@"%@", [formatter stringForObjectValue:@"+44 020 1234 5678"]);
        
        [formatter setUseAsYouTypeFormatter:YES];
        
        NSLog(@"Using AsYouTypeFormatter");
        NSLog(@"%@", [formatter stringForObjectValue:@"+13151234"]);
        NSLog(@"%@", [formatter stringForObjectValue:@"+4402012"]);
    }
    return 0;
}
