using VersionVigilante

using Pkg
using Test

const repo_url = "https://github.com/bcbi-test/versionvigilante-integration-test-repo.git"

@testset "VersionVigilante.jl" begin
    @testset "compare_versions.jl" begin
        @test !VersionVigilante.isprerelease(v"1")
        @test !VersionVigilante.isprerelease(v"1-")
        @test VersionVigilante.isprerelease(v"1-dev")
        @test VersionVigilante.isprerelease(v"1-PRE")
    end
    @testset "main.jl" begin
        # 1.0.0 -> 0.9.9 is FAIL
        VersionVigilante.with_branch(repo_url,
                                     "master-1.0.0",
                                     "feature-0.9.9") do
            rm("Project.toml"; force = true, recursive = true)
            open("Project.toml", "w") do io
                println(io, "version = \"0.9.9\"")
            end
    #         withenv() do
    #             @test_throws ErrorException VersionVigilante.main(repo_url;
    #                                                               master_branch = "master-1.0.0")
    #         end
        end

        # 1.0.0 -> 1.0.0- is FAIL
        VersionVigilante.with_branch(repo_url,
                                     "master-1.0.0",
                                     "feature-1.0.0-") do
            rm("Project.toml"; force = true, recursive = true)
            open("Project.toml", "w") do io
                println(io, "version = \"1.0.0-\"")
            end
    #         withenv() do
    #             @test_throws ErrorException VersionVigilante.main(repo_url;
    #                                                               master_branch = "master-1.0.0")
    #         end
        end

        # 1.0.0 -> 1.0.0-DEV is FAIL
        VersionVigilante.with_branch(repo_url,
                                     "master-1.0.0",
                                     "feature-1.0.0-") do
            rm("Project.toml"; force = true, recursive = true)
            open("Project.toml", "w") do io
                println(io, "version = \"1.0.0-DEV\"")
            end
    #         withenv() do
    #             @test_throws ErrorException VersionVigilante.main(repo_url;
    #                                                               master_branch = "master-1.0.0")
    #         end
        end

        # 1.0.0 -> 1.0.0 is FAIL
        VersionVigilante.with_branch(repo_url,
                                     "master-1.0.0",
                                     "feature-1.0.0") do
            rm("Project.toml"; force = true, recursive = true)
            open("Project.toml", "w") do io
                println(io, "version = \"1.0.0\"")
            end
    #         withenv() do
    #             @test_throws ErrorException VersionVigilante.main(repo_url;
    #                                                               master_branch = "master-1.0.0")
    #         end
        end
        VersionVigilante.with_branch(repo_url,
                                     "master-1.0.0",
                                     "feature-1.0.0") do
            rm("Project.toml"; force = true, recursive = true)
            open("Project.toml", "w") do io
                println(io, "version = \"1.0.0\"")
            end
    #         withenv() do
    #             @test_throws ErrorException VersionVigilante.main(repo_url;
    #                                                               master_branch = "master-1.0.0",
    #                                                               allow_unchanged_prerelease = true)
    #         end
        end
        VersionVigilante.with_branch(repo_url,
                                     "master-1.0.0",
                                     "feature-1.0.0") do
            rm("Project.toml"; force = true, recursive = true)
            open("Project.toml", "w") do io
                println(io, "version = \"1.0.0\"")
            end
    #         withenv() do
    #             @test_throws ErrorException VersionVigilante.main(repo_url;
    #                                                               master_branch = "master-1.0.0",
    #                                                               allow_unchanged_prerelease = false)
    #         end
        end

        # 1.0.0 -> 1.0.1 is PASS
        VersionVigilante.with_branch(repo_url,
                                     "master-1.0.0",
                                     "feature-1.0.1") do
            rm("Project.toml"; force = true, recursive = true)
            open("Project.toml", "w") do io
                println(io, "version = \"1.0.1\"")
            end
    #         withenv() do
    #             @test nothing == VersionVigilante.main(repo_url;
    #                                                    master_branch = "master-1.0.0")
    #         end
        end

        # 1.0.0 -> 1.1.0 is PASS
        VersionVigilante.with_branch(repo_url,
                                     "master-1.0.0",
                                     "feature-1.1.0") do
            rm("Project.toml"; force = true, recursive = true)
            open("Project.toml", "w") do io
                println(io, "version = \"1.1.0\"")
            end
    #         withenv() do
    #             @test nothing == VersionVigilante.main(repo_url;
    #                                                    master_branch = "master-1.0.0")
    #         end
        end

        # 1.0.0 -> 2.0.0 is PASS
        VersionVigilante.with_branch(repo_url,
                                     "master-1.0.0",
                                     "feature-2.0.0") do
            rm("Project.toml"; force = true, recursive = true)
            open("Project.toml", "w") do io
                println(io, "version = \"2.0.0\"")
            end
    #         withenv() do
    #             @test nothing == VersionVigilante.main(repo_url;
    #                                                    master_branch = "master-1.0.0")
    #         end
        end

        # 1.0.0-DEV -> 1.0.0-DEV is PASS if `allow_unchanged_prerelease = true`
        VersionVigilante.with_branch(repo_url,
                                     "master-1.0.0-dev",
                                     "feature-1.0.0-dev") do
            rm("Project.toml"; force = true, recursive = true)
            open("Project.toml", "w") do io
                println(io, "version = \"1.0.0-DEV\"")
            end
    #         withenv() do
    #             @test nothing == VersionVigilante.main(repo_url;
    #                                                    master_branch = "master-1.0.0-dev")
    #         end
        end
        VersionVigilante.with_branch(repo_url,
                                     "master-1.0.0-dev",
                                     "feature-1.0.0-dev") do
            rm("Project.toml"; force = true, recursive = true)
            open("Project.toml", "w") do io
                println(io, "version = \"1.0.0-DEV\"")
            end
    #         withenv() do
    #             @test nothing == VersionVigilante.main(repo_url;
    #                                                    master_branch = "master-1.0.0-dev", allow_unchanged_prerelease = true)
    #         end
        end

        # 1.0.0-DEV -> 1.0.0-DEV is FAIL if `allow_unchanged_prerelease = false`
        VersionVigilante.with_branch(repo_url,
                                     "master-1.0.0-dev",
                                     "feature-1.0.0-dev") do
            rm("Project.toml"; force = true, recursive = true)
            open("Project.toml", "w") do io
                println(io, "version = \"1.0.0-DEV\"")
            end
    #         withenv() do
    #             @test_throws ErrorException VersionVigilante.main(repo_url;
    #                                                               master_branch = "master-1.0.0-dev",
    #                                                               allow_unchanged_prerelease = false)
    #         end
        end

        # 1.0.0-DEV -> 1.0.0 is PASS
        VersionVigilante.with_branch(repo_url,
                                     "master-1.0.0-dev",
                                     "feature-1.0.0") do
            rm("Project.toml"; force = true, recursive = true)
            open("Project.toml", "w") do io
                println(io, "version = \"1.0.0\"")
            end
    #         withenv() do
    #             @test nothing == VersionVigilante.main(repo_url;
    #                                                    master_branch = "master-1.0.0-dev")
    #         endp
        end

        # printing output to stdout for GitHub Actions
        VersionVigilante.with_branch(repo_url,
                                     "master-1.0.0-dev",
                                     "feature-1.0.0") do
            rm("Project.toml"; force = true, recursive = true)
            open("Project.toml", "w") do io
                println(io, "version = \"1.0.0\"")
            end
    #         withenv("GITHUB_ACTIONS" => "true") do
    #             @test nothing == VersionVigilante.main(repo_url;
    #                                                    master_branch = "master-1.0.0-dev")
    #         end
    #         withenv("GITHUB_ACTIONS" => "false") do
    #             @test nothing == VersionVigilante.main(repo_url;
    #                                                    master_branch = "master-1.0.0-dev")
    #         end
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
