struct CommandOptions <: AbstractOption
    output::Union{String,Nothing}
    color::Union{String,Nothing}
    access_token::Union{String,Nothing}
    config_file::Union{String,Nothing}
    profile::Union{String,Nothing}
    server_url::Union{String,Nothing}
    help::Bool
    version::Bool
end
function CommandOptions(;
    output::Union{String,Nothing} = nothing,
    color::Union{String,Nothing} = nothing,
    access_token::Union{String,Nothing} = nothing,
    config_file::Union{String,Nothing} = nothing,
    profile::Union{String,Nothing} = nothing,
    server_url::Union{String,Nothing} = nothing,
    help::Bool = false,
    version::Bool = false,
)
    CommandOptions(
        output,
        color,
        access_token,
        config_file,
        profile,
        server_url,
        help,
        version,
    )
end

struct CommandWrapper
    options::CommandOptions
    command::Union{String,Nothing}
end

function CommandWrapper(; options::CommandOptions, command::Union{String,Nothing} = nothing)
    CommandWrapper(options, command)
end
