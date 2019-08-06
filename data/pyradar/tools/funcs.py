import datetime

import numpy as np
import netCDF4

from pyart.config import FileMetadata, get_fillvalue
from pyart.io.common import make_time_unit_str, _test_arguments
from pyart.core.radar import Radar

from copy import deepcopy

CASA_FIELD_NAMES = {
    # corrected reflectivity, horizontal
    'Reflectivity': 'reflectivity',
    # corrected reflectivity, vertical
    # differential reflectivity
    'DifferentialReflectivity': 'differential_reflectivity',
    'CrossPolCorrelation': 'cross_correlation_ratio',
    'DifferentialPhase': 'differential_phase',
    'SpecificPhase': 'specific_differential_phase',
    'NormalizedCoherentPower': 'normalized_coherent_power',
    'SignalToNoiseRatio': 'signal_to_noise_ratio',
    'Velocity': 'velocity',
    'SpectralWidth': 'spectrum_width',
    'SignalPower_H': 'signal_power_h',
    'CorrectedReflectivity': 'corrected_reflectivity',
    'CorrectedDifferentialReflectivity': 'corrected_differential_reflectivity',
    'RainfallRate': 'rain_rate'
}

def scale(x, out_range=(-1, 1)):
    domain = np.min(x), np.max(x)
    y = (x - (domain[1] + domain[0]) / 2) / (domain[1] - domain[0])
    return y * (out_range[1] - out_range[0]) + (out_range[1] + out_range[0]) / 2

def impute_missing(radar, radar_field=None, impute_str='minimum'):
    """
    takes the missing value and imputes it. Right now,
    only one method is supported, which is to replace
    missing values ( = -99900 ) with the minimum value
    in the radar field.
    """
    minimum_list = ['Reflectivity', 'CrossPolCorrelation','SpecificPhase',
        'SpectralWidth']
    zero_list = ['DifferentialReflectivity','NormalizedCoherentPower']
    
    field = deepcopy(radar.fields[radar_field]['data'])

    if radar_field in minimum_list:
        min_value = np.min(field[field>-900])
        field[field<-900] = min_value
        
    elif radar_field in zero_list:
        field[field<-900] = 0
        
    else:
        print('did nothing. check spelling?')
    
    radar.fields[radar_field]['data'] = field
    
    return radar

def read_casa_netcdf(filename, **kwargs):
    """
    Read a CASA NetCDF file.

    Parameters
    ----------
    filename : str
        Name of CASA NetCDF file to read data from.

    Returns
    -------
    radar : Radar
        Radar object.

    """
    # test for non empty kwargs
    _test_arguments(kwargs)

    # create metadata retrieval object
    filemetadata = FileMetadata('casa_netcdf')

    # Open netCDF4 file
    dset = netCDF4.Dataset(filename)
    nrays = len(dset.dimensions['Radial'])
    nbins = len(dset.dimensions['Gate'])

    # latitude, longitude and altitude
    latitude = filemetadata('latitude')
    longitude = filemetadata('longitude')
    altitude = filemetadata('altitude')
    latitude['data'] = np.array([dset.Latitude], 'float64')
    longitude['data'] = np.array([dset.Longitude], 'float64')
    altitude['data'] = np.array([dset.Height], 'float64')

    # metadata
    metadata = filemetadata('metadata')
    metadata_mapping = {
        'vcp-value': 'vcp',#not in casa
        'radarName-value': 'RadarName',
        'ConversionPlugin': 'conversion_software', #not in casa
    }
    for netcdf_attr, metadata_key in metadata_mapping.items():
        if netcdf_attr in dset.ncattrs():
            metadata[metadata_key] = dset.getncattr(netcdf_attr)

    # sweep_start_ray_index, sweep_end_ray_index
    sweep_start_ray_index = filemetadata('sweep_start_ray_index')
    sweep_end_ray_index = filemetadata('sweep_end_ray_index')
    sweep_start_ray_index['data'] = np.array([0], dtype='int32')
    sweep_end_ray_index['data'] = np.array([nrays-1], dtype='int32')

    # sweep number
    sweep_number = filemetadata('sweep_number')
    sweep_number['data'] = np.array([0], dtype='int32')

    # sweep_type
    scan_type = 'ppi'

    # sweep_mode, fixed_angle
    sweep_mode = filemetadata('sweep_mode')
    fixed_angle = filemetadata('fixed_angle')
    sweep_mode['data'] = np.array(1 * ['azimuth_surveillance'])
    elev_mean = np.mean(dset.variables['Elevation'])
    fixed_angle['data'] = np.array([elev_mean], dtype='float32')

    # time
    time = filemetadata('time')
    start_time = datetime.datetime.utcfromtimestamp(dset.variables['Time'][0])
    time['units'] = make_time_unit_str(start_time)
    time['data'] = np.zeros((nrays, ), dtype='float64')

    # range
    _range = filemetadata('range')
    step = dset.variables['GateWidth'][0]/1e3 
    # * len(dset.variables['GateWidth'][:]))/1e6
    _range['data'] = (np.arange(nbins, dtype='float32') * step + step / 2)
    _range['meters_to_center_of_first_gate'] = step / 2.
    _range['meters_between_gates'] = step

    # elevation
    elevation = filemetadata('elevation')
    elevation_angle = elev_mean
    elevation['data'] = np.ones((nrays, ), dtype='float32') * elevation_angle

    # azimuth
    azimuth = filemetadata('azimuth')
    azimuth['data'] = dset.variables['Azimuth'][:]

    # fields
    # Ryan Note: What is "TypeName"? 

#     field_name = dset.TypeName

#     field_data = np.ma.array(dset.variables[field_name][:])
#     if 'MissingData' in dset.ncattrs():
#         field_data[field_data == dset.MissingData] = np.ma.masked
#     if 'RangeFolded' in dset.ncattrs():
#         field_data[field_data == dset.RangeFolded] = np.ma.masked

#     fields = {field_name: filemetadata(field_name)}
#     fields[field_name]['data'] = field_data
#     fields[field_name]['units'] = dset.variables[field_name].Units
#     fields[field_name]['_FillValue'] = get_fillvalue()

    # borrowing from d3r_gcpex_nc.py
    ncvars = dset.variables
    keys = [k for k, v in ncvars.items() if v.dimensions == ('Radial', 'Gate')]
    fields = {}
    for key in keys:
        field_name = filemetadata.get_field_name(key)
        if field_name is None:
            field_name = key
        fields[field_name] = _ncvar_to_dict(ncvars[key])


    # instrument_parameters
    instrument_parameters = {}

    if 'PRF-value' in dset.ncattrs():
        dic = filemetadata('prt')
        prt = 1. / float(dset.getncattr('PRF-value'))
        dic['data'] = np.ones((nrays, ), dtype='float32') * prt
        instrument_parameters['prt'] = dic

    if 'PulseWidth-value' in dset.ncattrs():
        dic = filemetadata('pulse_width')
        pulse_width = dset.getncattr('PulseWidth-value') * 1.e-6
        dic['data'] = np.ones((nrays, ), dtype='float32') * pulse_width
        instrument_parameters['pulse_width'] = dic

    if 'NyquistVelocity-value' in dset.ncattrs():
        dic = filemetadata('nyquist_velocity')
        nyquist_velocity = float(dset.getncattr('NyquistVelocity-value'))
        dic['data'] = np.ones((nrays, ), dtype='float32') * nyquist_velocity
        instrument_parameters['nyquist_velocity'] = dic

    if 'Beamwidth' in dset.variables:
        dic = filemetadata('radar_beam_width_h')
        dic['data'] = dset.variables['Beamwidth'][:]
        instrument_parameters['radar_beam_width_h'] = dic

    dset.close()

    return Radar(
        time, _range, fields, metadata, scan_type,
        latitude, longitude, altitude,
        sweep_number, sweep_mode, fixed_angle, sweep_start_ray_index,
        sweep_end_ray_index,
        azimuth, elevation,
        instrument_parameters=instrument_parameters)

def _ncvar_to_dict(ncvar):
    """ Convert a NetCDF Dataset variable to a dictionary. """
    # copy all attribute except for scaling parameters
    d = dict((k, getattr(ncvar, k)) for k in ncvar.ncattrs()
             if k not in ['scale_factor', 'add_offset'])
    d['data'] = ncvar[:]
    if np.isscalar(d['data']):
        # netCDF4 1.1.0+ returns a scalar for 0-dim array, we always want
        # 1-dim+ arrays with a valid shape.
        d['data'] = np.array(d['data'])
        d['data'].shape = (1, )
    return d