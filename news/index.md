# Changelog

## oceandatr (development version)

## oceandatr 0.2.5

- Remove all data - this is now in the separate `oceandatrsets` package
- Update data references to use `oceandatrsets`
- Add `oceandatrsets` dependency
- Use `pak` instead of `remotes` for Github install (`remotes` is
  superseded)
- Use R-Universe for `gfwr` install
- Remove some get_features() tests that take a long time and are
  repeating individual function tests

## oceandatr 0.2.4

- Switch to `rerddap` package for downloading Bio-Oracle data
- Remove `biooracler` dependency
- Add `min_num_clusters` argument to
  [`get_enviro_zones()`](https://emlab-ucsb.github.io/oceandatr/reference/get_enviro_zones.md),
  and ensure min and max num cluster arguments meet `NbClust`
  requirements, \#70 by @jaseeverett

## oceandatr 0.2.3

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
