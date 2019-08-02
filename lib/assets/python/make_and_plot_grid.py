"""
Script to go from CASA netCDF file containing weather radar data to a Cartesian
grid and plotted to PNG for ImageOverlay with CHORDS

Ryan Gooch
s.ryan.gooch@gmail.com
July 2019
"""

import sys
import warnings
warnings.simplefilter("ignore")

import pyart # for plotting radar data, handling the data itself



import matplotlib.pyplot as plt # plotting utility for this notebook
import matplotlib as mpl # handling plot parameters like fonts
import numpy as np # array data manipulation
plt.switch_backend('agg')
mpl.use('agg')

import colorcet as cc # perceptually uniform colormaps

from matplotlib.colors import LinearSegmentedColormap # to build colormaps

# Ryan's tools for custom CASA data reader and certain other data utilities
from tools.funcs import read_casa_netcdf, impute_missing, scale

# colormap convenience dictionary. the usage for this looks like;
#     cmap = cmap_dict['NWS Reflectivity']
# this allows a simple way to refer to saved colormaps after deciding which
# goes best with which variable
cmap_dict = {
    'NWS Reflectivity': pyart.graph.cm.NWSRef,
    'NWS Velocity': pyart.graph.cm.NWSVel,
    'NWS Spectrum Width': pyart.graph.cm.NWS_SPW,
    'Colorcet: Rainbow': LinearSegmentedColormap.from_list('cc', cc.rainbow_bgyrm_35_85_c71),
    'Colorcet: Diverging (coolwarm)': LinearSegmentedColormap.from_list('cc', cc.coolwarm),
    'Colorcet: Linear (bgyw)': LinearSegmentedColormap.from_list('cc', cc.bgyw),
    'Colorcet: Linear (bmy)': LinearSegmentedColormap.from_list('cc', cc.bmy),
    'Colorcet: Linear (fire)': LinearSegmentedColormap.from_list('cc', cc.fire)
}

#RED FLAG: Need to verify user input as actual netcdf input 
input = sys.argv[1]
if __name__ == "__main__":
    radar = read_casa_netcdf(input)
    # list of fields we want to grid
    fields_to_grid = ['Reflectivity', 'SignalToNoiseRatio'] # ,'SpecificPhase','CrossPolCorrelation','DifferentialReflectivity','NormalizedCoherentPower','SpectralWidth']

    # grid is not good at handling nans, or fill values. Impute here
    # there are lists of variable names in tools.funcs.impute_missing
    # if this doesn't work, it might be because the names are not in the 
    # list. In most cases, we want "minimum" impute, not "zero" (see code
    # in that function for more info)
    for field in fields_to_grid:
#         print(field)
        radar = impute_missing(radar,field)
#         print('')

    # polar -> cartesian gridding
    grid = pyart.map.grid_from_radars(
        (radar,),
        grid_shape = (1, 1600, 1600),
        grid_limits = ((501,1000), (-41000.0,41000.0), (-41000.0,41000.0)),
        fields = ['Reflectivity','SignalToNoiseRatio']
    )
    
    # if needed, print bounding box values for image overlay
    print(np.min(grid.point_latitude['data']))
    print(np.max(grid.point_latitude['data']))
    print(np.min(grid.point_longitude['data']))
    print(np.max(grid.point_longitude['data']))
    
    # some of this is circuitous and backwards, but it works. Refactor might save
    # a few lines of code and time
    # plot_field is the field we are plotting
    # snr_field is the field on which we are threshold filtering (to remove clutter)
    # nan_array is required because we want a 2-D output array and for some reason,
    # direct filtering in place was unraveling the array.
    plot_field = grid.fields['Reflectivity']['data'][0]
    snr_field = grid.fields['SignalToNoiseRatio']['data'][0]
    nan_array = np.empty(plot_field.shape)[:] = np.NaN
    
    # Filters plot field on snr_field, replacing low values with NaN
    plot_field_filtered = np.where(
        snr_field < 3,
        nan_array,
        plot_field
    )
    
    # make the plot
    
    # here's where we grab the colormap from above. This is also nice, I think,
    # because one day we want the user to be able to pull colormaps from a dropdown
    # box, and the dropdown box will have names like "NWS Ref", not "pyart.graph.cm.NWSRef"
    cmap = cmap_dict['NWS Reflectivity'] # pull desired colormap
    
    # Set up figure
    fig = plt.figure(figsize=(12,12))
    ax = fig.add_subplot(111)
    
    # imshow is an image plotting function in matplotlib, and the reason I'm using
    # it here is because pyart has a lot of boilerplte we don't need
    # the plot variable has overly circuitous nonsense because I wanted to make 
    # absolutely sure masked values translated to NaN. Also, notice
    # vmin, vmax, cmap are specified, which here are based on reflectivity,
    # but these should map to defaults for each field on their own
    ax.imshow(np.ma.masked_where(np.isnan(plot_field_filtered),plot_field_filtered), 
              origin='lower', cmap = cmap, vmin = -10, vmax = 70)
    plt.axis('off')

    randomName = sys.argv[2]	
    # nameImage = randomName + "cartesian_gridded_zh.png"
    plt.savefig(randomName, dpi=150, transparent=True)
    plt.close() # close plots to reduce memory footprint
