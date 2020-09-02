using CUTEst, JLD2, JSOSolvers, SolverBenchmark, SolverTools

function runcutest(filename)
  nvar=100
  uncnames = sort(CUTEst.select(max_var=nvar, max_con=0, only_free_var=true))
  bndnames = sort(CUTEst.select(max_var=nvar, max_con=0))

  uncproblems = (CUTEstModel(p) for p in uncnames)
  bndproblems = (CUTEstModel(p) for p in bndnames)

  cols = [:name, :nvar, :status, :objective, :elapsed_time, :iter, :neval_obj, :neval_grad]

  jldopen(filename * ".jld", "w") do file
    stats = solve_problems(lbfgs, uncproblems, max_time=10.0)
    file["lbfgs"] = stats
    stats = solve_problems(trunk, uncproblems, max_time=10.0)
    file["trunk"] = stats
    stats = solve_problems(tron, bndproblems, max_time=10.0)
    file["tron"] = stats
    stats[cols]
  end
end