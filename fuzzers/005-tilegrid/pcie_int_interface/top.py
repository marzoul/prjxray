#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# Copyright (C) 2017-2020  The Project X-Ray Authors.
#
# Use of this source code is governed by a ISC-style
# license that can be found in the LICENSE file or at
# https://opensource.org/licenses/ISC
#
# SPDX-License-Identifier: ISC
import os
import re
import random
random.seed(int(os.getenv("SEED"), 16))
from prjxray import util
from prjxray.db import Database
from prjxray.grid_types import GridLoc

GTP_INT_Y_RE = re.compile("PCIE_INT_INTERFACE.*X[0-9]+Y([0-9]+)")


def get_pcie_int_tiles(grid, pcie_loc):
    def get_site_at_loc(loc):
        gridinfo = grid.gridinfo_at_loc(loc)

        sites = list(gridinfo.sites.keys())

        if len(sites) and sites[0].startswith("SLICE"):
            return sites[0]

        return None

    # Keep the PCIE_INT_INTERFACE tiles that have the LOC closest possible to desired pcie_loc
    # (lowest possible while still higher than pcie_loc.y)
    keep_left_loc_y = None
    keep_left_tile_name = None
    keep_left_site = None

    keep_right_loc_y = None
    keep_right_tile_name = None
    keep_right_site = None

    for tile_name in sorted(grid.tiles()):
        if not tile_name.startswith("PCIE_INT_INTERFACE"):
            continue

        m = GTP_INT_Y_RE.match(tile_name)
        assert m

        int_y = int(m.group(1))
        if int_y % 50 != 0:
            continue

        loc = grid.loc_of_tilename(tile_name)
        if loc.grid_y < pcie_loc.grid_y:
            continue

        is_left = loc.grid_x < pcie_loc.grid_x
        if is_left:

            if keep_left_site:
                if loc.grid_y > keep_left_loc_y:
                    continue
            keep_left_loc_y = loc.grid_y
            keep_left_tile_name = tile_name

            for i in range(1, loc.grid_x):
                loc_grid_x = loc.grid_x - i

                site = get_site_at_loc(GridLoc(loc_grid_x, loc.grid_y))

                if site:
                    keep_left_site = site
                    break

        else:

            if keep_right_site:
                if loc.grid_y > keep_right_loc_y:
                    continue

            keep_right_loc_y = loc.grid_y
            keep_right_tile_name = tile_name

            _, x_max, _, _ = grid.dims()
            for i in range(1, x_max - loc.grid_x):
                loc_grid_x = loc.grid_x + i

                site = get_site_at_loc(GridLoc(loc_grid_x, loc.grid_y))

                if site:
                    keep_right_site = site
                    break

    assert keep_left_site and keep_right_site

    pcie_int_tiles = list()
    pcie_int_tiles.append((keep_left_tile_name, True, keep_left_site))
    pcie_int_tiles.append((keep_right_tile_name, False, keep_right_site))

    return pcie_int_tiles


def gen_sites():
    db = Database(util.get_db_root(), util.get_part())
    grid = db.grid()
    for tile_name in sorted(grid.tiles()):
        loc = grid.loc_of_tilename(tile_name)
        gridinfo = grid.gridinfo_at_loc(loc)

        for site_name, site_type in gridinfo.sites.items():
            if site_type in ['PCIE_2_1']:
                pcie_int_tiles = get_pcie_int_tiles(grid, loc)

                yield pcie_int_tiles, site_name


def write_params(params):
    pinstr = 'tile,val,site\n'
    for tile, (site, val) in sorted(params.items()):
        pinstr += '%s,%s,%s\n' % (tile, val, site)
    open('params.csv', 'w').write(pinstr)


def run():
    print('''
module top();
    ''')

    params = {}

    sites = list(gen_sites())
    for pcie_int_tiles, site_name in sites:
        left_side = None
        right_side = None

        for tile, is_left, site in pcie_int_tiles:
            isone = random.randint(0, 1)
            params[tile] = (site_name, isone)

            if is_left:
                left_side = site
            else:
                right_side = site

        assert left_side and right_side

        print(
            '''
wire [1:0] PLDIRECTEDLINKCHANGE_{site};
wire [68:0] MIMTXRDATA_{site};

(* KEEP, DONT_TOUCH, LOC = "{left}" *)
LUT1 left_lut_{left} (.O(MIMTXRDATA_{site}[0]));

(* KEEP, DONT_TOUCH, LOC = "{right}" *)
LUT1 right_lut_{right} (.O(PLDIRECTEDLINKCHANGE_{site}[0]));

(* KEEP, DONT_TOUCH, LOC = "{site}" *)
PCIE_2_1 {site} (
    .PLDIRECTEDLINKCHANGE(PLDIRECTEDLINKCHANGE_{site}),
    .MIMTXRDATA(MIMTXRDATA_{site})
);'''.format(site=site_name, right=right_side, left=left_side))

    print("endmodule")
    write_params(params)


if __name__ == '__main__':
    run()
