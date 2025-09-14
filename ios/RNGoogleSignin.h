#import <React/RCTComponent.h>

#ifdef RCT_NEW_ARCH_ENABLED
  #import <RTNGauthSpec/RTNGauthSpec.h>
#else
  #import <React/RCTBridgeModule.h>
#endif

@interface RNGoogleSignin : NSObject <
#ifdef RCT_NEW_ARCH_ENABLED
NativeGoogleSigninSpec
#else
RCTBridgeModule
#endif
>

@end
