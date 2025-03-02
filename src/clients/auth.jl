struct AuthClient
    client::BitwardenClient
end

function login_access_token(
    auth::AuthClient;
    access_token::String = "",
    state_file::Union{String,Nothing} = nothing,
)
    if access_token == ""
        access_token = get(ENV, "BWS_ACCESS_TOKEN", "NoAccessToken")
    end

    command =
        Command(login_access_token = AccessTokenLoginRequest(access_token, state_file))
    result = run(auth.client, command)

    #auth.client.inner.access_token = access_token
    #return ResponseForAccessTokenLoginResponse(result)
    return result
end

function run(client::BitwardenClient, request::AccessTokenLoginRequest)
    client.inner.access_token = request.access_token

    # What to do with the state file?

    #response = login_access_token(client.inner, request)
    return true
end
