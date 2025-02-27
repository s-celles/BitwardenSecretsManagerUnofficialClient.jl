mutable struct BitwardenClient
    inner::BitwardenSecretsManagerCLIClient

    function BitwardenClient(settings::Union{ClientSettings,Nothing} = nothing)
        # Initialize with empty access token if no settings provided
        if settings === nothing || settings.access_token === nothing
            inner = BitwardenSecretsManagerCLIClient(; access_token = "")
        else
            inner = BitwardenSecretsManagerCLIClient(; access_token = settings.access_token)
        end
        return new(inner)
    end
end

function run(client::BitwardenClient, command::CommandWrapper)
    # Build array of command arguments - each argument must be its own string
    args = String[]

    # Add command first if present
    if command.command !== nothing
        # Split command by spaces to ensure proper argument passing
        append!(args, split(command.command))
    end

    # Add options - each flag and its value as separate arguments
    if command.options.output !== nothing
        push!(args, "--output")
        push!(args, string(command.options.output))
    end

    if command.options.color !== nothing
        push!(args, "--color")
        push!(args, string(command.options.color))
    end

    #if command.options.access_token !== nothing
    #    push!(args, "--access-token")
    #    push!(args, command.options.access_token)
    #end

    if command.options.config_file !== nothing
        push!(args, "--config-file")
        push!(args, command.options.config_file)
    end

    if command.options.profile !== nothing
        push!(args, "--profile")
        push!(args, string(command.options.profile))
    end

    if command.options.server_url !== nothing
        push!(args, "--server-url")
        push!(args, command.options.server_url)
    end

    command.options.help && push!(args, "--help")
    command.options.version && push!(args, "--version")

    return run(client.inner, args)
end

function parse_version(version_string::String)
    # Remove any trailing/leading whitespace
    version_string = strip(version_string)

    # Extract version using regex
    m = match(r"bws\s+(\d+\.\d+\.\d+)", version_string)
    if m === nothing
        throw(ArgumentError("Invalid version string format: $version_string"))
    end

    # Convert to VersionNumber
    return VersionNumber(m.captures[1])
end

function version(client::BitwardenClient)
    options = CommandOptions(version = true)
    command_wrapper = CommandWrapper(options = options, command = nothing)
    response = run(client, command_wrapper)
    return parse_version(response)
end

function help(client::BitwardenClient)
    options = CommandOptions(help = true)
    command_wrapper = CommandWrapper(options = options, command = nothing)
    response = run(client, command_wrapper)
    return response
end
