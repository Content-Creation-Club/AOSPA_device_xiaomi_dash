# Copyright (C) 2026 YorokobiMaster
# SPDX-License-Identifier: Apache-2.0

# Keep the stock 305 allocation, compression codec, and module load order.
BOARD_SYSTEM_DLKMIMAGE_PARTITION_SIZE := 7323648
BOARD_SYSTEM_DLKMIMAGE_EROFS_COMPRESSOR := lz4hc,level=12
BOARD_SYSTEM_DLKMIMAGE_EROFS_PCLUSTER_SIZE := 16384
