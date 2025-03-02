@testset "secrets" begin
    settings = ClientSettings()
    client = BitwardenClient(settings)
    client |> auth |> login_access_token

    org_id = OrganizationID(get(ENV, "BWS_ORG_ID", ZERO_UUID))
    #println("org_id= $org_id")

    @testset "create and delete" begin
        # Create a secret in a project
        project_id = ProjectID("57073045-0bd8-43e3-a0d5-b28c01194c7e")
        response = client |> secrets |> sc -> create!(sc, "test_secret", "test_value", [project_id], note="test_note")
        @test response isa ResponseForSecretResponse
        @test response.success
        @test response.data["value"] == "test_value"
        @test response.data["note"] == "test_note"

        # Delete the secret
        secret_id = SecretID(response.data["id"])
        response = client |> secrets |> sc -> delete!(sc, secret_id)
        @test response isa ResponseForSecretsDeleteResponse
        @test response.success
        @test response.data["value"] == 1  # Number of secrets deleted

        # Create several secrets in a project and delete them
        response1 = client |> secrets |> sc -> create!(sc, "test_secret1", "test_value1", project_id, note="test_note1")
        @test response1 isa ResponseForSecretResponse
        @test response1.success
        @test response1.data["value"] == "test_value1"
        @test response1.data["note"] == "test_note1"

        response2 = client |> secrets |> sc -> create!(sc, "test_secret2", "test_value2", project_id)
        @test response2.success
        @test response2.data["value"] == "test_value2"
        @test response2.data["note"] == ""

        response3 = client |> secrets |> sc -> create!(sc, "test_secret3", "test_value3", project_id)
        @test response3.success
        @test response3.data["value"] == "test_value3"
        @test response3.data["note"] == ""

        response = client |> secrets |> sc -> delete!(sc, [response1.data["id"], response2.data["id"], response3.data["id"]])
        @test response isa ResponseForSecretsDeleteResponse
        @test response.success
        @test response.data["value"] == 3  # Number of secrets deleted
    end
    
    @testset "create several secrets" begin
        project_id = ProjectID("57073045-0bd8-43e3-a0d5-b28c01194c7e")
        # Create 2 secrets
        response1 = client |> secrets |> sc -> create!(sc, "aaa", "AAA", project_id)
        response2 = client |> secrets |> sc -> create!(sc, "bbb", "BBB", project_id)

        @testset "get one" begin
            secret_id = response1.data["id"]  # String
            response = client |> secrets |> sc -> get(sc, secret_id)
            @test response isa ResponseForSecretResponse
            @test response.success
            @test response.data["value"] == "AAA"

            # should also work with a SecretID
            secret_id = SecretID(response2.data["id"])
            response = client |> secrets |> sc -> get(sc, secret_id)
            @test response.data["value"] == "BBB"

            # should also work with a UUID
            secret_id = UUID(response2.data["id"])
            response = client |> secrets |> sc -> get(sc, secret_id)
            @test response.data["value"] == "BBB"
        end

        #@testset "update" begin
        #    secret_id = SecretID(response2.data["id"])
        #    response = client |> secrets |> sc -> update!(sc, secret_id,
        #        key = "b_b",
        #        value = "B_B",
        #        note = "b note",
        #        organization_id = org_id,
        #        project_id = project_id,
        #    )
        #    @test response isa ResponseForSecretResponse
        #    @test response.success
        #    response = client |> secrets |> sc -> get(sc, secret_id)
        #    # Secret should be updated
        #    println(response)
        #    @test response.data["key"] == "b_b"
        #    @test response.data["value"] == "B_B"
        #    @test response.data["note"] == "b note"
        #end

        @testset "get several" begin
            secret_ids = SecretID.([
                response1.data["id"],
                response2.data["id"],
            ])
            response = client |> secrets |> sc -> get(sc, secret_ids)
            @test response isa ResponseForSecretsResponse
            @test response.success
            @test length(response.data) >= 2
            @test response.data[1]["value"] == "AAA"
            @test response.data[2]["value"] == "BBB"

            # should also work with strings (UUIDs)
            secret_ids = [
                response1.data["id"],
                response2.data["id"],
            ]
            response = client |> secrets |> sc -> get(sc, secret_ids)
            @test response isa ResponseForSecretsResponse
            @test response.success
            @test length(response.data) >= 2
            @test response.data[1]["value"] == "AAA"
            @test response.data[2]["value"] == "BBB"
        end

        @testset "list" begin
            # response = client |> secrets |> list
            # response = client |> SecretsClient |> sc -> list(sc, org_id)  #uncomment this line to test with org_id
            response = client |> secrets |> sc -> list(sc, project_id)
            @test length(response.data) > 0
            @test response.data[1]["value"] == "AAA"
            @test response.data[2]["value"] == "BBB"

            @testset "delete several" begin
                ids = [data["id"] for data in response.data]
                response = client |> secrets |> sc -> delete!(sc, ids)
                @test response isa ResponseForSecretsDeleteResponse
                @test response.success
                @test response.data["value"] == 2
            end    

        end

    end

end
