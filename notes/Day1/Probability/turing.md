# Probabilistic programming tools

Stochastic statements, like random variable

Say:

```julia
s ~ Normal()
v ~ ...
```

Model, equations, graphical notations.

Two components:

- Modelling DSL with `@model` macro
- Inference with either Hamiltonian Monte Carlo vs Particle MCMC

You sample with model and sampler (HMC, PG, NUTS, etc...)
