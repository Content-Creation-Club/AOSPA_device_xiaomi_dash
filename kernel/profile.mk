# Copyright (C) 2026 YorokobiMaster
# SPDX-License-Identifier: Apache-2.0

DASH_KERNEL_PROFILE := $(if $(filter true,$(DASH_OFFICIAL_GKI)),official,$(if $(filter true,$(DASH_STRICT_GKI)),strict,normal))
DASH_SYSTEM_DLKM := $(if $(filter true,$(DASH_BUILD_SYSTEM_DLKM) $(DASH_STRICT_GKI) $(DASH_OFFICIAL_GKI)),true,false)
