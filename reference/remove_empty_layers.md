# Remove empty layers in spatial object

Removes any layers (\`terra::rast\` object) or columns (\`sf\` object)
that are all zero or NA

## Usage

``` r
remove_empty_layers(dat)
```

## Arguments

- dat:

  \`sf\` or \`terra::rast\` object

## Value

\`sf\` or \`terra::rast\` depending on input
