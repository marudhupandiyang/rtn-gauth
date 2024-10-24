package com.marudhupandiyang.rtngauth;

import android.app.Activity;
import android.os.AsyncTask;
import android.util.Log;

import androidx.credentials.Credential;
import androidx.credentials.CredentialManager;
import androidx.credentials.CredentialManagerCallback;
import androidx.credentials.CustomCredential;
import androidx.credentials.GetCredentialRequest;
import androidx.credentials.GetCredentialResponse;
import androidx.credentials.PasswordCredential;
import androidx.credentials.PublicKeyCredential;
import androidx.credentials.exceptions.GetCredentialException;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GoogleApiAvailability;
import com.google.android.libraries.identity.googleid.GetSignInWithGoogleOption;
import com.google.android.libraries.identity.googleid.GoogleIdTokenCredential;
import com.facebook.react.turbomodule.core.interfaces.TurboModule;
import com.facebook.react.bridge.ReactModuleWithSpec;
import com.facebook.react.bridge.ReactContextBaseJavaModule;

public class RNGoogleSigninModule extends ReactContextBaseJavaModule implements ReactModuleWithSpec, TurboModule {
  public static final String NAME = "RNGoogleSignin";
  public static final String PLAY_SERVICES_NOT_AVAILABLE = "PLAY_SERVICES_NOT_AVAILABLE";

  private Activity activityContext;
  private GetSignInWithGoogleOption signInWithGoogleOption;
  private GetCredentialRequest request;
  private CredentialManager credentialManager;
  private String googleClientId;

    @Override
    public String getName() {
        return NAME;
    }

    public RNGoogleSigninModule(final ReactApplicationContext reactContext) {
        super(reactContext);

        this.activityContext = this.getCurrentActivity();
        this.credentialManager = CredentialManager.create(activityContext);
    }

    @ReactMethod
    public void playServicesAvailable(boolean showPlayServicesUpdateDialog, Promise promise) {
        Activity activity = getCurrentActivity();

        if (activity == null) {
            Log.w(NAME, "could not determine playServicesAvailable, activity is null");
            rejectWithNullActivity(promise);
            return;
        }

        GoogleApiAvailability googleApiAvailability = GoogleApiAvailability.getInstance();
        int status = googleApiAvailability.isGooglePlayServicesAvailable(activity);

        if (status != ConnectionResult.SUCCESS) {
            if (showPlayServicesUpdateDialog && googleApiAvailability.isUserResolvableError(status)) {
                int requestCode = 2404;
                googleApiAvailability.getErrorDialog(activity, status, requestCode).show();
            }
            promise.reject(PLAY_SERVICES_NOT_AVAILABLE, "Play services not available");
        } else {
            promise.resolve(true);
        }
    }

    static void rejectWithNullActivity(Promise promise) {
        promise.reject(NAME, "activity is null1");
    }

    @ReactMethod
    public void configure(final ReadableMap config, Promise promise) {
        try {
            this.googleClientId = config.getString("googleclientid");

            this.signInWithGoogleOption = new GetSignInWithGoogleOption.Builder(this.googleClientId)
                    .build();

            this.request = new GetCredentialRequest.Builder()
                    .addCredentialOption(signInWithGoogleOption)
                    .build();

            promise.resolve(true);
        } catch (Exception ex) {
            promise.reject(ex.getMessage());
        }
    }

    @ReactMethod
    public void signIn(final ReadableMap config, Promise promise) {
        credentialManager.getCredentialAsync(
                activityContext,
                request,
                null,
                AsyncTask.THREAD_POOL_EXECUTOR,
                new CredentialManagerCallback<GetCredentialResponse, GetCredentialException>() {
                    @Override
                    public void onResult(GetCredentialResponse result) {
                        promise.resolve(handleSignIn(result));
                    }

                    @Override
                    public void onError(GetCredentialException e) {
                        promise.reject("Error", handleFailure(e));
                    }
                }
        );
    }

    private String handleFailure(GetCredentialException e) {
        Log.e("mar", e.getMessage());
        return e.getMessage();
    }

    public WritableMap handleSignIn(GetCredentialResponse result) {
        // Handle the successfully returned credential.
        Credential credential = result.getCredential();

        if (credential instanceof PublicKeyCredential) {
            String responseJson = ((PublicKeyCredential) credential).getAuthenticationResponseJson();
            // Share responseJson i.e. a GetCredentialResponse on your server to validate and authenticate
            Log.e("mar1", responseJson);
        } else if (credential instanceof PasswordCredential) {
            String username = ((PasswordCredential) credential).getId();
            String password = ((PasswordCredential) credential).getPassword();
            // Use id and password to send to your server to validate and authenticate
            Log.e("mar1", username + "--" + password);
        } else if (credential instanceof CustomCredential) {
            if (GoogleIdTokenCredential.TYPE_GOOGLE_ID_TOKEN_CREDENTIAL.equals(credential.getType())) {
                // Use googleIdTokenCredential and extract id to validate and
                // authenticate on your server
                GoogleIdTokenCredential googleIdTokenCredential = GoogleIdTokenCredential.createFrom(((CustomCredential) credential).getData());

                WritableMap data = Arguments.createMap();

                data.putString("picture", googleIdTokenCredential.getProfilePictureUri().toString());
                data.putString("displayName", googleIdTokenCredential.getDisplayName());
                data.putString("email", googleIdTokenCredential.getId());
                data.putString("givenName", googleIdTokenCredential.getGivenName());
                data.putString("keyIDToken", googleIdTokenCredential.getIdToken());
                data.putString("familyName", googleIdTokenCredential.getFamilyName());
                return data;
            } else {
                // Catch any unrecognized custom credential type here.
                Log.e("mar", "Unexpected type of credential1");
            }
        } else {
            // Catch any unrecognized credential type here.
            Log.e("mar", "Unexpected type of credential");
        }
        return null;
    }
}
