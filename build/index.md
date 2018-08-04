
class: middle, centre




# JuliaDBMeta and StatPlots




## Metaprogramming tools for manipulating and visualizing data


Pietro Vertechi, JuliaCon 2018


---




# Outline


  * JuliaDBMeta: a pure Julia package (inspired on DataFramesMeta and Query) that uses metaprogramming to simplify operations on tabular data


--


  * Using metaprogramming, it is possible to pipe this data directly into the StatPlots package, for statistical visualizations


--


  * Thanks to the InteractBase package, it is possible to access these tools from a "hackable" and composable GUI


---




# Exploiting JuliaDB's technical advantages


<div style="display: flex; orientation: row;">     <div style="width: 47%; text-align:center;">         <strong>JuliaDB</strong>     </div>     <div style="width: 6%;"></div>     <div style="width: 47%; text-align:center;">         <strong>JuliaDBMeta</strong>     </div> </div> <div style="height: 1em;"></div>


--


<div style="display: flex; orientation: row;">     <div style="width: 47%;">         Fully-typed tables with type stable column extraction     </div>     <div style="width: 6%;"></div>     <div style="width: 47%;">         Replace symbols with respective column at macroexpand time     </div> </div> <div style="height: 1em;"></div>


--


<div style="display: flex; orientation: row;">     <div style="width: 47%;">         Fast row iteration     </div>     <div style="width: 6%;"></div>     <div style="width: 47%;">         Detect necessary variables and anonymous function     </div> </div> <div style="height: 1em;"></div>


--


<div style="display: flex; orientation: row;">     <div style="width: 47%;">         Parallel data storage and parallel computations     </div>     <div style="width: 6%;"></div>     <div style="width: 47%;">         Detect if user command can be parallelized automatically     </div> </div>


---




# Demo


```julia
using JuliaDBMeta
filepath = Pkg.dir("JuliaDBMeta", "test", "tables", "iris.csv")
iris = loadtable(filepath)
```

```
Table with 150 rows, 5 columns:
SepalLength  SepalWidth  PetalLength  PetalWidth  Species
─────────────────────────────────────────────────────────────
5.1          3.5         1.4          0.2         "setosa"
4.9          3.0         1.4          0.2         "setosa"
4.7          3.2         1.3          0.2         "setosa"
4.6          3.1         1.5          0.2         "setosa"
5.0          3.6         1.4          0.2         "setosa"
5.4          3.9         1.7          0.4         "setosa"
4.6          3.4         1.4          0.3         "setosa"
5.0          3.4         1.5          0.2         "setosa"
4.4          2.9         1.4          0.2         "setosa"
⋮
5.8          2.7         5.1          1.9         "virginica"
6.8          3.2         5.9          2.3         "virginica"
6.7          3.3         5.7          2.5         "virginica"
6.7          3.0         5.2          2.3         "virginica"
6.3          2.5         5.0          1.9         "virginica"
6.5          3.0         5.2          2.0         "virginica"
6.2          3.4         5.4          2.3         "virginica"
5.9          3.0         5.1          1.8         "virginica"
```


---




# Type stable column extraction


Each symbol gets replaced with the corresponding column:


```julia
@with iris :SepalLength .* :SepalWidth ./ mean(:SepalWidth)
```

```
150-element Array{Float64,1}:
 5.83842
 4.80811
 4.91932
 4.6642
 5.88748
 6.88836
 5.11557
 5.5604
 4.17357
 4.96838
 ⋮
 6.99629
 5.12211
 7.11731
 7.23179
 6.57436
 5.15155
 6.37811
 6.8949
 5.78936
```


---




# Type stable column extraction


```julia
using Base.Test
f(df) = @with df  :SepalLength
@inferred f(iris)
```

```
150-element Array{Float64,1}:
 5.1
 4.9
 4.7
 4.6
 5.0
 5.4
 4.6
 5.0
 4.4
 4.9
 ⋮
 6.9
 5.8
 6.8
 6.7
 6.7
 6.3
 6.5
 6.2
 5.9
```


---




# Fast row iteration


Replace each symbol with a reference to the respective field of a row:


```julia
@map iris :SepalLength/:SepalWidth
```

```
150-element Array{Float64,1}:
 1.45714
 1.63333
 1.46875
 1.48387
 1.38889
 1.38462
 1.35294
 1.47059
 1.51724
 1.58065
 ⋮
 2.22581
 2.14815
 2.125
 2.0303
 2.23333
 2.52
 2.16667
 1.82353
 1.96667
```


---




# Fast row iteration: under the hood


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




# Fast row iteration: examples


The same trick can be used to add a new column:


```julia
@transform iris {Ratio = :SepalLength/:SepalWidth}
```

```
Table with 150 rows, 6 columns:
SepalLength  SepalWidth  PetalLength  PetalWidth  Species      Ratio
──────────────────────────────────────────────────────────────────────
5.1          3.5         1.4          0.2         "setosa"     1.45714
4.9          3.0         1.4          0.2         "setosa"     1.63333
4.7          3.2         1.3          0.2         "setosa"     1.46875
4.6          3.1         1.5          0.2         "setosa"     1.48387
5.0          3.6         1.4          0.2         "setosa"     1.38889
5.4          3.9         1.7          0.4         "setosa"     1.38462
4.6          3.4         1.4          0.3         "setosa"     1.35294
5.0          3.4         1.5          0.2         "setosa"     1.47059
4.4          2.9         1.4          0.2         "setosa"     1.51724
⋮
5.8          2.7         5.1          1.9         "virginica"  2.14815
6.8          3.2         5.9          2.3         "virginica"  2.125
6.7          3.3         5.7          2.5         "virginica"  2.0303
6.7          3.0         5.2          2.3         "virginica"  2.23333
6.3          2.5         5.0          1.9         "virginica"  2.52
6.5          3.0         5.2          2.0         "virginica"  2.16667
6.2          3.4         5.4          2.3         "virginica"  1.82353
5.9          3.0         5.1          1.8         "virginica"  1.96667
```


---




# Fast row iteration: examples


The same trick can be used to add a new column:


```julia
@transform iris {Ratio = :SepalLength/:SepalWidth}
```


or to select data:


```julia
@where iris :SepalLength == 4.9 && :Species == "setosa"
```

```
Table with 4 rows, 5 columns:
SepalLength  SepalWidth  PetalLength  PetalWidth  Species
──────────────────────────────────────────────────────────
4.9          3.0         1.4          0.2         "setosa"
4.9          3.1         1.5          0.1         "setosa"
4.9          3.1         1.5          0.2         "setosa"
4.9          3.6         1.4          0.1         "setosa"
```


---




# Fast row iteration: out-of-core


As each row-wise macro implements a local computation, it will be parallelized out of the box if the data is stored on several processors.


```julia
iris5 = table(iris, chunks = 5)
@where iris5 :SepalLength == 4.9 && :Species == "setosa"
```

```
Distributed Table with 4 rows in 2 chunks:
SepalLength  SepalWidth  PetalLength  PetalWidth  Species
──────────────────────────────────────────────────────────
4.9          3.0         1.4          0.2         "setosa"
4.9          3.1         1.5          0.1         "setosa"
4.9          3.1         1.5          0.2         "setosa"
4.9          3.6         1.4          0.1         "setosa"
```


---




# Pipeline


All these macros have curried versions and can be combined with vanilla Julia Base or JuliaDB functions in a shared pipeline:


```julia
@apply iris begin
    @map {Ratio = :SepalLength/:SepalWidth, Sum = :SepalLength + :SepalWidth}
    sort(_, :Ratio, rev = true)
    _[1]
end
```

```
(Ratio = 2.9615384615384617, Sum = 10.3)
```


---




# Pipeline: grouping


The pipeline has support for grouping:


```julia
@apply iris :Species begin
    @map {Ratio = :SepalLength/:SepalWidth, Sum = :SepalLength + :SepalWidth}
    sort(_, :Ratio, rev = true)
    _[1]
end
```

```
Table with 3 rows, 3 columns:
Species       Ratio    Sum
───────────────────────────
"setosa"      1.95652  6.8
"versicolor"  2.81818  8.4
"virginica"   2.96154  10.3
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

