
## Configuration to add our version of LogicCircuits and other packages

1. Open a console in your local folder repository

2. Enter to julia command line
``` julia```

3. Set your local folder repository
```cd("your_local_path_respository/ProbabilisticCircuits.jl/")```

4. Enter to pkg mode
``` ]```

5. Copy and run the next lines
``` 
develop https://github.com/giulianavll/LogicCircuits.jl
add JuMP
add CSV
add Statistics
activate .
update; precompile
```