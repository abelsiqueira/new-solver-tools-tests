###
# Before running this, enter the folders `old` and `new`, activate and instantiate that folder and
# run `main.jl`.
###

using DataFrames, JLD2, Plots, SolverBenchmark
gr(size=(600,400))

function compare()
  isfile("old/old.jld") || error("Need old/old.jld")
  isfile("new/new.jld") || error("Need new/new.jld")

  costs = [
    df -> (df.status .!= :first_order) * Inf + df.elapsed_time,
    df -> (df.status .!= :first_order) * Inf + df.neval_obj + df.neval_grad,
    df -> (df.status .!= :first_order) * Inf + df.neval_obj + df.neval_grad + df.neval_hprod + df.neval_hess
  ]
  costnames = ["elapsed time", "#f + #g", "#f + #g + #H + #Hp"]

  cols = [:status, :objective, :neval_obj, :neval_grad, :neval_hprod]

  for solver in ["lbfgs", "trunk", "tron"]
    stats = Dict{Symbol,DataFrame}()
    jldopen("old/old.jld") do old
      stats[:old] = old[solver]
    end
    jldopen("new/new.jld") do new
      stats[:new] = new[solver]
    end

    open("$solver-table.md", "w") do io
      pretty_stats(io, join(stats, cols, invariant_cols=[:name]))
    end
    rob = Dict(s => count(df.status .== :first_order) for (s,df) in stats)
    println("Robustness: $rob")
    profile_solvers(stats, costs, costnames)
    png(solver)
  end
end

compare()