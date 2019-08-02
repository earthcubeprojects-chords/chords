import warnings
warnings.simplefilter("ignore")
import os
import pyart
import matplotlib.pyplot
import matplotlib as mpl
import numpy as np
import gzip
import shutil
import xarray as xr
from funcs import read_casa_netcdf
import json
import pandas as pd
# import gyzip

#import gridded netcdf data from a file
grid_file = '/netcdf_data/xmdl_grid.nc'

#read netcdf data
grid = pyart.io.grid_io.read_grid('/netcdf_data/xmdl_grid.nc')

#open dataset within gridded file
dataset = xr.open_dataset(grid_file)

#set the list of all the variables in the dataset to another variable
variables = list(dataset.variables)

#get the longitude, latitude and horizontal reflectivity of the data into variables
lats = grid.point_latitude['data']
lons = grid.point_longitude['data']
zh = grid.fields['Reflectivity']['data']
# time = grid.variables['units']

#create empty arrays for holding the latitude, longitude, reflectivity and timestamp data
latitude = []
longitude = []
reflectivity = []
times = []

# print(variables)
# print(grid.origin_longitude['data'][0])

#Create an array with all of the data in a stacked format compatible with converting to JSON
latLonRefArray = np.stack([lats.ravel(), lons.ravel(), zh.ravel()], axis = 1)

# arrangedArray = pd.DataFrame(latLonRefArray, columns=['latitude', 'longitude', 'zh'])
# arrangedArray= arrangedArray.dropna()

# print(latLonRefArray)

# print(lats)
# print(lons)
#


# f = open("jsonVersionTest.json", "w+")

#create an object of all of the data and save it to a variable called results
results = {"outputData": latLonRefArray.tolist()}

#format the data with indentation
json_string = json.dumps(results, indent=2)

#encode the json string into utf-8 format
json_bytes = json_string.encode('utf-8')

# json_string = json.dumps(results, indent=2)
# f.write(json_string)
# with gzip.open("outputTest.json", 'w+') as fout:
#     # json_string = json.dumps(results, indent=2)
#     fout.write(json_string)

#write the resulting JSON to a zipped file
with gzip.GzipFile("nextTest.json.gz", 'w') as fout:
    fout.write(json_bytes)


