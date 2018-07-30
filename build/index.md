
class: middle, centre




# JuliaDBMeta and StatPlots




## Metaprogramming tools for manipulating and visualizing data


Pietro Vertechi, JuliaCon 2018


---




# Introduction


  * The recent pure Julia library JuliaDB provides tool to store and manipulate tabular data, on a single or multiple processors.


--


  * Using metaprogramming, one can this packages simpler to use.


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




# Colwise-macros


Take an expression and transform symbols into the corresponding modules. `@where_vec`


Use symbols as if they were columns.


```julia
t = @with iris :SepalLength + :SepalWidth
```

```
150-element Array{Float64,1}:
  8.6
  7.9
  7.9
  7.7
  8.6
  9.3
  8.0
  8.4
  7.3
  8.0
  ⋮
 10.0
  8.5
 10.0
 10.0
  9.7
  8.8
  9.5
  9.6
  8.9
```


---




# Colwise-macros


Take an expression and transform symbols into the corresponding modules. `@where_vec`


Use symbols as if they were columns.


```julia
t = @with iris :SepalLength + :SepalWidth
```


The result can be used to filter the data:


```julia
t = @where_vec iris :SepalLength .> mean(:SepalLength)
```

```
Table with 70 rows, 5 columns:
SepalLength  SepalWidth  PetalLength  PetalWidth  Species
──────────────────────────────────────────────────────────────
7.0          3.2         4.7          1.4         "versicolor"
6.4          3.2         4.5          1.5         "versicolor"
6.9          3.1         4.9          1.5         "versicolor"
6.5          2.8         4.6          1.5         "versicolor"
6.3          3.3         4.7          1.6         "versicolor"
6.6          2.9         4.6          1.3         "versicolor"
5.9          3.0         4.2          1.5         "versicolor"
6.0          2.2         4.0          1.0         "versicolor"
6.1          2.9         4.7          1.4         "versicolor"
⋮
6.9          3.1         5.1          2.3         "virginica"
6.8          3.2         5.9          2.3         "virginica"
6.7          3.3         5.7          2.5         "virginica"
6.7          3.0         5.2          2.3         "virginica"
6.3          2.5         5.0          1.9         "virginica"
6.5          3.0         5.2          2.0         "virginica"
6.2          3.4         5.4          2.3         "virginica"
5.9          3.0         5.1          1.8         "virginica"
```


---




# Colwise-macros


Take an expression and transform symbols into the corresponding modules. `@where_vec`


Use symbols as if they were columns.


```julia
t = @with iris :SepalLength + :SepalWidth
```


The result can be used to filter the data:


```julia
t = @where_vec iris :SepalLength .> mean(:SepalLength)
```


or added as a new column:


```julia
t = @transform_vec iris {Ratio = :SepalLength ./ :SepalWidth}
t[1:5]
```

```
Table with 5 rows, 6 columns:
SepalLength  SepalWidth  PetalLength  PetalWidth  Species   Ratio
───────────────────────────────────────────────────────────────────
5.1          3.5         1.4          0.2         "setosa"  1.45714
4.9          3.0         1.4          0.2         "setosa"  1.63333
4.7          3.2         1.3          0.2         "setosa"  1.46875
4.6          3.1         1.5          0.2         "setosa"  1.48387
5.0          3.6         1.4          0.2         "setosa"  1.38889
```


---




# Row-wise macros


```julia
@filter iris :Species != "setosa"
@transform iris {Ratio = :SepalLength / :SepalWidth}
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
