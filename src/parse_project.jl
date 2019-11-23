import Pkg

function get_version(filename::AbstractString)::VersionNumber
    project = Pkg.TOML.parsefile(filename)
    return VersionNumber(project["version"])
end

function get_version()::VersionNumber
    filename = joinpath(pwd(), "Project.toml")
    return get_version(filename)
end

function get_upstream_version(repo_url::AbstractString;
                              master_branch::AbstractString)::VersionNumber
    original_directory = pwd()
    result = with_cloned_repo(repo_url) do
        run(`git checkout $(master_branch)`)
        result = get_version()
    end
    cd(original_directory)
    return result
end

function get_head_version(repo_url::AbstractString;
                          build_directory::AbstractString)::VersionNumber
    original_directory = pwd()
    cd(build_directory)
    result = get_version()
    cd(original_directory)
    return result
end
