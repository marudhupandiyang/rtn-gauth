# RTNGauth

## Common Setup

  - Install package

        npm install github:marudhupandiyang/rtn-gauth#main

  - Import in your Javascript as shown below

        import { GoogleSignin } from 'rtn-gauth';

  - Call it in the place your require using


        const res = await GoogleSignin.signIn();
        console.log('result from res', res);

## iOS Configuration
- Follow the instructions from here -> https://developers.google.com/identity/sign-in/ios/sign-in#objective-c
  - Set URL Types as described in the link above
  - modify AppDelegate.mm as described in the doc.
  - You can ignore all server and server token related items.

## Android Configuration
  - NO EXPLICT CONFIGURATION REQUIRED
  - Sign in is impletemented using Credential Manager.
  - Read this guide for more information -> https://developer.android.com/identity/sign-in/credential-manager
