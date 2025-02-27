using BitwardenSecretsManagerUnofficialClient
using BitwardenSecretsManagerUnofficialClient: ResponseForSecretResponse, ResponseForSecretsResponse, ResponseForSecretsDeleteResponse
using Pkg.Artifacts
using Base: SHA1
using Test

@testset "BitwardenSecretsManagerUnofficialClient" begin
    include("test_bws.jl")
    include("clients/test_main.jl")
    include("clients/test_projects.jl")
    include("clients/test_secrets.jl")
end
