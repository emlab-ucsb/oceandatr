# oceandatr (development version)
* Fix get_bathymetry() for areas that need more than one download chunk: every chunk but the northernmost was written one raster row too far north, so the bathymetry was shifted by one cell (15 arc seconds) from the first chunk boundary southwards, one row of data was lost at the boundary, and the southernmost row was never written. Areas that are a single chunk were not affected.
* Fix get_bathymetry() silently returning incomplete bathymetry when a download is interrupted. The GEBCO data are now downloaded with httr2 instead of RNetCDF, because when a download was cut short (e.g. an HTTP/2 stream error) the netcdf library reported the error to the console but returned the part of the chunk that was not received as zeros, with no R error. Each response is now checked to be complete, and downloads that fail are tried again up to 3 times. This removes the `RNetCDF` dependency.
* Fix the position of the bathymetry downloaded by get_bathymetry(): the coordinates of the GEBCO grid are the centres of its cells, but were used as the edges of the raster, so the data were half a cell (7.5 arc-seconds) north and east of their true position. 
* Fix get_bathymetry() leaving out the last column of the GEBCO grid when an area reaches 180 degrees longitude, so for areas that cross the antimeridian the bathymetry stopped one cell short of it, leaving a strip with no data. The same applied to the last row of the grid for areas reaching 90 degrees north. Downloaded bathymetry rasters are one row and one column larger as a result.
* Downloaded bathymetry is now saved in files named "bathy_gebco2026_..." instead of "bathy_...", so that files saved by earlier versions (which have the position errors fixed in this version) are not used when path is set to a folder that already has them. 

# oceandatr 0.6.0
* Switch to internal functions to access Marine Regions data and Bio-Oracle data on ERDDAP server. This removes `mregions2` and `rerddap` external dependencies, but adds the light dependency `jsonlite`.
* Add better handling of errors when APIs/ web files are unreachable or stop downloading part way through.

# oceandatr 0.5.1
* Add CITATION file and publication link badge

# oceandatr 0.5.0
* improve package testing by simplifying and speeding up tests
* add Github actions for code coverage
* add note to readme about package installation in Linux as per package reviewer note

# oceandatr 0.4.4
* remove meth = "" arguments from examples and vignette now that terra::spatSample() has been fixed. Fixes #77

# oceandatr 0.4.3
* Add fuzzy matching for get_boundary() using base::agrep()
* When no matches found for the name in get_boundary(), a selectable list of options is no longer presented as the behaviour of the pop-up list varied across OSes. Options are still printed to the console, but the user is asked to re-run the function with a correct name.
* getboundary vignette updated to reflect above change

# oceandatr 0.4.2 
* Add "Predicting fishing effort in Micronesia" vignette

# oceandatr 0.4.1 
* Add Github actions for R-CMD-CHECK
* Switch from ncdf4 to RNetCDF package for NetCDF file handling in get_bathymetry() because it supports OPeNDAP.

# oceandatr 0.4.0 
* `get_bathymetry()` now downloads data in chunks direct to disk to allow download of large areas
* `get_bathymetry()` pulls data from the latests GEBCO 2026 data
* fixed a minor issue in `polygon_in_4326()` to ensure geometry column is named geometry
* Update readme file to list GEBCO 2026 as source and update bathymetry map

# oceandatr 0.3.0
* `spatialgridr` package functions (get_boundary(), get_grid(), and get_data_in_grid()) integrated into `oceandatr`
* Dependency on `spatialgridr` removed
* Speeded up tests and examples by downscaling cold_coral example data, and reducing number of bathymetry data tests and examples

# oceandatr 0.2.6
* Remove `gfwr` package dependency
* Add `gfw_ais()` internal function for GFW API call. This is a simplified version of `gfwr` package functions.
* Add `geojsonsf` and `httr2` imports

# oceandatr 0.2.5
* Remove all data - this is now in the separate `oceandatrsets` package
* Update data references to use `oceandatrsets`
* Add `oceandatrsets` dependency
* Use `pak` instead of `remotes` for Github install (`remotes` is superseded)
* Use R-Universe for `gfwr` install
* Remove some get_features() tests that take a long time and are repeating individual function tests

# oceandatr 0.2.4
* Switch to `rerddap` package for downloading Bio-Oracle data
* Remove `biooracler` dependency
* Add `min_num_clusters` argument to `get_enviro_zones()`, and ensure min and max num cluster arguments meet `NbClust` requirements, #70 by @jaseeverett

# oceandatr 0.2.3

* Robust function argument checks implemented with package `checkmate`
* Removal of `magrittr` pipe and replacement with base R pipe, removal of dot operators
* Simplification of code
* bug fixes and documentation improvement
* `patches` package scenario in prioritization vignette removed due to changes in `prioritizr`

# oceandatr 0.2.2.0

* `get_bathymetry()` now accesses latest GEBCO data (sub-ice) from the Natural Environment Research Council's (NERC) Centre for Environmental Data Analysis (CEDA) using OPeNDAP.
* `get_bathymetry()` argument `resolution` removed: CEDA server only 15 arc second resolution data
* `get_bathymetry()` argument `keep` removed: bathymetry data is automatically saved
* `get_bathmetry()` argument `download_timeout` removed
* Added `NEWS.md` file

