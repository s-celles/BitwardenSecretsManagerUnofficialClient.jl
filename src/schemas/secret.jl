struct SecretGetRequest
    id::UUID  # or String
end

struct SecretsGetRequest
    ids::Vector{UUID}
end

struct SecretCreateRequest
    key::String
    note::String
    organization_id::Union{UUID,Nothing}
    value::String
    project_ids::Union{Vector{UUID},Nothing}
end

struct SecretPutRequest
    id::String
    key::String
    note::String
    organization_id::String
    value::String
    project_ids::Union{Vector{UUID},Nothing}
end

struct SecretIdentifiersRequest
    organization_id::String
end

struct SecretProjectIdentifiersRequest
    project_id::UUID
end

struct SecretsDeleteRequest
    ids::Vector{UUID}
end

struct SecretsSyncRequest
    organization_id::String
    last_synced_date::Union{String,Nothing}

    function SecretsSyncRequest(organization_id, last_synced_date = nothing)
        new(organization_id, last_synced_date)
    end
end

struct SecretsCommand <: AbstractCommand
    get::Union{SecretGetRequest,Nothing}
    get_by_ids::Union{SecretsGetRequest,Nothing}
    create::Union{SecretCreateRequest,Nothing}
    #list::Union{SecretIdentifiersRequest,Nothing}
    list::Union{SecretProjectIdentifiersRequest,Nothing}
    update::Union{SecretPutRequest,Nothing}
    delete::Union{SecretsDeleteRequest,Nothing}
    sync::Union{SecretsSyncRequest,Nothing}

    function SecretsCommand(;
        get = nothing,
        get_by_ids = nothing,
        create = nothing,
        list = nothing,
        update = nothing,
        delete = nothing,
        sync = nothing,
    )
        new(get, get_by_ids, create, list, update, delete, sync)
    end
end
