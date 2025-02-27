const ZERO_UUID = UUID("00000000-0000-0000-0000-000000000000")

struct OrganizationID
    id::UUID
end
OrganizationID(id::String) = OrganizationID(UUID(id))
OrganizationID() = OrganizationID(ZERO_UUID)

struct ProjectID
    id::UUID
end
ProjectID(id::String) = ProjectID(UUID(id))
ProjectID() = ProjectID(ZERO_UUID)

struct SecretID
    id::UUID
end
SecretID(id::String) = SecretID(UUID(id))
SecretID() = SecretID(ZERO_UUID)
