# Remove empty layers in spatial object

Removes any layers
([`terra::rast`](https://rspatial.github.io/terra/reference/rast.html)
object) or columns (`sf` object) that are all zero or NA

## Usage

``` r
remove_empty_layers(dat)
```

## Arguments

- dat:

  `sf` or
  [`terra::rast`](https://rspatial.github.io/terra/reference/rast.html)
  object

## Value

`sf` or
[`terra::rast`](https://rspatial.github.io/terra/reference/rast.html)
depending on input
