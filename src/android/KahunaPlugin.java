/*
 * Kahuna CONFIDENTIAL
 * __________________
 *
 *  2014 Kahuna, Inc.
 *  All Rights Reserved.
 *
 * NOTICE:  All information contained herein is, and remains
 * the property of Kahuna, Inc. and its suppliers,
 * if any.  The intellectual and technical concepts contained
 * herein are proprietary to Kahuna, Inc.
 * and its suppliers and may be covered by U.S. and Foreign Patents,
 * patents in process, and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Kahuna, Inc.
 */
package com.kahuna.phonegap.sdk;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

import com.kahuna.sdk.KahunaAnalytics;
import com.kahuna.sdk.KahunaUserCredentialKeys;

public class KahunaPlugin extends CordovaPlugin {
	
	private static final String TAG = "Kahuna";
	
	private static final String START_WITH_KEY = "startWithKey";
	private static final String ON_START = "onStart";
	private static final String ON_STOP = "onStop";
	private static final String TRACK_EVENT = "trackEvent";
	private static final String SET_USER_CREDENTIALS = "setUserCredentials";
	private static final String LOGOUT = "logout";
	private static final String SET_USER_ATTRIBUTES = "setUserAttributes";
	private static final String ENABLE_PUSH = "enablePush";
	private static final String DISABLE_PUSH = "disablePush";
	private static final String SET_DEBUG_MODE = "setDebugMode";
	
	@Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
		
		try {
			if(START_WITH_KEY.equals(action)) {
				String secretKey = args.getString(0);
				String senderId = null;
				
				if(args.length() > 1) {
					senderId = args.getString(1);
				}
				
				this.startWithKey(secretKey, senderId);
				return true;
			}
			else if(ON_START.equals(action)) {
				this.onStart();
			}
			else if(ON_STOP.equals(action)) {
				this.onStop();
			}
			else if(TRACK_EVENT.equals(action)) {
				String eventName = args.getString(0);
				this.trackEvent(eventName);
			}
			else if(SET_USER_ATTRIBUTES.equals(action)) {
				Map<String, String> userAttributes = null;
				JSONObject userAttsObject = args.getJSONObject(0);
				userAttributes = new HashMap<String, String>();
				Iterator<?> keys = userAttsObject.keys();
				while (keys.hasNext()) {
					String key = (String) keys.next();
					userAttributes.put(key, userAttsObject.getString(key));
				}
				this.setUserAttributes(userAttributes);
			}
			else if(SET_USER_CREDENTIALS.equals(action)) {
				String username = args.getString(0);
				String email = args.getString(1);
				this.setUserCredentials(username, email);
			}
			else if(LOGOUT.equals(action)) {
				this.logout();
			}
			else if(ENABLE_PUSH.equals(action)) {
				this.enablePush();
			}
			else if(DISABLE_PUSH.equals(action)) {
				this.disablePush();
			}
			else if(SET_DEBUG_MODE.equals(action)) {
				boolean enabled = args.getBoolean(0);
				this.setDebugMode(enabled);
			}
			else {
				Log.w(TAG, "Execute " + action + " did no match any method definition defined by Kahuna.");
				return false;
			}
		}
		catch(Exception e) {
			e.printStackTrace();
			return false;
		}
        return false;
    }
    
    private void startWithKey(final String secretKey, final String senderId) {
    	KahunaAnalytics.onAppCreate(this.cordova.getActivity().getApplicationContext(), secretKey, senderId);
    	KahunaAnalytics.setHybridSDKVersion("cordova_sdk_version", "437");
    	KahunaAnalytics.start();
    }
    
    private void onStart() {
    	KahunaAnalytics.start();
    }
    
    private void onStop() {
    	KahunaAnalytics.stop();
    }
    
    private void trackEvent(final String eventName) {
    	KahunaAnalytics.trackEvent(eventName);
    }
    
    private void setUserCredentials(final String username, final String email) {
    	if(username != null)
    		KahunaAnalytics.setUserCredential(KahunaUserCredentialKeys.USERNAME_KEY, username);
    	if(email != null)
    		KahunaAnalytics.setUserCredential(KahunaUserCredentialKeys.EMAIL_KEY, email);
    }
    
    private void logout() {
    	KahunaAnalytics.logout();
    }
    
    private void setUserAttributes(Map<String, String> userAttributes) {
    	KahunaAnalytics.setUserAttributes(userAttributes);
    }
    
    private void enablePush() {
    	KahunaAnalytics.enablePush();
    }
    
    private void disablePush() {
    	KahunaAnalytics.disablePush();
    }
    
    private void setDebugMode(boolean enable) {
    	KahunaAnalytics.setDebugMode(enable);
    }
    
    public class KAPushReceiver extends BroadcastReceiver {

    	@Override
    	public void onReceive(Context context, Intent intent) {
    		String action = intent.getAction();
    		if(action.equals(KahunaAnalytics.ACTION_PUSH_CLICKED)){
    			/* Push notification was clicked. */		
    			Bundle extras = intent.getBundleExtra(KahunaAnalytics.EXTRA_LANDING_DICTIONARY_ID);
    			for (String key : extras.keySet()) {
    			    Object value = extras.get(key);
    			    Log.d(TAG, String.format("%s : %s (%s)", key,  
    			        value.toString(), value.getClass().getName()));
    			}
    		}
    		if(action.equals(KahunaAnalytics.ACTION_PUSH_RECEIVED)){
    			/* Push notification was received. */
    			Log.i(TAG, "Received Kahuna push");
    			
    			Bundle extras = intent.getBundleExtra(KahunaAnalytics.EXTRA_LANDING_DICTIONARY_ID);
    			for (String key : extras.keySet()) {
    			    Object value = extras.get(key);
    			    Log.d(TAG, String.format("%s : %s (%s)", key,  
    			        value.toString(), value.getClass().getName()));
    			}
    		}
    	}

    }
}
