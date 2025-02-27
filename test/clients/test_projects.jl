@testset "projects" begin
    settings = ClientSettings()
    client = BitwardenClient(settings)
    client |> auth |> login_access_token

    #@testset "create" begin
    #    response = client |> projects |> prj -> create!(prj, "DummyProject")
    #    println(response)
    #end

    @testset "get" begin
        project_id = ProjectID("57073045-0bd8-43e3-a0d5-b28c01194c7e")
        response = client |> projects |> prj -> get(prj, project_id)
        @test response.data["name"] == "Project 2"
    end

    @testset "list" begin
        response = client |> projects |> list
        @test length(response.data) > 0
        # this test could be improved by checking the actual data
        # it will need to be updated when the data changes (e.g. new projects are added with create)
    end
end
