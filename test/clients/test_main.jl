using BitwardenSecretsManagerUnofficialClient: AuthClient, SecretsClient
using UUIDs

@testset "BitwardenClient" begin
    @testset "Constructor" begin
        @testset "no param" begin
            client = BitwardenClient()
            @test client isa BitwardenClient
        end

        @testset "passing a ClientSettings" begin
            settings = ClientSettings()
            client = BitwardenClient(settings)
            @test client isa BitwardenClient
        end

        @testset "version" begin
            settings = ClientSettings()
            client = BitwardenClient(settings)
            response = version(client)
            @test response == v"1.0.0"
        end

        @testset "help" begin
            settings = ClientSettings()
            client = BitwardenClient(settings)
            response = help(client)
            @test occursin("Bitwarden Secrets CLI", response)
        end

        @testset "login_access_token" begin
            settings = ClientSettings()
            client = BitwardenClient(settings)
            client |> auth |> login_access_token
            #response =
            #    client |>
            #    auth |>
            #    a -> login_access_token(a, get(ENV, "BWS_ACCESS_TOKEN", "DefaultAccessToken"))

            # println(client.inner.access_token)
        end
    end
end
