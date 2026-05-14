# Changelog

## oceandatr (development version)

\#oceandatr 0.2.3

- Robust function argument checks implemented with package `checkmate`
- Removal of `magrittr` pipe and replacement with base R pipe, removal
  of dot operators
- Simplification of code
- bug fixes and documentation improvement
- `patches` package scenario in prioritization vignette removed due to
  changes in `prioritizr`

## oceandatr 0.2.2.0

- [`get_bathymetry()`](https://emlab-ucsb.github.io/oceandatr/reference/get_bathymetry.md)
  now accesses latest GEBCO data (sub-ice) from the Natural Environment
  Research Council’s (NERC) Centre for Environmental Data Analysis
  (CEDA) using OPeNDAP.
- [`get_bathymetry()`](https://emlab-ucsb.github.io/oceandatr/reference/get_bathymetry.md)
  argument `resolution` removed: CEDA server only 15 arc second
  resolution data
- [`get_bathymetry()`](https://emlab-ucsb.github.io/oceandatr/reference/get_bathymetry.md)
  argument `keep` removed: bathymetry data is automatically saved
- `get_bathmetry()` argument `download_timeout` removed
- Added `NEWS.md` file
