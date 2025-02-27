struct ProjectGetRequest
    id::UUID  # or String?
end

struct ProjectCreateRequest
    name::String
    organization_id::UUID  # or String?
end

struct ProjectsListRequest
    organization_id::UUID  # or String
end

struct ProjectPutRequest
    id::UUID  # or String?
    name::String
    organization_id::UUID  # or String?
end

struct ProjectsDeleteRequest
    ids::Vector{UUID}  # Vector{String}?
end

struct ProjectsCommand <: AbstractCommand
    get::Union{ProjectGetRequest,Nothing}
    create::Union{ProjectCreateRequest,Nothing}
    list::Union{ProjectsListRequest,Nothing}
    update::Union{ProjectPutRequest,Nothing}
    delete::Union{ProjectsDeleteRequest,Nothing}

    ProjectsCommand(;
        get = nothing,
        create = nothing,
        list = nothing,
        update = nothing,
        delete = nothing,
    ) = new(get, create, list, update, delete)
end
