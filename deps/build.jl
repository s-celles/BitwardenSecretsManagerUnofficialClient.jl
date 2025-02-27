using Pkg
using Pkg.Artifacts
using Pkg.BinaryPlatforms
using Downloads
using SHA

# Detect platform 
platform = Pkg.BinaryPlatforms.HostPlatform()
arch_val = Pkg.BinaryPlatforms.arch(platform)
os_val = Pkg.BinaryPlatforms.os(platform)

# Artifacts location - make sure this is in the project root
artifacts_toml = joinpath(@__DIR__, "..", "Artifacts.toml")
if isfile(artifacts_toml)
    println("Removing existing Artifacts.toml")
    rm(artifacts_toml, force = true)
end

# Define the binary name based on OS
function get_exe_name()
    if Sys.iswindows()
        return "bws.exe"
    else
        return "bws"
    end
end

# Map of URLs and SHAs for each platform
function get_download_info()
    if arch_val == "x86_64" && os_val == "windows"
        return (
            url = "https://github.com/bitwarden/sdk-sm/releases/download/bws-v1.0.0/bws-x86_64-pc-windows-msvc-1.0.0.zip",
            sha256 = "69b8d0fb2facc8cec4dd2b8157a3496ecaaa376ee1b0fd822012192ce7437505",
        )
    elseif arch_val == "x86_64" && os_val == "linux"
        return (
            url = "https://github.com/bitwarden/sdk-sm/releases/download/bws-v1.0.0/bws-x86_64-unknown-linux-gnu-1.0.0.zip",
            sha256 = "9077fb7b336a62abc8194728fea8753afad8b0baa3a18723fc05fc02fdb53568",
        )
    elseif arch_val == "aarch64" && os_val == "linux"
        return (
            url = "https://github.com/bitwarden/sdk-sm/releases/download/bws-v1.0.0/bws-aarch64-unknown-linux-gnu-1.0.0.zip",
            sha256 = "20a3dcb9e3ce7716a1dc3c0e1c76cea9d5e2bf75094cbb5aad54ced4304929cb",
        )
    elseif arch_val == "x86_64" && os_val == "macos"
        return (
            url = "https://github.com/bitwarden/sdk-sm/releases/download/bws-v1.0.0/bws-x86_64-apple-darwin-1.0.0.zip",
            sha256 = "7e06cbc0f3543dd68585a22bf1ce09eca1d413322aa22554a713cf97de60495a",
        )
    elseif arch_val == "aarch64" && os_val == "macos"
        return (
            url = "https://github.com/bitwarden/sdk-sm/releases/download/bws-v1.0.0/bws-aarch64-apple-darwin-1.0.0.zip",
            sha256 = "5dd716878e5627220aa254cbe4e41e978f226f72d9117fc195046709db363e20",
        )
    else
        error("Unsupported platform: arch=$(arch_val), os=$(os_val)")
    end
end

println("Building for platform: $(arch_val)-$(os_val)")
download_info = get_download_info()

# Create a temporary directory for the download
download_dir = mktempdir()
zip_path = joinpath(download_dir, "bws.zip")

# Download the zip file
println("Downloading from $(download_info.url)")
Downloads.download(download_info.url, zip_path)

# Extract the zip file
println("Extracting to $(download_dir)")
if Sys.iswindows()
    run(
        `powershell -Command "Expand-Archive -Path '$(zip_path)' -DestinationPath '$(download_dir)' -Force"`,
    )
else
    run(`unzip -o -q '$(zip_path)' -d '$(download_dir)'`)
end

# List files after extraction for debugging
exe_files = readdir(download_dir)
println("Files in download directory: $(exe_files)")

# Create the artifact
artifact_hash = create_artifact() do artifact_dir
    exe_name = get_exe_name()

    # Look for the executable directly
    exe_path = joinpath(download_dir, exe_name)
    if isfile(exe_path)
        println("Found executable at $(exe_path)")
        cp(exe_path, joinpath(artifact_dir, exe_name))
    else
        # Copy all files except the zip
        for file in exe_files
            if file != "bws.zip"
                src_path = joinpath(download_dir, file)
                dest_path = joinpath(artifact_dir, file)

                if isdir(src_path)
                    cp(src_path, dest_path, force = true)
                else
                    cp(src_path, dest_path)
                end
            end
        end

        # Try to find the executable recursively
        found = false
        for (root, _, files) in walkdir(artifact_dir)
            for file in files
                if file == exe_name
                    found = true
                    exe_path = joinpath(root, file)
                    println("Found executable at $(exe_path)")
                    # If not at top level, copy it there
                    if root != artifact_dir
                        cp(exe_path, joinpath(artifact_dir, exe_name), force = true)
                    end
                    break
                end
            end
            found && break
        end

        if !found
            println("Warning: Couldn't find executable $(exe_name)")
            println("Files in artifact directory:")
            for (root, dirs, files) in walkdir(artifact_dir)
                println("  Directory: $(root)")
                for file in files
                    println("    - $(file)")
                end
            end
        end
    end

    # Set executable permissions on Unix
    if !Sys.iswindows()
        exe_final = joinpath(artifact_dir, exe_name)
        if isfile(exe_final)
            chmod(exe_final, 0o755)
        end
    else
        # Windows-specific permission handling
        exe_final = joinpath(artifact_dir, exe_name)
        if isfile(exe_final)
            println("Ensuring proper permissions for: $(exe_final)")

            try
                println("Unblocking file with PowerShell: $(exe_final)")
                run(`powershell -Command "Unblock-File -Path \"$(exe_final)\""`)
                println("File unblocked successfully")
            catch e
                println("Warning: Could not unblock file: $e")
            end

            # Get current username from environment
            current_user = ENV["USERNAME"]
            println(
                "3. Setting explicit READ and EXECUTE permissions for user: $(current_user)",
            )
            run(`cmd /c icacls "$(exe_final)" /reset`)
            run(`cmd /c icacls "$(exe_final)" /grant:r "$(current_user):(RX)"`)

        end
    end
end

# Bind the artifact
println("Binding artifact $(artifact_hash) to bitwarden_sdk_sm in $(artifacts_toml)")
bind_artifact!(
    artifacts_toml,
    "bitwarden_sdk_sm",
    artifact_hash,
    force = true,
    download_info = [(download_info.url, download_info.sha256)],
)

# Verify the artifact can be found - fix this part
verify_hash = Pkg.Artifacts.artifact_hash("bitwarden_sdk_sm", artifacts_toml)
if verify_hash !== nothing
    println("Artifact successfully bound and can be found")
    println("Artifact directory: $(Pkg.Artifacts.artifact_path(verify_hash))")
else
    error("Failed to bind artifact! Verification returned nothing.")
end

println("Bitwarden Secret Manager CLI binary installed successfully.")
