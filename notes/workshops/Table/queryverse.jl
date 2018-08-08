using Queryverse
using VegaDatasets

cars = dataset("cars")

cars |> Voyager()

cars |> typeof

# use quantitative columns etc...
# University of Washington building DataVoyager

cars |>
    @filter(_.Origin == "USA")

# Plots powered by vegalite (no 3D)
load("uscars") |>
    @vlplot(:point, x = :Miles_per_Gallon, y = :Weight_in_libs, color="Cylinders:n")

# Specify column by default, specific way to enter symbol
# CSV and Feather fully supported

# No Abstract supertype

# To continue pipeline after things not returing anything: "@tee"
using Query
Query.@tee
@tee
cars |>
    @tee( x->)
cars |> @take(3)
# All iterable things, drop and take...

# All lazy

# Plot

{:Miles_per_Gallon, title = "Foo"}
Query.@filter

using VegaLite

# Foo Vegalite plot description
