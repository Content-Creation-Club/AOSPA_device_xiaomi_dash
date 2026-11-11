# Copyright (C) 2026 YorokobiMaster
# SPDX-License-Identifier: Apache-2.0

# Keep the stock 305 allocation, compression codec, and module load order.
BOARD_SYSTEM_DLKMIMAGE_PARTITION_SIZE := 7323648
BOARD_SYSTEM_DLKMIMAGE_EROFS_COMPRESSOR := lz4hc,level=12
BOARD_SYSTEM_DLKMIMAGE_EROFS_PCLUSTER_SIZE := 16384

# Custom profiles use one signed core build. Official GKI uses its signed
# modules plus the audited local TLS module (not trusted by the official key).
# The native SYSTEM module install rule does not strip.
BOARD_SYSTEM_KERNEL_MODULES_LOAD := $(strip $(file <$(DEVICE_PATH)/kernel/modules.load.system_dlkm))
BOARD_SYSTEM_KERNEL_MODULES := $(addprefix $(DASH_GKI_CORE_OUT)/,$(BOARD_SYSTEM_KERNEL_MODULES_LOAD))
