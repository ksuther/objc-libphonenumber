//
//  libphonenumberFormatter.m
//  libphonenumber_js
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

#import "libphonenumberFormatter.h"
#import <JavaScriptCore/JavaScriptCore.h>

//JavaScript that is called by stringForObjectValue:
static NSString * const FormatScript = @"function formatNumber() {\
var PNF = i18n.phonenumbers.PhoneNumberFormat;\
var phoneUtil = i18n.phonenumbers.PhoneNumberUtil.getInstance();\
var number = phoneUtil.parseAndKeepRawInput(\"%1$@\", \"%2$@\");\
var isNumberValid = phoneUtil.isValidNumber(number);\
var region = phoneUtil.getRegionCodeForNumber(number);\
var type = (region == \"%2$@\" || region == null) ? PNF.%3$@ : PNF.INTERNATIONAL;\
return phoneUtil.format(number, type);\
}\
formatNumber();";

//JavaScript for AsYouTypeFormatter when useAsYouTypeFormatter is YES
static NSString * const AsYouTypeFormatScript = @"function formatAsYouTypeNumber() {\
var input = \"%1$@\";\
var result = null;\
var formatter = new i18n.phonenumbers.AsYouTypeFormatter('%2$@');\
for (var i = 0; i < input.length; i++) {\
    result = formatter.inputDigit(input.charAt(i));\
}\
return result;\
}\
formatAsYouTypeNumber();";

@interface libphonenumberFormatter ()
@property(nonatomic, assign) JSGlobalContextRef JSContext;

- (BOOL)_setupJSContext;
- (NSString *)_runScript:(NSString *)scriptString exceptionString:(__autoreleasing NSString **)exceptionString;
@end

@implementation libphonenumberFormatter

@synthesize countryCode = _countryCode;
@synthesize alwaysUseInternationalFormat = _alwaysUseInternationalFormat;

@synthesize JSContext = _JSContext;

- (id)init
{
    if ( (self = [super init]) ) {
        [self setCountryCode:[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode]];
        
        [self _setupJSContext];
    }
    return self;
}

- (void)dealloc
{
    JSGlobalContextRelease([self JSContext]);
}

- (NSString *)stringForObjectValue:(id)anObject
{
    NSAssert([anObject isKindOfClass:[NSString class]], @"anObject must be a string");
    anObject = [anObject stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    
    NSString *result = nil;
    
    if ([anObject length] > 0) {
        NSString *nationalOrInternational = [self alwaysUseInternationalFormat] ? @"INTERNATIONAL" : @"NATIONAL";
        NSString *formatScriptString = nil;
        
        if ([self useAsYouTypeFormatter]) {
            formatScriptString = [NSString stringWithFormat:AsYouTypeFormatScript, anObject, [self countryCode]];
        } else {
            formatScriptString = [NSString stringWithFormat:FormatScript, anObject, [self countryCode], nationalOrInternational];
        }
        
        NSString *exceptionString = NULL;
        
        result = [self _runScript:formatScriptString exceptionString:&exceptionString];
        
        NSAssert(exceptionString == nil, exceptionString);
    }
    
    return result;
}

#pragma mark - Private

- (BOOL)_setupJSContext
{
    NSURL *jsPath = [[NSBundle bundleForClass:[self class]] URLForResource:@"libphonenumber" withExtension:@"js"];
    NSError *error;
    NSString *libraryScript = [NSString stringWithContentsOfURL:jsPath usedEncoding:NULL error:&error];
    
    JSGlobalContextRef context = JSGlobalContextCreate(NULL);
    NSString *exceptionString = NULL;
    
    [self setJSContext:context];
    [self _runScript:libraryScript exceptionString:&exceptionString];
    
    return exceptionString == nil;
}

- (NSString *)_runScript:(NSString *)scriptString exceptionString:(__autoreleasing NSString **)exceptionString
{
    NSString *outString;
    JSStringRef string = JSStringCreateWithCFString((__bridge CFStringRef)scriptString);
    JSValueRef exception = NULL;
    JSValueRef result = JSEvaluateScript([self JSContext], string, NULL, NULL, 0, &exception);
    
    JSStringRelease(string);
    
    //Check for errors
    if (exception) {
        JSStringRef exceptionStr = JSValueToStringCopy([self JSContext], exception, NULL);
        
        if (exceptionString) {
            *exceptionString = (__bridge_transfer NSString *)JSStringCopyCFString(kCFAllocatorDefault, exceptionStr);
        }
        
        JSStringRelease(exceptionStr);
    } else {
        //Pull out result
        JSStringRef resultString = JSValueToStringCopy([self JSContext], result, &exception);
        
        outString = (__bridge_transfer NSString *)JSStringCopyCFString(kCFAllocatorDefault, resultString);
        
        JSStringRelease(resultString);
    }
    
    return outString;
}

@end
