class UsersBackoffice::TimeCartolaController < UsersBackofficeController
    require 'rest-client'
    require 'json'


    def show

        time_cartola = params[:time_cartola]
        @resp = RestClient::Request.execute( method: :get, url:"https://api.cartolafc.globo.com/times?q=#{time_cartola}" , verify_ssl: false)   
        @resp_verificar = JSON.parse(@resp.body)[0]

        if @resp_verificar == nil
            @time_encontrado = 1
            @cor_verificar = "red"
        else
           @escudo = JSON.parse(@resp.body)[0]["url_escudo_png"] 
           @nome_time = JSON.parse(@resp.body)[0]["nome"] 
           @cartoleiro = JSON.parse(@resp.body)[0]["nome_cartola"]            
           @slug = JSON.parse(@resp.body)[0]["time_id"]
           @cor_verificar = "green"
        end

    end
        

end