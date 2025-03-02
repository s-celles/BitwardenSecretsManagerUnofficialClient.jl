struct ProjectsClient
    client::BitwardenClient
end

function get(projects::ProjectsClient, project_id::ProjectID)
    id = project_id.id
    result = run(
        projects.client,
        Command(projects = ProjectsCommand(get = ProjectGetRequest(id))),
    )
    return ResponseForProjectResponse(result)
end

function create!(projects::ProjectsClient, name::String, organization_id::OrganizationID=OrganizationID())
    org_id = organization_id.id
    result = run(
        projects.client,
        Command(
            projects = ProjectsCommand(
                create = ProjectCreateRequest(name, org_id),
            ),
        ),
    )
    return ResponseForProjectResponse(result)
end

function list(projects::ProjectsClient, organization_id::OrganizationID=OrganizationID())
    org_id = organization_id.id
    result = run(
        projects.client,
        Command(projects = ProjectsCommand(list = ProjectsListRequest(org_id))),
    )
    return ResponseForProjectsResponse(result)
end

function update!(
    projects::ProjectsClient,
    id::ProjectID,
    name::String;
    organization_id::OrganizationID=OrganizationID(),
)
    result = run(
        projects.client,
        Command(
            projects = ProjectsCommand(
                update = ProjectPutRequest(id.id, name, organization_id.id),
            ),
        ),
    )
    return ResponseForProjectResponse(result)
end

function delete!(projects::ProjectsClient, ids::Vector{ProjectID})
    result = run(
        projects.client,
        Command(projects = ProjectsCommand(delete = ProjectsDeleteRequest([id.id for id in ids]))),
    )
    return ResponseForProjectsDeleteResponse(result)
end
delete!(projects::ProjectsClient, id::ProjectID) = delete!(projects, [id])

function run(client::BitwardenClient, request::ProjectsCommand)
    if request.create !== nothing
        args = String["project", "create"]
        args = _add_access_token(args, client)
        push!(args, request.create.name)
        response = run(client.inner, args)
        response = JSON.parse(response)
        return response
    elseif request.delete !== nothing
        args = String["project", "delete"]
        args = _add_access_token(args, client)
        for id in request.delete.ids
            push!(args, string(id))
        end
        response = run(client.inner, args)
        m = match(r"(\d) project[s]? deleted successfully.", response)
        if m === nothing
            throw(ArgumentError("Invalid response format: $response"))
        else
            n_deleted = parse(Int, m.captures[1])
        end
        response = Dict("value" => n_deleted)
        return response
    elseif request.update !== nothing
        args = String["project", "edit"]
        args = _add_access_token(args, client)
        if request.update.name !== nothing
            push!(args, "--name")
            push!(args, request.update.name)
        end
        #if request.update.organization_id !== nothing
        #    push!(args, "--organization-id")
        #    push!(args, request.update.organization_id)
        #end
        push!(args, string(request.update.id))
        response = run(client.inner, args)
        response = JSON.parse(response)
        return response
    elseif request.get !== nothing
        args = String["project", "get", string(request.get.id)]
        args = _add_access_token(args, client)
        response = run(client.inner, args)
        response = JSON.parse(response)
        return response
    elseif request.list !== nothing
        args = String["project", "list"]
        args = _add_access_token(args, client)
        response = run(client.inner, args)
        response = JSON.parse(response)
        return response
    else
        throw(ArgumentError("Project ? Not (yet) implemented"))
    end
end