import Pkg

function main(repo_url::AbstractString;
              build_directory::AbstractString = pwd(),
              master_branch::AbstractString = "master",
              allow_unchanged_prerelease::Bool = true,
              set_output::Bool = get(ENV, "GITHUB_ACTIONS", "") == "true",
              set_output_io::IO = stdout)::Nothing
    head_version = get_head_version(repo_url; build_directory = build_directory)  
    master_version = get_upstream_version(repo_url; master_branch = master_branch)
    @info("Master version: $(master_version)")
    @info("Head version: $(head_version)")
    if set_output
        set_actions_output(set_output_io, "master_version", "v$master_version")
        set_actions_output(set_output_io, "head_version", "v$head_version")
        # println(set_output_io, "::set-output name=master_version::v$(master_version)")
        # println(set_output_io, "::set-output name=pr_version::v$(head_version)")
    end 
    compare_versions(master_version,
                     head_version;
                     allow_unchanged_prerelease = allow_unchanged_prerelease,
                     set_output = set_output,
                     set_output_io = set_output_io)
    return nothing
end
