export XRAY_DATABASE="virtex7"
# Copyright (C) 2017-2020  The Project X-Ray Authors.
#
# Use of this source code is governed by a ISC-style
# license that can be found in the LICENSE file or at
# https://opensource.org/licenses/ISC
#
# SPDX-License-Identifier: ISC
export XRAY_PART="xc7vh870tflg1932-1"
export XRAY_ROI_FRAMES="0x00000000:0xffffffff"

# Note 1 : This part has 5 SLRs, SLR0 has GTZ_BOT, SLR1 SLR2 SLR3 have usual logic, SLR4 has GTZ_TOP
# Note 2 : SLR1 SLR2 SLR3 are visibly identical
# Note 3 : SLR1 SLR2 SLR3 also seem to be identical to SLR0 SLR1 of part xc7vh580t
# All CLB's in part, all BRAM's in part, all DSP's in part.
export XRAY_ROI_TILEGRID="SLICE_X0Y0:SLICE_X375Y449 RAMB18_X0Y0:RAMB18_X15Y179 RAMB36_X0Y0:RAMB36_X15Y89 DSP48_X0Y0:DSP48_X13Y179"

# Not bonded : All IOB of SLR1 and SLR2
export XRAY_EXCLUDE_ROI_TILEGRID="IOB_X0Y0:IOB_X1Y149 IOB_X0Y300:IOB_X1Y449"

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
