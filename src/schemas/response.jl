struct ResponseForSecretResponse
    success::Bool
    error_message::String
    data::Union{Dict{String,Any}, String}
end
ResponseForSecretResponse(data) =
    ResponseForSecretResponse(true, "", data)

#function ResponseForSecretResponse(dict::Dict)
#    return ResponseForSecretResponse(
#        get(dict, "success", false),
#        get(dict, "errorMessage", nothing),
#        get(dict, "data", Dict{String,Any}()),
#    )
#end

struct ResponseForSecretsResponse
    success::Bool
    error_message::String
    data::Vector
end
ResponseForSecretsResponse(data::Vector) = ResponseForSecretsResponse(true, "", data)
#function ResponseForSecretsResponse(dict::Dict)
#    return ResponseForSecretsResponse(
#        get(dict, "success", false),
#        get(dict, "errorMessage", nothing),
#        get(dict, "data", Dict{String,Any}()),
#    )
#end


struct ResponseForSecretIdentifiersResponse
    success::Bool
    error_message::String
    data::Any
end
ResponseForSecretIdentifiersResponse(data::Vector) =
    ResponseForSecretIdentifiersResponse(true, "", data)
#function ResponseForSecretIdentifiersResponse(dict::Dict)
#    return ResponseForSecretIdentifiersResponse(
#        get(dict, "success", false),
#        get(dict, "errorMessage", nothing),
#        get(dict, "data", Dict{String,Any}()),
#    )
#end


struct ResponseForSecretsDeleteResponse
    success::Bool
    error_message::String
    data::Dict  # {String,Any}
end
ResponseForSecretsDeleteResponse(data) = ResponseForSecretsDeleteResponse(true, "", data)
#function ResponseForSecretsDeleteResponse(dict::Dict)
#    return ResponseForSecretsDeleteResponse(
#        get(dict, "success", false),
#        get(dict, "errorMessage", nothing),
#        get(dict, "data", Dict{String,Any}()),
#    )
#end


struct ResponseForSecretsSyncResponse
    success::Bool
    error_message::String
    data::Dict{String,Any}
end
#function ResponseForSecretsSyncResponse(dict::Dict)
#    return ResponseForSecretsSyncResponse(
#        get(dict, "success", false),
#        get(dict, "errorMessage", nothing),
#        get(dict, "data", Dict{String,Any}()),
#    )
#end

struct ResponseForProjectResponse
    success::Bool
    error_message::String
    data::Dict{String,Any}
end
ResponseForProjectResponse(data::Dict{String,Any}) = ResponseForProjectResponse(true, "", data)
#function ResponseForProjectResponse(dict::Dict)
#    return ResponseForProjectResponse(
#        get(dict, "success", false),
#        get(dict, "errorMessage", nothing),
#        get(dict, "data", Dict{String,Any}()),
#    )
#end


struct ResponseForProjectsResponse
    success::Bool
    error_message::String
    data::Vector  #Dict{String,Any}
end
ResponseForProjectsResponse(data::Vector) = ResponseForProjectsResponse(true, "", data)

#function ResponseForProjectsResponse(dict::Dict)
#    return ResponseForProjectsResponse(
#        get(dict, "success", false),
#        get(dict, "errorMessage", nothing),
#        get(dict, "data", Dict{String,Any}()),
#    )
#end

struct ResponseForProjectsDeleteResponse
    success::Bool
    error_message::String
    data::Dict{String,Any}
end
ResponseForProjectsDeleteResponse(data) = ResponseForProjectsDeleteResponse(true, "", data)

#function ResponseForProjectsDeleteResponse(dict::Dict)
#    return ResponseForProjectsDeleteResponse(
#        get(dict, "success", false),
#        get(dict, "errorMessage", nothing),
#        get(dict, "data", Dict{String,Any}()),
#    )
#end
