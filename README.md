objc-libphonenumber
===================

This is a simple Objective-C formatter that uses libphonenumber and JavaScriptCore to format phone numbers.

#### Example usage

    libphonenumberFormatter *formatter = [[libphonenumberFormatter alloc] init];
    
    [formatter setCountryCode:@"US"];
    [formatter setAlwaysUseInternationalFormat:YES];
        
    NSLog(@"%@", [formatter stringForObjectValue:@"3151234567"]);

Outputs:

    +1 315-123-4567

#### Compatibility

This uses JavaScriptCore to run libphonenumber so it is currently Mac-only. JavaScriptCore is not public on iOS so you'll need to evaluate everything in a UIWebView or supply your own version of JavaScriptCore to use this on iOS.

#### Updating libphonenumber

Run the included script *build\_libphonenumber\_js.sh* to download and compile the latest versions of libphonenumber and closure-library:

    bash build_libphonenumber_js.sh libphonenumber_build

This will create a single JavaScript file *libphonenumber.js* in your current directly.

#### Credits
Contains a compiled version of libphonenumber (https://code.google.com/p/libphonenumber/) and parts of closure-library (https://code.google.com/p/closure-library/)