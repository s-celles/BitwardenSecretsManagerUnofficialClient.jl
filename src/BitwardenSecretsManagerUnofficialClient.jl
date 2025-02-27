module BitwardenSecretsManagerUnofficialClient

using Pkg
using Pkg.Artifacts

import Base: run
export bws_path, bws, BitwardenSecretsManagerCLIClient

const BWS_ARTIFACT_NAME = "bitwarden_sdk_sm"

"""
    bws_path()

Return the path to the Bitwarden Secret Manager CLI executable.
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
            "Could not find the Bitwarden Secret Manager artifact. Please build the package with `Pkg.build(\"BitwardenSecretsManagerUnofficialClient\")`.",
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

function run(client::BitwardenSecretsManagerCLIClient, parameters...)
    if client.access_token != ""
        parameters = (parameters..., "--access-token \"$(client.access_token)\"")
    end
    println("parameters: $parameters")

    parameters = join(parameters, " ")
    cmd = `$(client.exe_path) $(parameters...)`

    # Execute the command with output capture
    stdout_buffer = IOBuffer()
    stderr_buffer = IOBuffer()

    process = run(pipeline(cmd, stdout = stdout_buffer, stderr = stderr_buffer), wait = true)

    # Check if the command executed successfully
    if process.exitcode != 0
        err_output = String(take!(stderr_buffer))
        throw(
            ErrorException(
                "Command failed with exit code: $(process.exitcode). Error: $err_output",
            ),
        )
    end

    # Retrieve the output as text
    result = String(take!(stdout_buffer))

    return result
end


#"""
#    run_bws(args...; kwargs...)
#
#Run the Bitwarden Secret Manager CLI with the given arguments.
#Returns the output as a string.
#
#Example:
#```julia
## Get help
#output = run_bws("--help")
#
## Access a secret
#output = run_bws("get", "secret", "my-secret-id")
#```
#"""
#function run_bws(args...; kwargs...)
#    cmd = `$(bws_path()) $args`
#    return read(cmd, String)
#end

# Run the build script if this is the first time loading the package
function __init__()
    # Check if artifact exists without throwing errors
    try
        artifacts_toml = joinpath(@__DIR__, "..", "Artifacts.toml")
        if !isfile(artifacts_toml)
            @warn "Artifacts.toml not found at $(artifacts_toml). Run Pkg.build(\"BitwardenSecretsManagerUnofficialClient\") to install."
            return
        end

        artifact_hash = Pkg.Artifacts.artifact_hash(BWS_ARTIFACT_NAME, artifacts_toml)
        if artifact_hash === nothing
            @warn "Bitwarden Secret Manager artifact not found. Run Pkg.build(\"BitwardenSecretsManagerUnofficialClient\") to install."
            return
        end

        # Just check if the artifact directory exists
        artifact_dir = Pkg.Artifacts.artifact_path(artifact_hash)
        exe_name = Sys.iswindows() ? "bws.exe" : "bws"
        exe_path = joinpath(artifact_dir, exe_name)

        if !isfile(exe_path)
            # Check recursively but silently
            found = false
            for (root, _, files) in walkdir(artifact_dir)
                if exe_name in files
                    found = true
                    break
                end
            end

            if !found
                @warn "Bitwarden Secret Manager executable not found in artifact directory. Run Pkg.build(\"BitwardenSecretsManagerUnofficialClient\") to reinstall."
            end
        end
    catch e
        @warn "Error checking Bitwarden Secret Manager installation: $e"
        @warn "You may need to run Pkg.build(\"BitwardenSecretsManagerUnofficialClient\") before using this package."
    end
end

end # module
