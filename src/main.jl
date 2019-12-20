import Pkg

function main(repo_url::AbstractString;
              build_directory::AbstractString = pwd(),
              master_branch::AbstractString = "master",
              allow_unchanged_prerelease::Bool = true,
              gh_set_output::Bool = get(ENV, "GITHUB_ACTIONS", "") == "true",
              gh_set_output_io::IO = stdout)::Nothing
    head_version = get_head_version(repo_url; build_directory = build_directory)
    master_version = get_upstream_version(repo_url; master_branch = master_branch)
    @info("Master version: $(master_version)")
    @info("Head version: $(head_version)")
    _gh_set_output_println(gh_set_output, gh_set_output_io, "master_version", "v$(master_version)")
    _gh_set_output_println(gh_set_output, gh_set_output_io, "pr_version", "v$(head_version)")
    compare_versions(master_version,
                     head_version;
                     allow_unchanged_prerelease = allow_unchanged_prerelease,
                     gh_set_output = gh_set_output,
                     gh_set_output_io = gh_set_output_io)
    return nothing
end
