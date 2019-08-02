"""
Script to go through a directory and convert CASA .nc files
to .png images where each channel in RGB corresponds to a 
different radar variable.

Currently very much in development. Need to choose directories
below carefully. For simplicity and testing I'm currently 
individually specifying folders (i.e. only training cases for
one class at a time)
"""
import glob
import gzip
import shutil
import os

import numpy as np
import matplotlib.pyplot as plt 

from tqdm import tqdm

# companion file holding useful functions
from funcs import read_casa_netcdf, impute_missing, scale

BASE_DIR = '/net/denali/storage2/radar2/people/rgooch/Research/2018-Manuscripts/'
DATA_DIR = 'convnet-radar-features/squall/data/train/stratiform'
READ_DIR = os.path.join(BASE_DIR,DATA_DIR)

SAVE_ENDPOINT = 'transfer-learning-strat-conv/data/train/stratiform'
SAVE_DIR = os.path.join(BASE_DIR,SAVE_ENDPOINT)
file_list = glob.glob(os.path.join(READ_DIR,'*.netcdf.gz'))
file_list = sorted(file_list)

print('Converting %d netcdf.gz files to png' % (len(file_list)))
print('-'*42)

# choose what fields we want to grid
fields_to_grid = ['Reflectivity','SpecificPhase','DifferentialReflectivity']

for nc_file in tqdm(file_list):
    # try: 
    # Unzip the file and return its name
    with gzip.open(nc_file, 'rb') as zipped_nc_file:
        with open('temp.nc', 'wb') as nc_file:
            shutil.copyfileobj(zipped_nc_file, nc_file)

    # pre-test: Want lowest elevation scan, if
    # not, we continue
    dset = Dataset('temp.nc')
    elev_mean = np.mean(dset.variables['Elevation'])
    if elev_mean > 1.:
        continue

    # Get pyart radar object
    radar = read_casa_netcdf('temp.nc')

    # Impute missing values, so that gridding function doesn't get borked
    for field in fields_to_grid:
        radar = impute_missing(radar,field)

    # Grid the data to Cartesian
    grid = pyart.map.grid_from_radars(
        (radar,),
        grid_shape = (1, 800, 800),
        grid_limits = ((501,1000), (-41000.0,41000.0), (-41000.0,41000.0)),
        fields=fields_to_grid
    )

    # --------------------------------------------------------------------------
    # copy the fields and process accordingly
    # this is a good candidate for another tools function
    zh_grid = deepcopy(grid.fields['Reflectivity']['data'])
    kdp_grid = deepcopy(grid.fields['SpecificPhase']['data'])
    zdr_grid = deepcopy(grid.fields['DifferentialReflectivity']['data'])

    # reflectivity sensible lower and upper bounds
    zh_grid[zh_grid < -24] = -24
    zh_grid[zh_grid > 64] = 64

    # Just clip kdp at 5 deg
    kdp_grid[kdp_grid > 5] = 5

    # looks best from subjective view, fungible
    zdr_grid[zdr_grid < -8] = -8
    zdr_grid[zdr_grid > 10] = 10
    # --------------------------------------------------------------------------

    # Smush the three channels together to form image
    grid_image = np.stack(
        [
            scale(zh_grid, [0,1])[0],
            scale(zdr_grid, [0,1])[0],
            scale(kdp_grid, [0,1])[0]
        ],
        axis=2
    )
    
    # generate and save image
    save_name = nc_file.replace('.netcdf.gz','.png')

    fig = plt.figure(figsize=(15,15))
    plt.imshow(grid_image, origin='lower') # may not have to call this?
    plt.imsave(os.path.join(SAVE_DIR,save_name), grid_image, origin='lower')

    plt.close()