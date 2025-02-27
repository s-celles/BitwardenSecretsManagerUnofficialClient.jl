# BitwardenSecretsManagerUnofficialClient

[![Build Status](https://github.com/s-celles/BitwardenSecretsManagerUnofficialClient.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/s-celles/BitwardenSecretsManagerUnofficialClient.jl/actions/workflows/CI.yml?query=branch%3Amain)

An unofficial Julia client for the Bitwarden Secrets Manager CLI.

> ### ⚠️ Development Status
> 
> This project is in **alpha stage**. The API is not stable and may change significantly between versions without deprecation warnings. Breaking changes will be noted in release notes.
> 
> **Not recommended for production environments.**

## Features

- 🔑 Access to Bitwarden Secrets Manager functionality
- 🔄 Type-safe Julia interface with automatic type conversions
- 🛠️ Support for organizations, projects, and secrets management
- 📦 Automatic CLI binary installation and management
- 🧩 Pipeline-friendly API with functional composition

## Prerequisites

- Julia 1.10 or higher
- Internet connection for initial CLI binary download
- A Bitwarden account with Secrets Manager access
- Valid Bitwarden access token (for authentication)

## Installation

To install the package, use Julia's package manager:

```julia
using Pkg
Pkg.add("BitwardenSecretsManagerUnofficialClient")
```

The package will automatically download and install the appropriate Bitwarden Secrets Manager CLI binary for your platform during installation.

## Usage

### Basic usage

```julia
using BitwardenSecretsManagerUnofficialClient

# Create a client
client = BitwardenClient()

# Get version information 
version(client)  # Returns VersionNumber("1.0.0")

# Get help
help(client)  # Returns CLI help text
```

### Authentication

```julia
using BitwardenSecretsManagerUnofficialClient

# Create client with settings
settings = ClientSettings(access_token="your_access_token")
client = BitwardenClient(settings)

# Or authenticate after creation
client |> auth |> login_access_token
```

### Managing Secrets

```julia
using BitwardenSecretsManagerUnofficialClient
using UUIDs

# Create a client
client = BitwardenClient()

# List secrets
client |> secrets |> sc -> list(sc, org_id)

# List secrets in an organization
org_id = OrganizationID("your_organization_id")
client |> secrets |> sc -> list(sc, org_id)

# Other secret operations
secrets_client = SecretsClient(client)
# or
secrets_client = client |> secrets

# Create secret
create!(secrets_client, 
    OrganizationID("org-uuid"), 
    "secret-key",
    "secret-value", 
    "optional note")

# Get secret
get(secrets_client, SecretID("secret-uuid"))

# Update secret
update!(secrets_client,
    OrganizationID("org-id"),
    SecretID("secret-id"),
    "new-key",
    "new-value",
    "new note")

# Delete secrets
delete!(secrets_client, SecretID.(["secret-id-1", "secret-id-2"]))
```

## Managing Projects

## Handling IDs

The package provides type-safe ID handling:

```julia
# Creating IDs from strings or UUIDs
org_id = OrganizationID("40f36664-5d09-4193-8445-b1c500f3d1ba")
project_id = ProjectID(UUID("57073045-0fd8-43e3-a0d5-b28c01194c7e"))
secret_id = SecretID("efb07cd0-b18a-49ce-81c9-b291f1590661")

# Converting between types as needed
uuid_value = UUID(secret_id)
string_value = string(org_id)
```

## Troubleshooting
### Common Issues

1. Authentication Errors
- Verify that your access token is valid and not expired
- Ensure environment variables are properly set if using them
2. Command Execution Errors
- Check the Bitwarden CLI version with version(client)
- Try running help(client) to verify the CLI is working
3. Connectivity Issues
- Ensure your firewall allows the CLI to connect to Bitwarden servers
- Verify your internet connection is working

### Contributing
Contributions are welcome! Please feel free to submit a Pull Request.

### License
This Julia package is licensed under the MIT License - see the LICENSE file for details.

Note: The Bitwarden Secrets Manager CLI binary (`bws`) is distributed under the BITWARDEN SOFTWARE DEVELOPMENT KIT LICENSE AGREEMENT.
