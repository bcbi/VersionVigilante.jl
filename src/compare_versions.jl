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
                          allow_prerelease_versions::Bool)::Nothing
    if head_version > master_version
        @info("Version number has increased")
    elseif head_version == master_version
        if isprerelease(head_version) && isprerelease(master_version) && allow_prerelease_versions
            @info("Version number did not change, but it is a prerelease so this is allowed")
        else
            throw(ErrorException("Version number is unchanged, which is not allowed"))
        end
    else
        throw(ErrorException("Version number decreased, which is not allowed"))
    end
    return nothing
end
