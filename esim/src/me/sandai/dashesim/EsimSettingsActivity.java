// Copyright (C) 2026 YorokobiMaster
// SPDX-License-Identifier: Apache-2.0

package me.sandai.dashesim;

import android.content.ActivityNotFoundException;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.telephony.TelephonyManager;
import android.telephony.euicc.EuiccManager;
import android.util.Log;
import android.widget.Toast;

import androidx.appcompat.app.AlertDialog;
import androidx.preference.Preference;

import com.android.settingslib.collapsingtoolbar.CollapsingToolbarBaseActivity;
import com.android.settingslib.widget.MainSwitchPreference;
import com.android.settingslib.widget.SettingsBasePreferenceFragment;

public final class EsimSettingsActivity extends CollapsingToolbarBaseActivity {
    @Override
    protected void onCreate(Bundle state) {
        super.onCreate(state);
        if (!EsimController.isSupported(this)) {
            finish();
            return;
        }
        if (state == null) {
            getSupportFragmentManager().beginTransaction().replace(
                    com.android.settingslib.collapsingtoolbar.R.id.content_frame,
                    new EsimFragment()).commit();
        }
    }

    public static final class EsimFragment extends SettingsBasePreferenceFragment {
        private MainSwitchPreference mSwitch;
        private Preference mManage;
        private Preference mStatus;
        private boolean mBusy;
        private final BroadcastReceiver mSlotReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                if (!mBusy) refresh();
            }
        };

        @Override
        public void onCreatePreferences(Bundle state, String key) {
            setPreferencesFromResource(R.xml.esim_settings, key);
            mSwitch = findPreference("enabled");
            mManage = findPreference("manage");
            mStatus = findPreference("status");
            mSwitch.setOnPreferenceChangeListener((preference, value) -> {
                boolean enabled = (Boolean) value;
                if (!enabled && EsimController.hasActiveProfile(requireContext())) {
                    new AlertDialog.Builder(requireContext())
                            .setTitle(R.string.active_title)
                            .setMessage(R.string.active_message)
                            .setPositiveButton(android.R.string.ok, null).show();
                    return false;
                }
                switchMode(enabled);
                return false; // Only reflect the new state after the modem confirms it.
            });
            mManage.setOnPreferenceClickListener(preference -> {
                try {
                    startActivity(new Intent(EuiccManager.ACTION_MANAGE_EMBEDDED_SUBSCRIPTIONS));
                } catch (ActivityNotFoundException e) {
                    Toast.makeText(requireContext(), R.string.lpa_unavailable, Toast.LENGTH_LONG).show();
                }
                return true;
            });
            findPreference("refresh").setOnPreferenceClickListener(preference -> {
                refresh();
                return true;
            });
        }

        @Override
        public void onResume() {
            super.onResume();
            requireContext().registerReceiver(mSlotReceiver,
                    new IntentFilter(TelephonyManager.ACTION_SIM_SLOT_STATUS_CHANGED),
                    Context.RECEIVER_EXPORTED);
            if (!mBusy) refresh();
        }

        @Override
        public void onPause() {
            requireContext().unregisterReceiver(mSlotReceiver);
            super.onPause();
        }

        private void refresh() {
            Boolean enabled;
            try {
                enabled = EsimController.getEnabled(requireContext());
            } catch (RuntimeException e) {
                Log.e("DashEsim", "Cannot read modem slot state", e);
                enabled = null;
            }
            mSwitch.setEnabled(enabled != null && !mBusy);
            if (enabled != null) mSwitch.setChecked(enabled);
            mManage.setEnabled(Boolean.TRUE.equals(enabled) && !mBusy);
            mStatus.setSummary(enabled == null ? R.string.state_unavailable
                    : enabled ? R.string.state_enabled : R.string.state_disabled);
        }

        private void switchMode(boolean enabled) {
            mBusy = true;
            mSwitch.setEnabled(false);
            mManage.setEnabled(false);
            mStatus.setSummary(R.string.switching);
            Context context = requireContext().getApplicationContext();
            EsimController.WORKER.execute(() -> {
                boolean success;
                try {
                    EsimController.setEnabled(context, enabled);
                    success = true;
                } catch (Exception e) {
                    Log.e("DashEsim", "Modem switch failed", e);
                    success = false;
                }
                final boolean completed = success;
                android.app.Activity activity = getActivity();
                if (activity == null) return;
                activity.runOnUiThread(() -> {
                    if (!isAdded()) return;
                    mBusy = false;
                    refresh();
                    if (!completed) {
                        Toast.makeText(requireContext(), R.string.switch_failed, Toast.LENGTH_LONG).show();
                    }
                });
            });
        }
    }
}
