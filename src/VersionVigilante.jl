module VersionVigilante

import Pkg

include("compare_versions.jl")
include("main.jl")
include("parse_project.jl")
include("set_output.jl")
include("utils.jl")

end # module
