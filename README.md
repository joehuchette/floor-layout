# floor-layout
This repository contains omputational materials for _Strong mixed-integer formulations for the floor layout problem_ by Joey Huchette, Santanu S. Dey, and Juan Pablo Vielma. It contains scripts to generate all the computational results presented in the paper, as well as .mps file models for each formulation and each benchmark instance.

To run these scripts, you will need julia version 0.4 and a few Julia packages:
* JuMP v0.12
* FloorLayout (unreleased)
* MathProgBase v0.3
* CPLEX v0.1
* Gadfly

These packages can be added by running the following Julia script:
```jl
Pkg.add("JuMP")
Pkg.checkout("JuMP", "release-0.12")
Pkg.add("CPLEX")
Pkg.add("Gadfly")
Pkg.clone("https://github.com/joehuchette/FloorLayout.jl.git")
```
