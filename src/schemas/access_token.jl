struct AccessTokenLoginRequest
    access_token::String
    state_file::Union{String,Nothing}

    AccessTokenLoginRequest(access_token, state_file = nothing) =
        new(access_token, state_file)
end
