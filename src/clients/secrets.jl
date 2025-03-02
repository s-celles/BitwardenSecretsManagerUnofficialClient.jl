# SecretsClient
struct SecretsClient
    client::BitwardenClient
end

function get(secrets::SecretsClient, secret_id::SecretID)
    id = secret_id.id
    result =
        run(secrets.client, Command(secrets = SecretsCommand(get = SecretGetRequest(id))))
    return ResponseForSecretResponse(result)
end
get(secrets::SecretsClient, secret_id::UUID) = get(secrets, SecretID(secret_id))
get(secrets::SecretsClient, secret_id::String) = get(secrets, SecretID(secret_id))

function get(secrets::SecretsClient, secret_ids::Vector{SecretID})
    results = ResponseForSecretsResponse[]
    ids = [secret_id.id for secret_id in secret_ids]
    result = run(
        secrets.client,
        Command(secrets = SecretsCommand(get_by_ids = SecretsGetRequest(ids))),
    )
    return ResponseForSecretsResponse(result)  # ToFix
end
get(secrets::SecretsClient, secret_ids::Vector{String}) = get(secrets, SecretID.(secret_ids))

function create!(
    secrets::SecretsClient,
    key::String,
    value::String,
    project_ids::Vector{ProjectID};
    organization_id::Union{OrganizationID,Nothing} = nothing,
    note::String = "",
)
    if organization_id !== nothing
        throw(ArgumentError("Organization ID is not yet supported"))
    end

    result = run(
        secrets.client,
        Command(
            secrets = SecretsCommand(
                create = SecretCreateRequest(
                    key,
                    note,
                    organization_id,
                    value,
                    [project_id.id for project_id in project_ids],
                ),
            ),
        ),
    )
    return ResponseForSecretResponse(result)
end
create!(secrets::SecretsClient, key::String, value::String, project_id::ProjectID; note::String="") =
    create!(secrets, key, value, [project_id], note=note)


function list(secrets::SecretsClient, project_id::ProjectID)
    result = run(
        secrets.client,
        Command(secrets = SecretsCommand(list = SecretProjectIdentifiersRequest(project_id.id))),
    )
    return ResponseForSecretIdentifiersResponse(true, "", result)
end
list(secrets::SecretsClient) = list(secrets, ProjectID())

function update!(
    secrets::SecretsClient,
    id::SecretID;
    key::Union{String,Nothing} = nothing,
    value::Union{String,Nothing} = nothing,
    note::Union{String,Nothing} = nothing,
    project_id::Union{ProjectID,Nothing} = nothing,
    organization_id::OrganizationID = OrganizationID(),
)
    if note === nothing
        # secrets api does not accept empty notes
        note = ""
    end

    result = run(
        secrets.client,
        Command(
            secrets = SecretsCommand(
                update = SecretPutRequest(
                    string(id.id),
                    key,
                    note,
                    value,
                    string(organization_id.id.value),
                    project_id !== nothing ? [project_id.id] : nothing,
                ),
            ),
        ),
    )
    return ResponseForSecretResponse(result)
end

function delete!(secrets::SecretsClient, ids::Vector{UUID})
    result = run(
        secrets.client,
        Command(secrets = SecretsCommand(delete = SecretsDeleteRequest(ids))),
    )
    return ResponseForSecretsDeleteResponse(result)
end
delete!(secrets::SecretsClient, id::SecretID) = delete!(secrets, [id.id])
delete!(secrets::SecretsClient, ids::Vector{SecretID}) = delete!(secrets, [id.id for id in ids])
delete!(secrets::SecretsClient, id::String) = delete!(secrets, [UUID(id)])
delete!(secrets::SecretsClient, ids::Vector{String}) = delete!(secrets, [UUID(id) for id in ids])

function sync!(
    secrets::SecretsClient,
    organization_id::String,
    last_synced_date::Union{String,Nothing} = nothing,
)
    result = run(
        secrets.client,
        Command(
            secrets = SecretsCommand(
                sync = SecretsSyncRequest(organization_id, last_synced_date),
            ),
        ),
    )
    return ResponseForSecretsSyncResponse(result)
end

function _add_access_token(args::Vector{String}, client::BitwardenClient)
    if client.inner.access_token != ""
        push!(args, "--access-token")
        push!(args, client.inner.access_token)
    end
    return args
end

function run(client::BitwardenClient, request::SecretsCommand)
    # CRUD operations for secrets
    if request.create !== nothing # Create a secret
        args = String["secret", "create"]
        args = _add_access_token(args, client)
        if request.create.note != ""
            push!(args, "--note")
            push!(args, request.create.note)
        end
        push!(args, request.create.key)
        push!(args, request.create.value)
        push!(args, string(request.create.project_ids[1]))
        response = run(client.inner, args)
        response = JSON.parse(response)
        return response
    elseif request.get !== nothing  # Read a secret
        args = String["secret", "get", string(request.get.id)]
        args = _add_access_token(args, client)
        response = run(client.inner, args)
        response = JSON.parse(response)
        return response
    elseif request.get_by_ids !== nothing
        responses = []
        for id in request.get_by_ids.ids
            args = String["secret", "get", string(id)]
            args = _add_access_token(args, client)
            response = run(client.inner, args)
            response = JSON.parse(response)
            push!(responses, response)
        end
        return responses
    elseif request.update !== nothing  # Update a secret
        throw(ArgumentError("Update a secret not (yet) implemented"))
        args = String["secret", "edit", string(request.update.id)]
        args = _add_access_token(args, client)
        if request.update.key !== nothing
            push!(args, "--key")
            push!(args, request.update.key)
        end
        if request.update.value !== nothing
            push!(args, "--value")
            push!(args, request.update.value)
        end
        if request.update.note !== nothing
            push!(args, "--note")
            push!(args, request.update.note)
        end
        #if request.update.organization_id !== nothing
        #    push!(args, "--organization-id")
        #    push!(args, request.update.organization_id)
        #end
        if request.update.project_ids !== nothing
            push!(args, "--project-id")
            push!(args, string(request.update.project_ids[1]))
        end
        response = run(client.inner, args)
        response = JSON.parse(response)
        return response
    elseif request.delete !== nothing  # Delete a secret
        args = String["secret", "delete"]
        args = _add_access_token(args, client)
        for id in request.delete.ids
            push!(args, string(id))
        end
        response = run(client.inner, args)
        # response = JSON.parse(response)  # bws secret delete doesn't ouput JSON by default https://github.com/bitwarden/sdk-sm/issues/1220
        m = match(r"(\d) secret[s]? deleted successfully.", response)
        if m === nothing
            throw(ArgumentError("Invalid response format: $response"))
        else
            n_deleted = parse(Int, m.captures[1])
        end
        response = Dict("value" => n_deleted)
        return response
    elseif request.list !== nothing
        #if request.list.organization_id != ""
        #    throw(ArgumentError("Filter by organization ID is currently unsupported"))
        #end
        args = String["secret", "list"]
        if request.list.project_id != UUID(ZERO_UUID)
            push!(args, string(request.list.project_id))
        end
        args = _add_access_token(args, client)
        response = run(client.inner, args)
        response = JSON.parse(response)
        return response
    else
        throw(ArgumentError("Secret $request not (yet) implemented"))
    end
end
