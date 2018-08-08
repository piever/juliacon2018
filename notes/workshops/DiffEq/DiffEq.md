# How to build things to solve PDE ?

Solve by changing in:

- linear system
- nonlinear system
- ODE
- SDE
- ...

## Poisson example

First, represent `u` function. Linear interpolation?
Discrete derivative. Discrete second derivative.

Now it becomes a linear problem `u''` is linear in our grid. Careful: needs boundary condition.
Solve by inverting tridiagonal matrix.

`u'' = f(u)` ? Now we get `Au=f(u)` --> nonlinear root-finding problem

`u_t = u_xx + f(u,t)` --> `U_t = AU + f(U, t)`
`U' = AU + f(U, t)`

## Represent functions and derivatives

FDM: DiffEqOperators
FVM ?
FEM: many packages
Spectral methods: FFTW? ApproxFun

## FDM

Get lazy object that can multiply as if it had the values.

## FEM

Represent a function as a linear combination of basis functions. Esp. useful for complex domains.
Either via PyCall or JuliaFEM. Also JuAFEM (toolbox)

## Spectral methods

Fourier series to get `sin(kx)` basis. Done with FFTW in Julia.

For continuous functions, it converges quickly, plus derivatives are easy to write. Also, ApproxFun.

Derivatives are all diagonal...

ApproxFun also has other basis, like Chebyshev polynomials. Choose correct space according to fct properties.

## Backslash an * are powerful as they specialize

LinearMaps.jl does it without matrix

## Preconditioning

Matrix may have bad properties. Preconditioning, i.e. solve simpler problem and then move on to glmres.

For example, Incomplete LU decomposition.

## Linear solver in parallel

Trilinos.jl

## Nonlinear case

Rootfinding method (like Newtons!)
