using BitwardenSecretsManagerUnofficialClient
using Pkg.Artifacts
using Base: SHA1
using Test

@testset "BitwardenSecretsManagerUnofficialClient" begin
    # Test that we can get the path to the executable
    @testset "bws_path" begin
        path = bws_path()
        @test isfile(path)

        split_path = splitpath(path)
        artifact_toml = joinpath(@__DIR__, "..", "Artifacts.toml")
        bitwarden_sdk_sm_hash = artifact_hash("bitwarden_sdk_sm", artifact_toml)
        @test SHA1(split_path[end-1]) == bitwarden_sdk_sm_hash
    end

    @testset "run" begin
        # Test that we can run the executable with --help
        #output = run_bws("--help")
        #@test occursin("Bitwarden Secret Manager", output) || occursin("bws", output)

        @testset "no param" begin
            bws() do exe
                # Capture output in a buffer
                buffer = IOBuffer()
                run(pipeline(`$exe --version`, stdout = buffer))
                response = String(take!(buffer))
                @test occursin("bws", response)
                # @test response == "bws 1.0.0"
            end
        end

        @testset "passing a BitwardenSecretsManagerCLIClient" begin
            client = BitwardenSecretsManagerCLIClient()
            bws(client) do exe
                # Capture output in a buffer
                buffer = IOBuffer()
                run(pipeline(`$exe --version`, stdout = buffer))
                response = String(take!(buffer))
                @test occursin("bws", response)
                # @test response == "bws 1.0.0"
            end
        end

        @testset "run command with a BitwardenSecretsManagerCLIClient" begin
            client = BitwardenSecretsManagerCLIClient()
            response = run(client, "--version")
            @test occursin("bws", response)
        end

    end


end
