function isprerelease(version::VersionNumber)::Bool
    prerelease = version.prerelease
    isempty(prerelease) && return false
    for x in prerelease
        if !isempty(strip(x))
            return true
        end
    end
    return false
end

function compare_versions(master_version::VersionNumber,
                          head_version::VersionNumber;
                          allow_unchanged_prerelease::Bool, 
                          gh_set_output::Bool = get(ENV, "GITHUB_ACTIONS", "") == "true",
                          gh_set_output_io::IO = stdout)::Nothing
    if head_version > master_version
        _gh_set_output_println(gh_set_output, gh_set_output_io, "compare_versions", "success")
        @info("Version number has increased")
    elseif head_version == master_version
        if isprerelease(head_version) && isprerelease(master_version) && allow_unchanged_prerelease
            _gh_set_output_println(gh_set_output, gh_set_output_io, "compare_versions", "success")
            @info("Version number did not change, but it is a prerelease so this is allowed")
        else
            _gh_set_output_println(gh_set_output, gh_set_output_io, "compare_versions", "failure")
            throw(ErrorException("Version number is unchanged, which is not allowed"))
        end
    else
        _gh_set_output_println(gh_set_output, gh_set_output_io, "compare_versions", "failure")
        throw(ErrorException("Version number decreased, which is not allowed"))
    end
    return nothing
end
