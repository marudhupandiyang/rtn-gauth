
#import <React/RCTConvert.h>
#import "AuthenticationServices/ASAuthorizationAppleIDProvider.h"

@interface RCTConvert (ASAuthorizationAppleIDRequest)
+ (ASAuthorizationAppleIDRequest *)appIdRequestFromDictionary:(NSDictionary *)requestOptions;
@end
