# Changelog

## oceandatr (development version)

## oceandatr 0.2.2.0

- [`get_bathymetry()`](https://emlab-ucsb.github.io/oceandatr/reference/get_bathymetry.md)
  now accesses latest GEBCO data (sub-ice) from the Natural Environment
  Research Council’s (NERC) Centre for Environmental Data Analysis
  (CEDA) using OPeNDAP.
- `get_bathyemtry()` argument `resolution` removed: CEDA server only 15
  arc second resolution data
- [`get_bathymetry()`](https://emlab-ucsb.github.io/oceandatr/reference/get_bathymetry.md)
  argument `keep` removed: bathymetry data is automatically saved
- `get_bathmetry()` argument `download_timeout` removed
- Added `NEWS.md` file
