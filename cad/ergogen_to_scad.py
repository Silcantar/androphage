'''A Python script to convert an Ergogen YAML file to a series of OpenSCAD
variable declarations.
'''

import argparse
import sys
import yaml

parser = argparse.ArgumentParser()
parser.add_argument('-i', '--inputfile', default='ergogen.yaml', required=False)
parser.add_argument('-o', '--outputfile', default='ergogen.scad', required=False)
parser.add_argument('-v', '--verbose', action='store_true')
args = parser.parse_args()

column_properties = ['origin', 'splay', 'stagger']

with open(args.inputfile) as yf:
    eg = yaml.safe_load(yf)

with open(args.outputfile, 'w') as sf:
    for unit in eg['units']:
        sf.write(f'{unit} = {eg['units'][unit]};\n')
    zones = eg['points']['zones']
    for zone in zones:
        if len(zones) > 1:
            zone_name = f'{zone}_'
        else:
            zone_name = ''
        default_row_count = 1
        try:
            default_row_count = len(zones[zone]['rows'])
            sf.write(f'{zone_name}rowcount = {default_row_count};\n')
        except KeyError:
            pass
        try:
            columns = zones[zone]['columns']
        except KeyError:
            if args.verbose: print('Warning: No columns specified in this zone.')
            continue
        for column in columns:
            try:
                sf.write(f'{zone_name}{column}_rowcount = {len(columns[column]['rows'])};\n')
            except (KeyError, TypeError):
                if args.verbose: print(f'Info: No rows specified for column {column}. Using the default ({default_row_count}) for this zone.')
                sf.write(f'{zone_name}{column}_rowcount = {default_row_count};\n')
            try:
                props = list(columns[column]['key'] | column_properties)
                for prop in props:
                    if isinstance(props[prop], list):
                        sf.write(f'{zone_name}{column}_{prop} = [{', '.join(map(str, props[prop]))}];\n')
                    else:
                        sf.write(f'{zone_name}{column}_{prop} = {props[prop]};\n')
            except (KeyError, TypeError):
                pass
