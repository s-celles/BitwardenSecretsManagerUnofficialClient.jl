@testset "projects" begin
    settings = ClientSettings()
    client = BitwardenClient(settings)
    client |> auth |> login_access_token

    # @testset "create" begin
    #    response = client |> projects |> prj -> create!(prj, "DummyProject")
    # end

    project_id = ProjectID("57073045-0bd8-43e3-a0d5-b28c01194c7e")

    @testset "get" begin
        response = client |> projects |> prj -> get(prj, project_id)
        @test response.data["name"] in ["Test proj 2", "Test project 2"]
    end

    @testset "update" begin
        response = client |> projects |> prj -> get(prj, project_id)
        if response.data["name"] == "Test proj 2"
            response = client |> projects |> prj -> update!(prj, project_id, "Test project 2")
            @test response.data["name"] == "Test project 2"
        else
            response = client |> projects |> prj -> update!(prj, project_id, "Test proj 2")
            @test response.data["name"] == "Test proj 2"
        end
    end

    @testset "list" begin
        response = client |> projects |> list
        @test length(response.data) > 0
        # this test could be improved by checking the actual data
        # it will need to be updated when the data changes (e.g. new projects are added with create)
    end

    # @testset "delete" begin
    #     project_id = ProjectID("2a0b6cc7-e936-4d88-a044-b29400b02dea")
    #     response = client |> projects |> prj -> delete!(prj, project_id)
    #     @test response.success
    # end
end
