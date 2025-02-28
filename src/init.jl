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
            @warn "Bitwarden Secrets Manager artifact not found. Run Pkg.build(\"BitwardenSecretsManagerUnofficialClient\") to install."
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
                @warn "Bitwarden Secrets Manager executable not found in artifact directory. Run Pkg.build(\"BitwardenSecretsManagerUnofficialClient\") to reinstall."
            end
        end
    catch e
        @warn "Error checking Bitwarden Secrets Manager installation: $e"
        @warn "You may need to run Pkg.build(\"BitwardenSecretsManagerUnofficialClient\") before using this package."
    end
end
