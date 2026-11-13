/* Copyright (C) 2026 YorokobiMaster
 * SPDX-License-Identifier: Apache-2.0
 */
package me.sandai.wake;

import android.app.ActivityManager;
import android.content.ContentResolver;
import android.content.Context;
import android.database.ContentObserver;
import android.os.Handler;
import android.os.UserHandle;
import android.provider.Settings;
import android.util.Slog;

import com.android.internal.os.BackgroundThread;
import com.android.server.SystemService;

/** Maps PA's gesture policy to the setting consumed by the shared DashWake driver bridge. */
public final class GestureSettingsService extends SystemService {
    private static final String TAG = "GestureSettings";
    private final ContentResolver resolver;
    private final Handler worker = BackgroundThread.getHandler();
    private final int doubleTapDefault;
    private int currentUser;

    public GestureSettingsService(Context context) {
        super(context);
        resolver = context.getContentResolver();
        doubleTapDefault = context.getResources().getInteger(
                com.android.internal.R.integer.config_doubleTapDefault);
    }

    @Override
    public void onStart() {
        ContentObserver observer = new ContentObserver(worker) {
            @Override
            public void onChange(boolean selfChange) {
                sync();
            }
        };
        resolver.registerContentObserver(Settings.System.getUriFor(
                Settings.System.GESTURES_ENABLED), false, observer, UserHandle.USER_ALL);
        resolver.registerContentObserver(Settings.System.getUriFor(
                Settings.System.GESTURE_DOUBLE_TAP), false, observer, UserHandle.USER_ALL);
        switchUser(ActivityManager.getCurrentUser());
    }

    @Override
    public void onUserSwitching(TargetUser from, TargetUser to) {
        switchUser(to.getUserIdentifier());
    }

    private void switchUser(int userId) {
        worker.post(() -> {
            currentUser = userId;
            sync();
        });
    }

    private void sync() {
        boolean gesturesEnabled = Settings.System.getIntForUser(resolver,
                Settings.System.GESTURES_ENABLED, 1, currentUser) != 0;
        int doubleTapAction = Settings.System.getIntForUser(resolver,
                Settings.System.GESTURE_DOUBLE_TAP, doubleTapDefault, currentUser);
        // Every enabled PA action needs double-tap events, including non-wake actions.
        int enabled = gesturesEnabled && doubleTapAction > 0 ? 1 : 0;
        if (Settings.Secure.getIntForUser(resolver,
                Settings.Secure.DOUBLE_TAP_TO_WAKE, -1, currentUser) == enabled) return;
        if (Settings.Secure.putIntForUser(resolver,
                Settings.Secure.DOUBLE_TAP_TO_WAKE, enabled, currentUser)) {
            Slog.i(TAG, "user=" + currentUser + " doubleTap=" + enabled);
        } else {
            Slog.e(TAG, "Cannot synchronize double-tap setting for user=" + currentUser);
        }
    }
}
