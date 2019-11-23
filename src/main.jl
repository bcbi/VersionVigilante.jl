import Pkg

function main(repo_url::AbstractString;
              build_directory::AbstractString = pwd(),
              master_branch::AbstractString = "master",
              allow_prerelease_versions::Bool = true)::Nothing
    head_version = get_head_version(repo_url; build_directory = build_directory)
    @info("Head version: $(head_version)")
    master_version = get_upstream_version(repo_url; master_branch = master_branch)
    @info("Master version: $(master_version)")
    compare_versions(master_version,
                     head_version;
                     allow_prerelease_versions = allow_prerelease_versions)
    return nothing
end
