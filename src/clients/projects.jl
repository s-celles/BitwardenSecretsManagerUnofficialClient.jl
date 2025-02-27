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
                create = ProjectCreateRequest(name, organization_id),
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
    organization_id::String,
    id::String,
    name::String,
)
    result = run(
        projects.client,
        Command(
            projects = ProjectsCommand(
                update = ProjectPutRequest(id, name, organization_id),
            ),
        ),
    )
    return ResponseForProjectResponse(result)
end

function delete!(projects::ProjectsClient, ids::Vector{String})
    result = run(
        projects.client,
        Command(projects = ProjectsCommand(delete = ProjectsDeleteRequest(ids))),
    )
    return ResponseForProjectsDeleteResponse(result)
end

function run(client::BitwardenClient, request::ProjectsCommand)
    if request.create !== nothing
        throw(ArgumentError("Project create not (yet) implemented"))
    elseif request.delete !== nothing
        throw(ArgumentError("Project delete not (yet) implemented"))
    elseif request.update !== nothing
        throw(ArgumentError("Project update not (yet) implemented"))
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