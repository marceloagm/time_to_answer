class UsersBackoffice::TimeCartolaController < UsersBackofficeController
    require 'rest-client'
    require 'json'


    def show

        email = params[:email]
        password = params[:password]


        uri = URI.parse("https://login.globo.com/api/authentication")
        request = Net::HTTP::Post.new(uri)
        request.content_type = "application/json"
        request["Cache-Control"] = "no-cache"
        request["User-Agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.89 Safari/537.36"
        request["Data"] = "teste"
        request["Datatype"] = "json"
        request.body = JSON.dump({
        "payload" => {
            "email" => "#{email}",
            "password" => "#{password}",
            "serviceId" => 4728
        }
        })
        
        req_options = {
        use_ssl: uri.scheme == "https",
        }
        
        @response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
        end
        
        glb_time = JSON.parse(@response.body)["glbId"]
        
        uri2 = URI.parse("https://api.cartolafc.globo.com/auth/time")
        request2 = Net::HTTP::Get.new(uri2)
        request2["Cache-Control"] = "no-cache"
        request2["X-Glb-Token"] = "#{glb_time}"

        req_options2 = {
        use_ssl: uri.scheme == "https",
        }

        @response2 = Net::HTTP.start(uri2.hostname, uri2.port, req_options2) do |http|
        http.request(request2)
        end

        
        if @response2.code == "401"
            @time_encontrado = 1
            @cor_verificar = "red"
        else
            equipe_encontrada = JSON.parse(@response2.body)
            @nome_time = equipe_encontrada["time"]["nome"]
            @cartoleiro = equipe_encontrada["time"]["nome_cartola"]
            @escudo = equipe_encontrada["time"]["url_escudo_png"]
            @slug = equipe_encontrada["time"]["time_id"]
            @cor_verificar = "green"

        end

    end
        

end
