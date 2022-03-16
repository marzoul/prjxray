export XRAY_DATABASE="virtex7"
# Copyright (C) 2017-2020  The Project X-Ray Authors.
#
# Use of this source code is governed by a ISC-style
# license that can be found in the LICENSE file or at
# https://opensource.org/licenses/ISC
#
# SPDX-License-Identifier: ISC
export XRAY_PART="xc7vx1140tflg1930-1"
export XRAY_ROI_FRAMES="0x00000000:0xffffffff"

# Note : This part has 4 SLRs
# All CLB's in part, all BRAM's in part, all DSP's in part.
export XRAY_ROI_TILEGRID="SLICE_X0Y0:SLICE_X375Y599 RAMB18_X0Y0:RAMB18_X15Y239 RAMB36_X0Y0:RAMB36_X15Y119 DSP48_X0Y0:DSP48_X13Y239"

# Not bonded
export XRAY_EXCLUDE_ROI_TILEGRID="IOB_X1Y500:IOB_X1Y599"

# This is used by fuzzers/005-tilegrid/generate_full.py
# (special handling for frame addresses of certain IOIs -- see the script for details).
# This needs to be changed for any new device!
# If you have a FASM mismatch or unknown bits in IOIs, CHECK THIS FIRST.
export XRAY_IOI3_TILES=""

source $(dirname ${BASH_SOURCE[0]})/../utils/environment.sh

env=$(python3 ${XRAY_UTILS_DIR}/create_environment.py)
ENV_RET=$?
if [[ $ENV_RET != 0 ]] ; then
	return $ENV_RET
fi
eval $env
