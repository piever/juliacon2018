
class: middle, centre




# JuliaDBMeta and StatPlots




## Metaprogramming tools for manipulating and visualizing data


Pietro Vertechi, JuliaCon 2018


---




# Introduction


  * The recent pure Julia library JuliaDB provides tool to store and manipulate tabular data, on a single or multiple processors.


--


  * Using metaprogramming, one can make this package simpler to use.


--


  * JuliaDBMeta and StatPlots try to create a consistent DSL for dealing with tabular data, from data filtering and preprocessing to visualization


--


  * Thanks to the InteractBase package, it is possible to access this tool from a "hackable" and composable GUI


---




# JuliaDBMeta


JuliaDBMeta is a set of macros to simplify data manipulation with JuliaDB, heavily inspired on DataFramesMeta. It exploits the technical advantages of JuliaDB:


  * Fully typed tables with type stable column extraction
  * Fast row iteration
  * Parallel data storage and parallel computations


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




# Row-wise macros


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




# Row-wise macros: examples


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




# Row-wise macros: out-of-core


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




# Column-wise macros


Very similar to row-wise macros, but they act on columns (each symbol gets replaced with the corresponding column). Useful when the whole column is needed:


```julia
using StatsBase
@where_vec iris :SepalLength .> quantile(:SepalLength, 0.95)
```

```
Table with 8 rows, 5 columns:
SepalLength  SepalWidth  PetalLength  PetalWidth  Species
─────────────────────────────────────────────────────────────
7.6          3.0         6.6          2.1         "virginica"
7.3          2.9         6.3          1.8         "virginica"
7.7          3.8         6.7          2.2         "virginica"
7.7          2.6         6.9          2.3         "virginica"
7.7          2.8         6.7          2.0         "virginica"
7.4          2.8         6.1          1.9         "virginica"
7.9          3.8         6.4          2.0         "virginica"
7.7          3.0         6.1          2.3         "virginica"
```


---




# Pipeline


All these macros have curried versions and can be combined with vanilla Julia Base or JuliaDB functions in a shared pipeline:


```julia
@apply iris begin
    @map {Ratio = :SepalLength/:SepalWidth, Sum = :SepalLength/:SepalWidth}
    sort(_, :Ratio, rev = true)
    _[1]
end
```

```
(Ratio = 2.9615384615384617, Sum = 2.9615384615384617)
```


---




# Pipeline: grouping


All these macros have curried versions and can be combined with vanilla Julia Base or JuliaDB functions in a shared pipeline:


```julia
@apply iris :Species begin
    @map {Ratio = :SepalLength/:SepalWidth, Sum = :SepalLength/:SepalWidth}
    sort(_, :Ratio, rev = true)
    _[1]
end
```

```
Table with 3 rows, 3 columns:
Species       Ratio    Sum
──────────────────────────────
"setosa"      1.95652  1.95652
"versicolor"  2.81818  2.81818
"virginica"   2.96154  2.96154
```

