class: middle, centre
# JuliaDBMeta and StatPlots
## Metaprogramming tools for manipulating and visualizing data
Pietro Vertechi, JuliaCon 2018

---

# Introduction

- The recent pure Julia library JuliaDB provides tool to store and manipulate tabular data, on a single or multiple processors.
--
- Using metaprogramming, one can make this package simpler to use.
--
- JuliaDBMeta and StatPlots try to create a consistent DSL for dealing with tabular data, from data filtering and preprocessing to visualization
--
- Thanks to the InteractBase package, it is possible to access this tool from a "hackable" and composable GUI

---
# JuliaDBMeta

JuliaDBMeta is a set of macros to simplify data manipulation with JuliaDB, heavily inspired on DataFramesMeta. It exploits the technical advantages of JuliaDB:

- Fully typed tables with type stable column extraction
- Fast row iteration
- Parallel data storage and parallel computations

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
