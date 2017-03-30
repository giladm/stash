/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2011, 2015
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */
package com.ibm.mce.samples.gcm;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;

import com.ibm.mce.sdk.api.notification.Action;
import com.ibm.mce.sdk.api.notification.MceNotificationAction;
import com.ibm.mce.sdk.api.notification.NotificationDetails;
import com.ibm.mce.sdk.util.Logger;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.Map;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.app.Activity;
import android.widget.Toast;

public class NewsNotificationAction  extends Activity  implements MceNotificationAction{
    private WebView mWebview;

    public static final String TAG = "NewslNotificationAction";

    public static final String DOMAIN_URL = "http://www.albayan.ae";
    public static final String DOMAIN_URL_CATEGORY = "http://media.albayan.ae/rss/mobile";

    private static final String NOTIFICATION_TITLE = "com.xtify.sdk.NOTIFICATION_TITLE";
    private static final String NOTIFICATION_CONTENT = "com.xtify.sdk.NOTIFICATION_CONTENT";

    public static final String NEWS_CATEGORY_KEY = "cu";
    public static final String NEWS_ARTICLE_KEY = "au";


    @Override
    public void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);
    }
    @Override
    public void handleAction(Context context, String type, String name, String attribution, String mailingId, Map<String, String> payload, boolean fromNotification) {
        String valueJSONStr = payload.get(Action.KEY_VALUE);

        if(valueJSONStr != null && !(valueJSONStr.trim().length()==0)) {
            try {
                JSONObject valueJSON = new JSONObject(valueJSONStr);
                String categoryUrl = valueJSON.getString(NEWS_CATEGORY_KEY);
                String articleUrl = valueJSON.getString(NEWS_ARTICLE_KEY);
                String url ="http://www.albayan.ae/five-senses/east-and-west/2017-03-07-1.2879453?_ga=1.173536288.2092588678.1488955851";
                Logger.v(TAG, "News is about to be visisble. cu:" +categoryUrl+"au"+articleUrl+"u:"+url);
/*                Intent intent = new Intent(context, WebViewClient.class);
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                intent.putExtra("url",url);

  */            mWebview  = new WebView(this);
                mWebview.getSettings().setJavaScriptEnabled(true); // enable javascript
                final Activity activity = this;
                mWebview.setWebViewClient(new WebViewClient() {
                    public void onReceivedError(WebView view, int errorCode, String description, String failingUrl) {
                        Toast.makeText(activity, description, Toast.LENGTH_SHORT).show();
                    }
                });

                mWebview .loadUrl(url);
                setContentView(mWebview );
    /*            try {
                    context.startActivity(intent);
                } catch (android.content.ActivityNotFoundException e) {
                    Logger.e(TAG, "No News activity found:" + e.getMessage(), e);
                }
        */    } catch (JSONException jsone) {
                Logger.e(TAG, "Failed to parse JSON get news message", jsone);
            }
        } else {
            Log.e(TAG, "No address for get news action");
        }
    }

    @Override
    public void init(Context context, JSONObject jsonObject) {

    }

    @Override
    public void update(Context context, JSONObject jsonObject) {

    }

    @Override
    public boolean shouldDisplayNotification(Context context, NotificationDetails notificationDetails, Bundle bundle) {
        return true;
    }
}
