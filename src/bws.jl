const BWS_ARTIFACT_NAME = "bitwarden_sdk_sm"

"""
    bws_path()

Return the path to the Bitwarden Secrets Manager CLI executable.
"""
function bws_path()
    # Get the path to our artifact
    artifacts_toml = joinpath(@__DIR__, "..", "Artifacts.toml")

    # Check if the Artifacts.toml file exists
    if !isfile(artifacts_toml)
        error("Artifacts.toml file not found at $(artifacts_toml)")
    end

    artifact_hash = Pkg.Artifacts.artifact_hash(BWS_ARTIFACT_NAME, artifacts_toml)

    if artifact_hash === nothing
        error(
            "Could not find the Bitwarden Secrets Manager artifact. Please build the package with `Pkg.build(\"BitwardenSecretsManagerUnofficialClient\")`.",
        )
    end

    # Get the artifact directory
    artifact_dir = Pkg.Artifacts.artifact_path(artifact_hash)

    # Get the executable path
    exe_name = Sys.iswindows() ? "bws.exe" : "bws"
    exe_path = joinpath(artifact_dir, exe_name)

    if !isfile(exe_path)
        # Try to find it recursively if not in top directory
        for (root, _, files) in walkdir(artifact_dir)
            if exe_name in files
                return joinpath(root, exe_name)
            end
        end
        error("Executable $(exe_name) not found in artifact directory")
    end

    return exe_path
end

"""
    run_bws(args...; kwargs...)

Run the Bitwarden Secrets Manager CLI with the given arguments.
Returns the output as a string.

Example:
```julia
# Get help
output = run_bws("--help")

# Access a secret
output = run_bws("get", "secret", "my-secret-id")
```
"""
function run_bws(args...; kwargs...)
    cmd = `$(bws_path()) $args`
    return read(cmd, String)
end

mutable struct BitwardenSecretsManagerCLIClient
    exe_path::String
    access_token::String
end
function BitwardenSecretsManagerCLIClient(; access_token::String = "")
    exe_path = bws_path()
    BitwardenSecretsManagerCLIClient(exe_path, access_token)
end

"""
# Example
```julia
bws() do exe
    run(`exe, "--version`")
end
```
"""
function bws(f::Function, client::Union{BitwardenSecretsManagerCLIClient,Nothing} = nothing)
    if client === nothing
        client = BitwardenSecretsManagerCLIClient()
    end
    f(client.exe_path)
end

function run(client::BitwardenSecretsManagerCLIClient, parameters::Vector{String})
    exe_path = bws_path()

    # Log for debugging
    @debug "Running command: $exe_path $(join(parameters, " "))"

    # Run command and capture output
    buffer = IOBuffer()
    err_buffer = IOBuffer()

    # Pass parameters as separate arguments to the command
    process = run(
        pipeline(`$exe_path $parameters`, stdout = buffer, stderr = err_buffer),
        wait = true,
    )

    # Return the output as a string
    return String(take!(buffer))
end
