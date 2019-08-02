# Data Topics

## Rendering GeoTIFF in Leaflet

This is done using the Leaflet ImageOverlay layer. We could use ImageOverlay directly,
but there is (are?) readymade extensions that provide enhanced _GeoTIFF_
functions.

[leaflet-geotiff](https://github.com/stuartmatthews/leaflet-geotiff) looks like the right choice for displaying _geoTIFF_.
Just have the leaflet web page JavaScript specify the desired file on the server,
and it will fetch the file and display it. The github project provides a simple example on how to use it.

## Converting netCDF gridded files to raster files

_Note:_ Instructions are given her for embedding a color table in the
_GeoTIFF_ file. However, this is not mandatory, and may not be desirable.
The _leaflet-geotiff_ plugin (above) allows you to dynamically specify a color
table.

_GeoTIFF_ is an appropriate raster input for imagery, since it carries along navigation information.

A netCDF file containing gridded radar data can easily be converted to _GeoTIFF_ using the GDAL tools.

[GDAL](https://gdal.org/index.html) is a set of valuable Open Source GIS tools.
We mainly will use two tools: [gdal_translate](https://gdal.org/programs/gdal_translate.html)
and [gdaldem](https://gdal.org/programs/gdaldem.html).

To install GDAL on MacOS  
(it may ask you to install X-Code; just follow those instructions):
```
brew install gdal
```

Convert the gridded _netCDF_ file to _GeoTIFF_:
```
gdal_translate -of GTiff  netCDF:"xmdl_grid.nc":Reflectivity xmdl_grid.tif
Input file size is 1600, 1600
0...10...20...30...40...50...60...70...80...90...100 - done.
```

Add a color table to the geotiff file. You provide the color table in the form
of a CSV file (see https://khufkens.com/2016/03/09/map-colours-onto-data-values-in-gdal/)
```
gdaldem color-relief xmdl_grid.tif color_table.csv xmdl_grid_colors.tif 
0...10...20...30...40...50...60...70...80...90...100 - done.
```

Double-click on the _GeoTIFF_ files,and you will see nice radar images! The first will be greyscale,
since it has no color table.

_Extra Credit:_

Much like _ncdump -h_, _gdalinfo_ provides summary information about a _netCDF_ file:
```
gdalinfo netCDF:xmdl_grid.nc                                    
Driver: netCDF/Network Common Data Format
Files: none associated
Size is 512, 512
Coordinate System is `'
Metadata:
  NC_GLOBAL#comment=
  NC_GLOBAL#Conventions=CF/Radial instrument_parameters
  NC_GLOBAL#field_names=Reflectivity, Velocity, SpectralWidth, DifferentialReflectivity, DifferentialPhase, CrossPolCorrelation, NormalizedCoherentPower, SpecificPhase, CorrectedReflectivity, CorrectedDifferentialReflectivity, SignalToNoiseRatio, RainfallRate, HVReflectivity
  NC_GLOBAL#history=
  NC_GLOBAL#institution=
  NC_GLOBAL#instrument_name=
  NC_GLOBAL#instrument_type=radar
  NC_GLOBAL#platform_type=fixed
  NC_GLOBAL#primary_axis=axis_z
  NC_GLOBAL#references=
  NC_GLOBAL#source=
  NC_GLOBAL#title=
  NC_GLOBAL#version=1.3
  NC_GLOBAL#volume_number=0
Subdatasets:
  SUBDATASET_1_NAME=NETCDF:"xmdl_grid.nc":radar_name
  SUBDATASET_1_DESC=[1x1] radar_name (8-bit character)
  SUBDATASET_2_NAME=NETCDF:"xmdl_grid.nc":point_latitude
  SUBDATASET_2_DESC=[1x1600x1600] point_latitude (64-bit floating-point)
  SUBDATASET_3_NAME=NETCDF:"xmdl_grid.nc":point_longitude
  SUBDATASET_3_DESC=[1x1600x1600] point_longitude (64-bit floating-point)
  SUBDATASET_4_NAME=NETCDF:"xmdl_grid.nc":point_altitude
  SUBDATASET_4_DESC=[1x1600x1600] point_altitude (64-bit floating-point)
  SUBDATASET_5_NAME=NETCDF:"xmdl_grid.nc":Reflectivity
  SUBDATASET_5_DESC=[1x1x1600x1600] Reflectivity (32-bit floating-point)
  SUBDATASET_6_NAME=NETCDF:"xmdl_grid.nc":SignalToNoiseRatio
  SUBDATASET_6_DESC=[1x1x1600x1600] SignalToNoiseRatio (32-bit floating-point)
  SUBDATASET_7_NAME=NETCDF:"xmdl_grid.nc":ROI
  SUBDATASET_7_DESC=[1x1x1600x1600] radius_of_influence (32-bit floating-point)
Corner Coordinates:
Upper Left  (    0.0,    0.0)
Lower Left  (    0.0,  512.0)
Upper Right (  512.0,    0.0)
Lower Right (  512.0,  512.0)
Center      (  256.0,  256.0)
```

Notice the "subdatasets", which correspond to _netcdf_ variables. You can also examine these subsets using
_gdalinfo_:

```
gdalinfo netCDF:"xmdl_grid.nc":Reflectivity
Driver: netCDF/Network Common Data Format
Files: xmdl_grid.nc
Size is 1600, 1600
Coordinate System is `'
Origin = (-41025.641025641023589,41025.641025641023589)
Pixel Size = (51.282051282051285,-51.282051282051285)
Metadata:
  NC_GLOBAL#comment=
  NC_GLOBAL#Conventions=CF/Radial instrument_parameters
  NC_GLOBAL#field_names=Reflectivity, Velocity, SpectralWidth, DifferentialReflectivity, DifferentialPhase, CrossPolCorrelation, NormalizedCoherentPower, SpecificPhase, CorrectedReflectivity, CorrectedDifferentialReflectivity, SignalToNoiseRatio, RainfallRate, HVReflectivity
  NC_GLOBAL#history=
  NC_GLOBAL#institution=
  NC_GLOBAL#instrument_name=
  NC_GLOBAL#instrument_type=radar
  NC_GLOBAL#platform_type=fixed
  NC_GLOBAL#primary_axis=axis_z
  NC_GLOBAL#references=
  NC_GLOBAL#source=
  NC_GLOBAL#title=
  NC_GLOBAL#version=1.3
  NC_GLOBAL#volume_number=0
  NETCDF_DIM_EXTRA={time,z}
  NETCDF_DIM_time_DEF={1,6}
  NETCDF_DIM_time_VALUES=0
  NETCDF_DIM_z_DEF={1,6}
  NETCDF_DIM_z_VALUES=501
  Reflectivity#Units=dBz
  time#calendar=gregorian
  time#long_name=Time of grid
  time#standard_name=time
  time#units=seconds since 2016-07-27T22:32:25Z
  x#axis=X
  x#long_name=X distance on the projection plane from the origin
  x#standard_name=projection_x_coordinate
  x#units=m
  y#axis=Y
  y#long_name=Y distance on the projection plane from the origin
  y#standard_name=projection_y_coordinate
  y#units=m
  z#axis=Z
  z#long_name=Z distance on the projection plane from the origin
  z#positive=up
  z#standard_name=projection_z_coordinate
  z#units=m
Corner Coordinates:
Upper Left  (  -41025.641,   41025.641) 
Lower Left  (  -41025.641,  -41025.641) 
Upper Right (   41025.641,   41025.641) 
Lower Right (   41025.641,  -41025.641) 
Center      (   0.0000000,  -0.0000000) 
Band 1 Block=1600x1 Type=Float32, ColorInterp=Undefined
  NoData Value=9.96920996838686905e+36
  Unit Type: dBz
  Metadata:
    NETCDF_DIM_time=0
    NETCDF_DIM_z=501
    NETCDF_VARNAME=Reflectivity
    Units=dBz
```

