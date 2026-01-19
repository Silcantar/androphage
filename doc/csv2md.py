import sys
import pandas as pd
from tabulate import tabulate

try:
	print( sys.argv[1] )
	csvFile = sys.argv[1]
except:
	csvFile = 'table.csv'

try:
	mdFile = sys.argv[2]
except:
	mdFile = 'table.md'

try:
	delim = sys.argv[3]
except:
	delim = ','

# Load CSV file into DataFrame
df = pd.read_csv( csvFile )

with open( mdFile, 'a' ) as f:
	# Convert DataFrame to Markdown Table
	print( tabulate( df, tablefmt="pipe", headers="keys" ), file = f )