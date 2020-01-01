using VersionVigilante

using Pkg
using Test

const repo_url = "https://github.com/bcbi-test/versionvigilante-integration-test-repo.git"

@testset "VersionVigilante.jl" begin
    @testset "assert.jl" begin
        @test nothing == VersionVigilante.always_assert(true, "")
        @test_throws VersionVigilante.AlwaysAssertionError VersionVigilante.always_assert(false, "")
    end
    @testset "compare_versions.jl" begin
        @testset "isprerelease" begin
            @test !VersionVigilante.isprerelease(v"1")
            @test !VersionVigilante.isprerelease(v"1-")
            @test VersionVigilante.isprerelease(v"1-dev")
            @test VersionVigilante.isprerelease(v"1-PRE")
        end
        @testset "_calculate_increment" begin
            include("test_calculate_increment.jl")
        end

    end
    @testset "main.jl" begin
        for (pass, master_branch, feature_branch, version) in [
                (false, "master-1.0.0", "feature-0.9.9", "0.9.9"), # 1.0.0 -> 0.9.9 is FAIL
                (false, "master-1.0.0", "feature-1.0.0-", "1.0.0-"), # 1.0.0 -> 1.0.0- is FAIL
                (false, "master-1.0.0", "feature-1.0.0-", "1.0.0-DEV"), # 1.0.0 -> 1.0.0-DEV is FAIL
                (false, "master-1.0.0", "feature-1.0.0", "1.0.0"), # 1.0.0 -> 1.0.0 is FAIL
                (true, "master-1.0.0", "feature-1.0.1", "1.0.1"), # 1.0.0 -> 1.0.1 is PASS
                (true, "master-1.0.0", "feature-1.1.0", "1.1.0"), # 1.0.0 -> 1.1.0 is PASS
                (true, "master-1.0.0", "feature-2.0.0", "2.0.0"), # 1.0.0 -> 2.0.0 is PASS
                (true, "master-1.0.0-dev", "feature-1.0.0-dev", "1.0.0-DEV"), # 1.0.0-DEV -> 1.0.0-DEV is PASS if `allow_unchanged_prerelease = true`
                (true, "master-1.0.0-dev", "feature-1.0.0", "1.0.0"), # 1.0.0-DEV -> 1.0.0 is PASS
                ]
            VersionVigilante.with_branch(repo_url, master_branch, feature_branch) do
                rm("Project.toml"; force = true, recursive = true)
                open("Project.toml", "w") do io
                    println(io, "version = \"$(version)\"")
                end
                if pass
                    withenv() do
                        @test nothing == VersionVigilante.main(repo_url;
                                                               master_branch = master_branch)
                    end
                else
                    withenv() do
                        @test_throws ErrorException VersionVigilante.main(repo_url;
                                                                          master_branch = master_branch)
                    end
                end
            end
        end

        for (pass, master_branch, feature_branch, version, allow_unchanged_prerelease) in [
                (false, "master-1.0.0", "feature-1.0.0", "1.0.0", true),
                (false, "master-1.0.0", "feature-1.0.0", "1.0.0", false),
                (true, "master-1.0.0-dev", "feature-1.0.0-dev", "1.0.0-DEV", true), # 1.0.0-DEV -> 1.0.0-DEV is FAIL if `allow_unchanged_prerelease = false`
                (false, "master-1.0.0-dev", "feature-1.0.0-dev", "1.0.0-DEV", false), # 1.0.0-DEV -> 1.0.0-DEV is FAIL if `allow_unchanged_prerelease = false`
                ]
            VersionVigilante.with_branch(repo_url, master_branch, feature_branch) do
                rm("Project.toml"; force = true, recursive = true)
                open("Project.toml", "w") do io
                    println(io, "version = \"$(version)\"")
                end
                if pass
                    withenv() do
                        @test nothing == VersionVigilante.main(repo_url;
                                                               master_branch = master_branch,
                                                               allow_unchanged_prerelease = allow_unchanged_prerelease)
                    end
                else
                    withenv() do
                        @test_throws ErrorException VersionVigilante.main(repo_url;
                                                                          master_branch = master_branch,
                                                                          allow_unchanged_prerelease = allow_unchanged_prerelease)
                    end
                end
            end
        end

        # (master_branch, feature_branch, version)
        _skipping_versions_integration_tests = [("master-1.0.0", "feature-$(x)", "$(x)") for x in ["1.0.2",
                                                                                                   "1.0.3",
                                                                                                   "1.2.0",
                                                                                                   "1.2.1",
                                                                                                   "1.2.2",
                                                                                                   "1.2.3",
                                                                                                   "3.0.0",
                                                                                                   "3.0.1",
                                                                                                   "3.1.0",
                                                                                                   "3.1.1"]]
        for (pass, master_branch, feature_branch, version, allow_skipping_versions) in vcat([(true, y..., true) for y in _skipping_versions_integration_tests],
                                                                                            [(false, y..., false) for y in _skipping_versions_integration_tests])
            VersionVigilante.with_branch(repo_url, master_branch, feature_branch) do
                rm("Project.toml"; force = true, recursive = true)
                open("Project.toml", "w") do io
                    println(io, "version = \"$(version)\"")
                end
                if pass
                    withenv() do
                        @test nothing == VersionVigilante.main(repo_url;
                                                               master_branch = master_branch,
                                                               allow_skipping_versions = allow_skipping_versions)
                    end
                else
                    withenv() do
                        @test_throws ErrorException VersionVigilante.main(repo_url;
                                                                          master_branch = master_branch,
                                                                          allow_skipping_versions = allow_skipping_versions)
                    end
                end
            end
        end

        # printing output to stdout for GitHub Actions
        VersionVigilante.with_branch(repo_url,
                                     "master-1.0.0-dev",
                                     "feature-1.0.0") do
            rm("Project.toml"; force = true, recursive = true)
            open("Project.toml", "w") do io
                println(io, "version = \"1.0.0\"")
            end
            withenv("GITHUB_ACTIONS" => "true") do
                @test nothing == VersionVigilante.main(repo_url;
                                                       master_branch = "master-1.0.0-dev")
            end
            withenv("GITHUB_ACTIONS" => "false") do
                @test nothing == VersionVigilante.main(repo_url;
                                                       master_branch = "master-1.0.0-dev")
            end
        end
    end
    @testset "parse_project.jl" begin
        VersionVigilante.with_temp_dir() do
            rm("Project.toml"; force = true, recursive = true)
            open("Project.toml", "w") do io
                println(io, "version = \"1.2.3\"")
            end
            @test VersionVigilante.get_version() == v"1.2.3"
        end
    end
    @testset "utils.jl" begin
    end
end
