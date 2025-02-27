module BitwardenSecretsManagerUnofficialClient

using Pkg
using Pkg.Artifacts
using UUIDs
using JSON

import Base: run, get, delete!
export bws_path, run_bws, bws, BitwardenSecretsManagerCLIClient
export ClientSettings, BitwardenClient, version, help
export SecretID, ProjectID, OrganizationID, ZERO_UUID
export create!, update!, list, sync!
export login_access_token, list
export auth, secrets, projects

abstract type AbstractCommand end
abstract type AbstractOption end

include("init.jl")
include("types.jl")
include("bws.jl")
include("command_wrapper.jl")

include("schemas/access_token.jl")
include("schemas/secret.jl")
include("schemas/project.jl")
include("schemas/response.jl")

include("clients/settings.jl")
include("clients/main.jl")
include("clients/auth.jl")
include("clients/secrets.jl")
include("clients/projects.jl")


struct Command <: AbstractCommand
    login_access_token::Union{AccessTokenLoginRequest,Nothing}
    secrets::Union{SecretsCommand,Nothing}
    projects::Union{ProjectsCommand,Nothing}
end
function Command(;
    login_access_token::Union{AccessTokenLoginRequest,Nothing} = nothing,
    secrets::Union{SecretsCommand,Nothing} = nothing,
    projects::Union{ProjectsCommand,Nothing} = nothing,
)
    Command(login_access_token, secrets, projects)
end

function run(client::BitwardenClient, command::Command)
    if command.secrets !== nothing
        run(client, command.secrets)
    elseif command.projects !== nothing
        run(client, command.projects)
    elseif command.login_access_token !== nothing
        run(client, command.login_access_token)
    else
        throw(ArgumentError("Unknown command"))
    end
end

# Shortcuts for convenience and readability
auth = AuthClient
secrets = SecretsClient
projects = ProjectsClient

end # module
