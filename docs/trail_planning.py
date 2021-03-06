#!/usr/bin/env python

import json

map_size = (2732.0, 2049.0)
aspect_ratio = 16.0 / 9.0
h = map_size[0] / aspect_ratio
ymin = (map_size[1] - h) / 2.0
ymax = ymin + h

point_count = 12
points = [
    (330, 515), # start
    (460, 600), # control point 1
    (400, 690), # control point 2
    (290, 780), # 1
    (118, 930), # control point 1
    (100, 1032), # control point 2
    (95, 1081), # 2
    (120, 1328), # control point 1
    (213, 977), # control point 2
    (633, 1313), # 3
    (951, 1570), # control point 1
    (274, 1283), # control point 2
    (409, 1446), # 4
    (512, 1654), # control point 1
    (655, 1643), # control point 2
    (915, 1391), # 5
    (1212, 1265), # control point 1
    (1233, 1234), # control point 2
    (1100, 1133), # 6
    (1146, 930), # control point 1
    (1452, 708), # control point 2
    (1598, 1000), # 7
    (1735, 653), # control point 1
    (1947, 585), # control point 2
    (2056, 808), # 8
    (1623, 655), # control point 1
    (1757, 1227), # control point 2
    (2042, 958), # 9
    (2063, 1151), # control point 1
    (1979, 1260), # control point 2
    (1781, 1312), # 10
    (1519, 1358), # control point 1
    (1951, 1588), # control point 2
    (2318, 1470), # treasure
]

level_names = [
    '0_setting_sail', '1_sea_legs', '2_pegleg_plunder', '3_cutlass_careen',
    '4_fire_in_the_hole', '5_dead_men_tell_no_tales', '6_davy_jones_locker',
    '7_letter_of_marque', '8_give_no_quarter', '9_boom_about', '10_high_seas',
    '11_shiver_me_timbers',
]

def convert_x(x):
    return x / map_size[0]

def convert_y(y):
    return 1 - (y - ymin) / h

def point_to_dict(point):
    return {
        'x': convert_x(point[0]),
        'y': convert_y(point[1]),
    }

def path_to_dict():
    path = {}
    path['startPoint'] = {
        'levelNamed': level_names[0],
        'target': point_to_dict(points[0])
    }

    pointSets = []
    for i in range(1, point_count):
        pointSet = {
            'levelNamed': level_names[i],
            'target': point_to_dict(points[3 * i]),
            'controlPoint1': point_to_dict(points[3 * i - 2]),
            'controlPoint2': point_to_dict(points[3 * i - 1]),
        }
        pointSets.append(pointSet)
    path['points'] = pointSets

    return path

if __name__ == "__main__":
    path = path_to_dict()
    print(json.dumps(path))
