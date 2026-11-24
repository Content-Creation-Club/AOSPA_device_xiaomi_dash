/*
 * Copyright (C) 2026 YorokobiMaster
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#include "FastChargeService.h"

int main() {
  return dash::runFastChargeService("vendor.lineage.health.IFastCharge/default",
                                    "/data/misc/dash-health", "fast-charge");
}
