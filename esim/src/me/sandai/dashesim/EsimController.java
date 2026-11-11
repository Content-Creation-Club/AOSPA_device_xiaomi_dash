// Copyright (C) 2026 YorokobiMaster
// SPDX-License-Identifier: Apache-2.0

package me.sandai.dashesim;

import android.content.Context;
import android.content.pm.PackageManager;
import android.os.SystemClock;
import android.os.SystemProperties;
import android.telephony.SubscriptionInfo;
import android.telephony.SubscriptionManager;
import android.telephony.TelephonyManager;
import android.telephony.UiccSlotInfo;

import java.io.IOException;
import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

final class EsimController {
    static final ExecutorService WORKER = Executors.newSingleThreadExecutor();

    static boolean isSupported(Context context) {
        String model = SystemProperties.get("ro.product.odm.model", "");
        return (model.equals("2602BPC18G") || model.equals("2602BPC18I"))
                && context.getPackageManager().hasSystemFeature(
                        PackageManager.FEATURE_TELEPHONY_EUICC);
    }

    // Read the HAL-backed slot directly. null is unavailable, not "disabled".
    static Boolean getEnabled(Context context) {
        TelephonyManager manager = context.getSystemService(TelephonyManager.class);
        UiccSlotInfo[] slots = manager.getUiccSlotsInfo();
        if (slots == null || slots.length <= 1 || slots[1] == null) return null;
        if (slots[1].getCardStateInfo() == UiccSlotInfo.CARD_STATE_INFO_ERROR) return null;
        return slots[1].getIsEuicc();
    }

    static boolean hasActiveProfile(Context context) {
        List<SubscriptionInfo> subscriptions = context.getSystemService(SubscriptionManager.class)
                .getActiveSubscriptionInfoList();
        if (subscriptions == null) return false;
        for (SubscriptionInfo subscription : subscriptions) {
            if (subscription.isEmbedded()) return true;
        }
        return false;
    }

    static void setEnabled(Context context, boolean enabled) throws IOException {
        if (!isSupported(context)) throw new IOException("Unsupported hardware");
        if (!enabled && hasActiveProfile(context)) throw new IOException("Active eSIM profile");
        String token = Long.toString(SystemClock.elapsedRealtimeNanos());
        SystemProperties.set("sys.dash.esim.request", token + (enabled ? ":enable" : ":disable"));
        long deadline = SystemClock.elapsedRealtime() + 30_000;
        boolean acknowledged = false;
        while (SystemClock.elapsedRealtime() < deadline) {
            String response = SystemProperties.get("sys.dash.esim.response", "");
            if (response.startsWith(token + ":")) {
                if (!response.equals(token + ":done")) throw new IOException("Modem command failed");
                acknowledged = true;
            }
            if (acknowledged && Boolean.valueOf(enabled).equals(getEnabled(context))) return;
            SystemClock.sleep(200);
        }
        throw new IOException("Timed out waiting for modem slot update");
    }

    private EsimController() {}
}
