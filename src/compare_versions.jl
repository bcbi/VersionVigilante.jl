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

function _calculate_increment(before::VersionNumber,
                              after::VersionNumber)::VersionNumber
    before_first3 = VersionNumber(before.major,
                                  before.minor,
                                  before.patch)
    after_first3 = VersionNumber(after.major,
                                 after.minor,
                                 after.patch)
    # @debug("before: ", before)
    # @debug("before_first3: ", before_first3)
    # @debug("after:", after)
    # @debug("after_first3:", after_first3)
    always_assert(after > before, "after > before")
    always_assert(after_first3 >= before_first3,
                  "after_first3 >= before_first3")
    if before.major == after.major
        if before.minor == after.minor
            always_assert(after.patch >= before.patch,
                          "after.patch >= before.patch")
            return VersionNumber(0, 0, after.patch - before.patch)
        else
            always_assert(after.minor >= before.minor,
                          "after.minor >= before.minor")
            return VersionNumber(0,
                                 after.minor - before.minor,
                                 after.patch - 0)
        end
    else
        always_assert(after.major >= before.major,
                      "after.major >= before.major")
        return VersionNumber(after.major - before.major,
                             after.minor - 0,
                             after.patch - 0)
    end
end

function check_version_increment(master_version::VersionNumber,
                                 head_version::VersionNumber;
                                 allow_skipping_versions::Bool,
                                 gh_set_output::Bool = get(ENV, "GITHUB_ACTIONS", "") == "true",
                                 gh_set_output_io::IO = stdout)::Nothing
    always_assert(head_version > master_version, "head_version > master_version")
    _gh_set_output_println(gh_set_output, gh_set_output_io, "compare_versions", "success")
    @info("Version number has increased")
    increment = _calculate_increment(master_version, head_version)
    if increment in [v"0.0.0", v"0.0.1", v"0.1.0", v"1.0.0"]
        @info("Increment is good",
              master_version,
              head_version,
              increment)
    else
        if allow_skipping_versions
            @warn("Increment is bad, but `allow_skipping_versions` is true, so we will allow it",
                  master_version,
                  head_version,
                  increment,
                  allow_skipping_versions)
        else
            @error("Increment is bad",
                  master_version,
                  head_version,
                  increment,
                  allow_skipping_versions)
            error("Bad increment")
        end
    end
    return nothing
end

function compare_versions(master_version::VersionNumber,
                          head_version::VersionNumber;
                          allow_unchanged_prerelease::Bool,
                          allow_skipping_versions::Bool,
                          gh_set_output::Bool = get(ENV, "GITHUB_ACTIONS", "") == "true",
                          gh_set_output_io::IO = stdout)::Nothing
    if head_version > master_version
        check_version_increment(master_version,
                                head_version;
                                allow_skipping_versions = allow_skipping_versions,
                                gh_set_output = gh_set_output,
                                gh_set_output_io = gh_set_output_io)
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
