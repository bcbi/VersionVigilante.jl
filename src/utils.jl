function with_temp_dir(f::Function)
    original_directory = pwd()
    tmp_dir = mktempdir()
    atexit( () -> rm(tmp_dir; force = true, recursive = true) )
    cd(tmp_dir)
    result = f()
    cd(original_directory)
    rm(tmp_dir; force = true, recursive = true)
    return result
end

function with_cloned_repo(f::Function, repo_url::AbstractString)
    original_directory = pwd()
    result = with_temp_dir() do
        run(`git clone $(repo_url) MYCLONEDREPO`)
        cd("MYCLONEDREPO")
        return f()
    end
    cd(original_directory)
    return result
end

function with_branch(f::Function,
                     repo_url::AbstractString,
                     base_branch::AbstractString,
                     head_branch::AbstractString)
    original_directory = pwd()
    result = with_cloned_repo(repo_url) do
        run(`git checkout $(base_branch)`)
        run(`git branch $(head_branch)`)
        run(`git checkout $(head_branch)`)
        return f()
    end
    cd(original_directory)
    return result
end
