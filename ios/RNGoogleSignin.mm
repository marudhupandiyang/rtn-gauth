#import <React/RCTLog.h>
#import <React/RCTUtils.h>
#import <GoogleSignIn/GoogleSignIn.h>
#import "RNGoogleSignin.h"
#import "AuthenticationServices/ASAuthorizationAppleIDProvider.h"
#import "AuthenticationServices/ASAuthorizationController.h"

@implementation RNGoogleSignin

RCT_EXPORT_MODULE();

static NSString *const ASYNC_OP_IN_PROGRESS = @"ASYNC_OP_IN_PROGRESS";

- (NSDictionary *)constantsToExport
{
  return @{
           @"BUTTON_SIZE_ICON": @(kGIDSignInButtonStyleIconOnly),
           @"BUTTON_SIZE_STANDARD": @(kGIDSignInButtonStyleStandard),
           @"BUTTON_SIZE_WIDE": @(kGIDSignInButtonStyleWide),
           @"SIGN_IN_CANCELLED": [@(kGIDSignInErrorCodeCanceled) stringValue],
           @"SIGN_IN_REQUIRED": [@(kGIDSignInErrorCodeHasNoAuthInKeychain) stringValue],
           @"SCOPES_ALREADY_GRANTED": [@(kGIDSignInErrorCodeScopesAlreadyGranted) stringValue],
           @"IN_PROGRESS": ASYNC_OP_IN_PROGRESS,
           };
}

#ifdef RCT_NEW_ARCH_ENABLED
- (facebook::react::ModuleConstants<JS::NativeGoogleSignin::Constants>)getConstants {
  return facebook::react::typedConstants<JS::NativeGoogleSignin::Constants>(
          {.BUTTON_SIZE_ICON = kGIDSignInButtonStyleIconOnly,
                  .BUTTON_SIZE_STANDARD = kGIDSignInButtonStyleStandard,
                  .BUTTON_SIZE_WIDE = kGIDSignInButtonStyleWide,
                  .SIGN_IN_CANCELLED = [@(kGIDSignInErrorCodeCanceled) stringValue],
                  .SIGN_IN_REQUIRED = [@(kGIDSignInErrorCodeHasNoAuthInKeychain) stringValue],
                  .IN_PROGRESS = ASYNC_OP_IN_PROGRESS,
                  .SCOPES_ALREADY_GRANTED = [@(kGIDSignInErrorCodeScopesAlreadyGranted) stringValue],
          });
}
#endif

+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

RCT_EXPORT_METHOD(configure:(NSDictionary *)options
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
  resolve(@"done");
}

RCT_EXPORT_METHOD(signIn:(NSDictionary *)options
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
  UIViewController* presentingViewController = RCTPresentedViewController();

  [GIDSignIn.sharedInstance signInWithPresentingViewController:presentingViewController
                                                          hint:nil
                                              additionalScopes:nil
                                                    completion:^(GIDSignInResult *signInResult, NSError *error) {
    if (signInResult) {
      GIDGoogleUser *user = signInResult.user;
      NSURL *imageURL = user.profile.hasImage ? [user.profile imageURLWithDimension:120] : nil;

      NSDictionary *userInfo = @{
                                @"id": user.userID,
                                @"name": RCTNullIfNil(user.profile.name),
                                @"givenName": RCTNullIfNil(user.profile.givenName),
                                @"familyName": RCTNullIfNil(user.profile.familyName),
                                @"photo": imageURL ? imageURL.absoluteString : [NSNull null],
                                @"email": user.profile.email,
                                };

      NSDictionary *params = @{
                           @"user": userInfo,
                           @"idToken": user.idToken.tokenString,
//                           @"serverAuthCode": RCTNullIfNil(serverAuthCode),
                           @"scopes": user.grantedScopes,
                           };

      resolve(params);
    } else {
      reject(@"SIGN_IN_ERROR", @"Error in Google Signin", nil);
    }
  }];
}

- (NSDictionary*)createUserDictionary: (nullable GIDSignInResult *) result {
  return [self createUserDictionary:result.user serverAuthCode:result.serverAuthCode];
}

- (NSDictionary*)createUserDictionary: (nullable GIDGoogleUser *) user serverAuthCode: (nullable NSString*) serverAuthCode {
  if (!user) {
    return nil;
  }
  NSURL *imageURL = user.profile.hasImage ? [user.profile imageURLWithDimension:120] : nil;

  NSDictionary *userInfo = @{
                             @"id": user.userID,
                             @"name": RCTNullIfNil(user.profile.name),
                             @"givenName": RCTNullIfNil(user.profile.givenName),
                             @"familyName": RCTNullIfNil(user.profile.familyName),
                             @"photo": imageURL ? imageURL.absoluteString : [NSNull null],
                             @"email": user.profile.email,
                             };

  NSDictionary *params = @{
                           @"user": userInfo,
                           @"idToken": user.idToken.tokenString,
                           @"serverAuthCode": RCTNullIfNil(serverAuthCode),
                           @"scopes": user.grantedScopes,
                           };
  return params;
}

#ifdef RCT_NEW_ARCH_ENABLED
- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
   (const facebook::react::ObjCTurboModule::InitParams &)params
{
   return std::make_shared<facebook::react::NativeGoogleSigninSpecJSI>(params);
}
#endif

@end
