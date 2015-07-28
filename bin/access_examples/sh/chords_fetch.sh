#!/bin/sh

urlcsv='http://chords.dyndns.org/instruments/26.csv?last'
urljson='http://chords.dyndns.org/instruments/26.json?last'

echo 'CSV format:'
curl $urlcsv

echo 'JSON format:'
curl $urljson

echo
