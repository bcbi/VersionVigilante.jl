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
                          set_output::Bool,
                          set_output_io::IO)::Nothing
    if head_version > master_version
        @info("Version number has increased")

        # Set change_type outputs on GH Actions
        if set_output
            # 3-digit versions
            if head_version.major > 0 && master_version.major > 0
                if head_version.major > master_version.major
                    set_actions_output(set_output_io, "change_type", "breaking")
                elseif head_version.minor > master_version.minor
                    set_actions_output(set_output_io, "change_type", "feature")
                elseif head_version.patch > master_version.patch
                    set_actions_output(set_output_io, "change_type", "patch")
                end
            # 2 digit versions
            # Follows Pkg.jl's conventions, not standard semver
            else
                if head_version.minor > master_version.minor
                    set_actions_output(set_output_io, "change_type", "breaking")
                elseif head_version.patch > master_version.patch
                    set_actions_output(set_output_io, "change_type", "feature/patch")
                end
            end
        end

    elseif head_version == master_version
        if isprerelease(head_version) && isprerelease(master_version) && allow_unchanged_prerelease
            @info("Version number did not change, but it is a prerelease so this is allowed")
        else
            throw(ErrorException("Version number is unchanged, which is not allowed"))
        end
    else
        throw(ErrorException("Version number decreased, which is not allowed"))
    end
    return nothing
end
