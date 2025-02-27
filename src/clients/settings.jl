struct ClientSettings
    device_type::Union{String,Nothing}
    app_id::Union{String,Nothing}
    user_agent::Union{String,Nothing}

    bws_path::String
    access_token::String
end

function ClientSettings(;
    device_type = nothing,
    app_id = nothing,
    user_agent = "BitwardenSecretsManagerUnofficialClient.jl",
    bws_path = bws_path(),
    access_token = "",
)
    ClientSettings(device_type, app_id, user_agent, bws_path, access_token)
end
