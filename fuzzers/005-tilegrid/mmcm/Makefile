# Copyright (C) 2017-2020  The Project X-Ray Authors.
#
# Use of this source code is governed by a ISC-style
# license that can be found in the LICENSE file or at
# https://opensource.org/licenses/ISC
#
# SPDX-License-Identifier: ISC
N ?= 12
# Was expecting oneval 3, but bits might be inverted
# FIXME: dword
# Ex: 0002009D_029_15
GENERATE_ARGS?="--oneval 2 --design params.csv --dword 0 --auto-frame"
include ../fuzzaddr/common.mk
