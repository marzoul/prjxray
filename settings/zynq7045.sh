# Copyright (C) 2017-2020  The Project X-Ray Authors.
#
# Use of this source code is governed by a ISC-style
# license that can be found in the LICENSE file or at
# https://opensource.org/licenses/ISC
#
# SPDX-License-Identifier: ISC
export XRAY_DATABASE="zynq7"
export XRAY_PART="xc7z045ffg900-1"
export XRAY_ROI_FRAMES="0x00000000:0xffffffff"

# All CLB's in part, all BRAM's in part, all DSP's in part.
export XRAY_ROI_TILEGRID=\
"SLICE_X0Y0:SLICE_X171Y349"\
"RAMB18_X0Y0:RAMB18_X8Y139"\
"RAMB36_X0Y0:RAMB36_X8Y69"\
"DSP48_X0Y0:DSP48_X6Y139"

export XRAY_EXCLUDE_ROI_TILEGRID=""

# This is used by fuzzers/005-tilegrid/generate_full.py
# (special handling for frame addresses of certain IOIs -- see the script for details).
# This needs to be changed for any new device!
# If you have a FASM mismatch or unknown bits in IOIs, CHECK THIS FIRST.
export XRAY_IOI3_TILES="LIOI3_X0Y9"

# Note : Actually unknown how to find this for a new part
export XRAY_PS7_INT="INT_L_X18Y300"

source $(dirname ${BASH_SOURCE[0]})/../utils/environment.sh

env=$(python3 ${XRAY_UTILS_DIR}/create_environment.py)
ENV_RET=$?
if [[ $ENV_RET != 0 ]] ; then
	return $ENV_RET
fi
eval $env
