#flow chart: using tutorial from: https://mikeyharper.uk/flowcharts-in-r-using-diagrammer/

#combined for oceandatr and patchwise

DiagrammeR::grViz("digraph {

graph [layout = dot, rankdir = LR]

# define the global styles of the nodes. We can override these in box if we wish
node [shape = rectangle, style = filled, fillcolor = royalblue3]

area [label = 'get_area()']
pus [label = 'get_grid()']
features [label =  'get_features()']
prioritize [label = 'prioritizr', fillcolor = 'green', shape = 'hexagon', orientation = 90, height = 1.1]
cost[label = 'cost data', fillcolor = grey]
patches[label = 'create_patches()', fillcolor = Coral]
patchesdf[label = 'create_patches_df()', fillcolor = Coral]
patchesbndmatrix[label = 'create_boundary_matrix()', fillcolor = Coral]
patchestargets[label = 'features_targets()', fillcolor = Coral]
patchesconstraints[label = 'constraints_targets', fillcolor = Coral]
patchesconvert[label = 'convert_solution', fillcolor = Coral]

# edge definitions with the node IDs
cost -> prioritize
features -> patches -> patchesdf -> patchesbndmatrix
features -> patchesdf -> patchestargets -> patchesconstraints
patches -> patchesbndmatrix
cost -> patchesdf -> patchesconstraints
area -> pus -> features -> prioritize
{patchesdf patchestargets patchesbndmatrix patchesconstraints} -> prioritize -> patchesconvert

}")

#oceandatr only

DiagrammeR::grViz("digraph {

graph [layout = dot, rankdir = LR]

# define the global styles of the nodes. We can override these in box if we wish
node [shape = rectangle, style = filled, fillcolor = deepskyblue, fontsize = 24]

area [label = 'get_area()']
pus [label = 'get_grid()']
features [label =  'get_features()']
prioritize [label = 'prioritizr', fillcolor = darkolivegreen2, shape = 'hexagon', orientation = 90, height = 1.7]
cost[label = 'get_dist_shore()']

# edge definitions with the node IDs
cost -> prioritize
area -> pus -> features -> prioritize


}") 

#oceandatr to patchwise

DiagrammeR::grViz("digraph {

graph [layout = dot, rankdir = LR]

# define the global styles of the nodes. We can override these in box if we wish
node [shape = rectangle, style = filled, fillcolor = deepskyblue, fontsize = 24]

area [label = 'get_area()']
pus [label = 'get_grid()']
features [label =  'get_features()']
prioritize [label = 'prioritizr', fillcolor = darkolivegreen2, shape = 'hexagon', orientation = 90, height = 1.7]
cost[label = 'cost data', fillcolor = grey]
patches[label = 'create_patches()', fillcolor = Coral]
patchesdf[label = 'create_patches_df()', fillcolor = Coral]
patchesbndmatrix[label = 'create_boundary_matrix()', fillcolor = Coral]
patchestargets[label = 'features_targets()', fillcolor = Coral]
patchesconstraints[label = 'constraints_targets', fillcolor = Coral]
patchesconvert[label = 'convert_solution', fillcolor = Coral]

# edge definitions with the node IDs
features -> patches -> patchesdf -> patchesbndmatrix
area -> pus -> features -> patchesdf -> patchestargets -> patchesconstraints
patches -> patchesbndmatrix
cost -> patchesdf -> patchesconstraints

{patchesdf patchestargets patchesbndmatrix patchesconstraints} -> prioritize -> patchesconvert

}")
