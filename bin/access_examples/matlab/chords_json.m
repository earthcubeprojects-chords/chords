% Read CHORDS JSON data into a Matlab program.
% This code uses the JSONlab toolbox from the Matlab File Exchange.
% (Matlab >= R2014b)

url='http://chords.dyndns.org/instruments/26.json?last';
json_data = urlread(url);
inst_data =loadjson(json_data);
inst_data
inst_data.Data
