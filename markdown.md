class: middle, centre
# JuliaDBMeta and StatPlots
## Metaprogramming tools for manipulating and visualizing data
Pietro Vertechi, JuliaCon 2018

---

# Outline

- JuliaDBMeta: a pure Julia package (inspired on DataFramesMeta and Query) that uses metaprogramming to simplify operations on tabular data
--
- Using metaprogramming, it is possible to pipe this data directly into the StatPlots package, for statistical visualizations
--
- Thanks to the InteractBase package, it is possible to access these tools from a "hackable" and composable GUI

---
# Exploiting JuliaDB's technical advantages

<div style="display: flex; orientation: row;">
    <div style="width: 47%;">
        Fully-typed tables with type stable column extraction
    </div>
    <p style="width: 6%; text-align:center;">
        &rarr;
    </p>
    <div style="width: 47%;">
        Allow the user to type a symbol explicitly and replace it with a column at macroexpand time
    </div>
</div>
<div style="height: 1em;"></div>

--

<div style="display: flex; orientation: row;">
    <div style="width: 47%;">
        Fast row iteration
    </div>
    <p style="width: 6%; text-align:center;">
        &rarr;
    </p>
    <div style="width: 47%;">
        From a user expression, detect which columns are needed and what anonymous function to run on each row
    </div>
</div>
<div style="height: 1em;"></div>

--

<div style="display: flex; orientation: row;">
    <div style="width: 47%;">
        Parallel data storage and parallel computations
    </div>
    <p style="width: 6%; text-align:center;">
        &rarr;
    </p>
    <div style="width: 47%;">
        Detect if user command can be parallelized automatically
    </div>
</div>

---

# Demo

```@example meta
using JuliaDBMeta
filepath = Pkg.dir("JuliaDBMeta", "test", "tables", "iris.csv")
iris = loadtable(filepath)
```

---

# Row-wise macros

Replace each symbol with a reference to the respective field of a row:

```@example meta
@map iris :SepalLength/:SepalWidth
```

---

# Row-wise macros: under the hood

```julia
@map iris :SepalLength/:SepalWidth
```
--
* Construct anonymous function `t -> t.SepalLength / t.SepalWidth`
--
* Store list of fields that are actually used: `(:SepalLength, :SepalWidth)`
--
* Return:

```julia
map(t -> t.SepalLength / t.SepalWidth, iris, select = (:SepalLength, :SepalWidth))
```

---

# Row-wise macros: examples

The same trick can be used to add a new column:

```@example meta
@transform iris {Ratio = :SepalLength/:SepalWidth}
```

---

# Row-wise macros: examples

The same trick can be used to add a new column:

```julia
@transform iris {Ratio = :SepalLength/:SepalWidth}
```

or to select data:

```@example meta
@where iris :SepalLength == 4.9 && :Species == "setosa"
```

---

# Row-wise macros: out-of-core

As each row-wise macro implements a local computation, it will be parallelized out of the box if the data is stored on several processors.

```@example meta
iris5 = table(iris, chunks = 5)
@where iris5 :SepalLength == 4.9 && :Species == "setosa"
```

---

# Column-wise macros

Very similar to row-wise macros, but they act on columns (each symbol gets replaced with the corresponding column). Useful when the whole column is needed:

```@example meta
using StatsBase
@where_vec iris :SepalLength .> quantile(:SepalLength, 0.95)
```

---

# Pipeline

All these macros have curried versions and can be combined with vanilla Julia Base or JuliaDB functions in a shared pipeline:

```@example meta
@apply iris begin
    @map {Ratio = :SepalLength/:SepalWidth, Sum = :SepalLength + :SepalWidth}
    sort(_, :Ratio, rev = true)
    _[1]
end
```
---

# Pipeline: grouping

The pipeline has support for grouping:

```@example meta
@apply iris :Species begin
    @map {Ratio = :SepalLength/:SepalWidth, Sum = :SepalLength + :SepalWidth}
    sort(_, :Ratio, rev = true)
    _[1]
end
```

---

# Pipeline: plotting

The pipeline has support for plotting via StatPlots and the `@df` macro:

```julia
using StatPlots
@apply iris begin
    @map {Ratio = :SepalLength/:SepalWidth, Sum = :SepalLength+:SepalWidth}
    @df scatter(:Ratio, :Sum, smooth = true)
end
```

---

# Interactivity

The [InteractBase](https://github.com/piever/InteractBase.jl/) package allows the creation of interactive user interfaces based on JuliaDBMeta and StatPlots.
