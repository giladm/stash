/*
 * Licensed Materials - Property of IBM
 *
 * 5725E28, 5725I03
 *
 * © Copyright IBM Corp. 2011, 2016
 * US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */
package com.ibm.mce.samples.gcm;


import android.annotation.TargetApi;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.content.Context;
import android.content.SharedPreferences;
import android.os.Build;
import android.util.Log;

import com.google.android.gms.gcm.GoogleCloudMessaging;
import com.ibm.mce.samples.gcm.layout.ResourcesHelper;
import com.ibm.mce.sdk.SdkPreferences;
import com.ibm.mce.sdk.api.MceApplication;
import com.ibm.mce.sdk.api.MceSdk;
import com.ibm.mce.sdk.api.notification.NotificationsPreference;
import com.ibm.mce.sdk.plugin.inapp.ImageTemplate;
import com.ibm.mce.sdk.plugin.inapp.InAppTemplateRegistry;
import com.ibm.mce.sdk.plugin.inapp.VideoTemplate;
import com.ibm.mce.sdk.plugin.inbox.HtmlRichContent;
import com.ibm.mce.sdk.plugin.inbox.PostMessageTemplate;
import com.ibm.mce.sdk.plugin.inbox.RichContentTemplateRegistry;
import com.ibm.mce.sdk.registration.RegistrationClientImpl;
import com.ibm.mce.sdk.session.SessionManager;
import com.ibm.mce.sdk.util.Logger;
// gm test
import java.util.Date;
import java.util.TimeZone;
import java.util.Locale ;

import static com.ibm.mce.sdk.session.SessionManager.*;

public class SampleApplication extends MceApplication {

    public static final String MCE_SAMPLE_NOTIFICATION_CHANNEL_ID = "mce_sample_channel";

    @Override
    public void onCreate() {
        super.onCreate();

        Log.d("VersionTest", "v = "+RegistrationClientImpl.getVersion(getApplicationContext()));
        Log.d("gilad","start  testTimezoneName");
         testTimezoneName();
        Log.d("gilad","after  testTimezoneName");
        ResourcesHelper resourcesHelper = new ResourcesHelper(getResources(), getPackageName());

        /**
         * Custom layout
         */

        MceSdk.getNotificationsClient().setCustomNotificationLayout(this,
                resourcesHelper.getString("expandable_layout_type"),
                resourcesHelper.getLayoutId("custom_notification"),
                resourcesHelper.getId("bigText"),
                resourcesHelper.getId("bigImage"), resourcesHelper.getId("action1"),
                resourcesHelper.getId("action2"),
                resourcesHelper.getId("action3"));

        MceSdk.getNotificationsClient().getNotificationsPreference().setSoundEnabled(getApplicationContext(), true);
        MceSdk.getNotificationsClient().getNotificationsPreference().setSound(getApplicationContext(), resourcesHelper.getRawId("notification_sound"));
        MceSdk.getNotificationsClient().getNotificationsPreference().setVibrateEnabled(getApplicationContext(), true);
        long[] vibrate = { 0, 100, 200, 300 };
        MceSdk.getNotificationsClient().getNotificationsPreference().setVibrationPattern(getApplicationContext(), vibrate);
        MceSdk.getNotificationsClient().getNotificationsPreference().setIcon(getApplicationContext(),resourcesHelper.getDrawableId("icon"));
        MceSdk.getNotificationsClient().getNotificationsPreference().setLightsEnabled(getApplicationContext(), true);
        int ledARGB = 0x00a2ff;
        int ledOnMS = 300;
        int ledOffMS = 1000;
        MceSdk.getNotificationsClient().getNotificationsPreference().setLights(getApplicationContext(), new int[]{ledARGB, ledOnMS, ledOffMS});

        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            createNotificationChannel(getApplicationContext());
        }


        if(SampleGcmBroadcastReceiver.SENDER_ID != null) {
            String registeredSenderId = getSharedPref(getApplicationContext()).getString("senderId", null);
            if(!SampleGcmBroadcastReceiver.SENDER_ID.equals(registeredSenderId)) {
                (new Thread(new Runnable() {
                    @Override
                    public void run() {
                        try {
                            GoogleCloudMessaging gcm = GoogleCloudMessaging.getInstance(getApplicationContext());
                            String regid = gcm.register(SampleGcmBroadcastReceiver.SENDER_ID);
                            Log.i(SampleGcmBroadcastReceiver.TAG, "GCM registration id: " + regid);
                            getEditor(getApplicationContext()).putString("senderId", SampleGcmBroadcastReceiver.SENDER_ID).commit();
                        } catch (Exception e) {
                            Log.e(SampleGcmBroadcastReceiver.TAG, "Failed to register GCM", e);
                        }
                    }
                })).start();
            }
        }
    }

    private static final String PREFS_NAME = "IBM_MCE_SAMPLE";

    private static SharedPreferences getSharedPref(Context context) {
        return context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);
    }

    private static SharedPreferences.Editor getEditor(Context context) {
        return getSharedPref(context).edit();
    }

    @TargetApi(26)
    private static void createNotificationChannel(Context context) {
        NotificationManager notificationManager =
                (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
        NotificationChannel channel = notificationManager.getNotificationChannel(MCE_SAMPLE_NOTIFICATION_CHANNEL_ID);
        if(channel == null) {
            CharSequence name = context.getString(R.string.notif_channel_name);
            String description = context.getString(R.string.notif_channel_description);
            int importance = NotificationManager.IMPORTANCE_HIGH;
            channel = new NotificationChannel(MCE_SAMPLE_NOTIFICATION_CHANNEL_ID, name, importance);
            channel.setDescription(description);
            NotificationsPreference notificationsPreference = MceSdk.getNotificationsClient().getNotificationsPreference();
            notificationsPreference.setNotificationChannelId(context, MCE_SAMPLE_NOTIFICATION_CHANNEL_ID);
            notificationManager.createNotificationChannel(channel);
        }
    }
    public void testTimezoneName() {
        // Try to iterate through all the locales and get short daylight timezone name
        Locale[] locales = Locale.getAvailableLocales();
        String[] timeZoneNames = TimeZone.getAvailableIDs();
//        String[] timeZoneNames = {"Asia/SomethingThatDoesntExist"};
        String currentTimezoneName = "empty";
        String currentLocaleName = "empty";
        Context context = getApplicationContext();
        Log.d("gilad","total locales:"+locales.length);
        Log.d("gilad","total timezoneNames:"+timeZoneNames.length);
        try {
            for (int i = 0; i < locales.length; i++) {
                Locale aLocale = locales[i];
                currentLocaleName = "" + aLocale;
                if ((i % 5) ==0)
                    Log.i("gilad locale:", currentLocaleName);

                for (int j = 0; j < timeZoneNames.length; j++) {
                    TimeZone timezone = TimeZone.getTimeZone(timeZoneNames[j]);
                    currentTimezoneName = "" + timeZoneNames[j];
                    synchronized (context) {
                        if ((j % 190) == 0)
                            Log.v("gilad timezone:", currentLocaleName);
                        testLocaleTimezone(aLocale, timezone,context);
                        //SessionManager.SessionState sessionState = SessionManager.getSessionState(context);
                        //Logger.d("gilad", "#"+i+" Session state [" + sessionState.getSessionStartDate() + " - " + sessionState.getSessionEndDate() + "]");
                    }

                    //                   Log.e("gilad", "Locale: " + aLocale + "TZ: " + timezone.getDisplayName(true, 0x00000000, aLocale));
                }
            }
        } catch (java.lang.AssertionError ex) {
            Log.e("AssertionError gilad", "timezone=" + currentTimezoneName + ", locale=" + currentLocaleName);
        }

    }


    public void testLocaleTimezone(Locale locale, TimeZone timezone,Context context) {
        String storedNameShortDaylight = timezone.getDisplayName(true, 0x00000000, locale);
        String storedNameShortStandard = timezone.getDisplayName(false, 0x00000000, locale);
        String storedNameLongDaylight = timezone.getDisplayName(true, 0x00000001, locale);
        String storedNameLongStandard = timezone.getDisplayName(false, 0x00000001, locale);
        String concatinateString =storedNameLongDaylight+storedNameLongStandard+storedNameShortDaylight+storedNameShortStandard ;
        if (concatinateString.length() > 500) {
            Log.d("gilad concatinateString", concatinateString);
        }
        //        Log.i("gilad", storedNameShortDaylight + " " +
//            storedNameShortStandard + " "  +
//            storedNameLongDaylight + " " +
//            storedNameLongStandard);
        Date sessionStartTime = SdkPreferences.getSessionStarTime(context);
        Date sessionEndTime = null;
        if(sessionStartTime != null) {
            //Logger.d("gilad", "Found session start: "+sessionStartTime);
            Date lastPauseTime = SdkPreferences.getLastPauseTime(context);
            if (lastPauseTime != null) {
                //Logger.d("gilad", "App in background since: "+lastPauseTime);
                if(SdkPreferences.isSessionTrackingEnabled(context)) {
                    Date now = new Date();
                    if (now.getTime() - lastPauseTime.getTime() > SdkPreferences.getSessionDuration(context)) {
                       // Logger.d("gilad", "Session timed out");
                        sessionEndTime = lastPauseTime;
                    }
                } else {
                    sessionEndTime = lastPauseTime;
                }
            }else if(!SdkPreferences.isSessionTrackingEnabled(context)) {
                sessionEndTime = new Date();
            }
        }
        Logger.v("gilad", String.valueOf(new SessionState(sessionStartTime, sessionEndTime)));
    }
}
