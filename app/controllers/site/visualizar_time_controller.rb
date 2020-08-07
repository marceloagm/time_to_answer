class Site::VisualizarTimeController < SiteController
    require 'rest-client'
    require 'json'
    before_action :set_api
    before_action :set_rodada
    before_action :set_mercado


    def time 

        @rodada = params["rodada"].to_i
        

        if @rodada > @rodada_atual ||  @rodada < 1
            redirect_to site_resultados_index_path
        else 


            if @mercado == 1 && @rodada == @rodada_atual
                #busca time no banco de dados
                time = params["time"]
                @times = Equipe.all.where(id: time)   
                    if @times.blank?
                        redirect_to site_resultados_index_path
                    end

            else 
                #busca time no cartola
                slug = params["slug"]
                url2 = 'https://api.cartolafc.globo.com/time/id/'
                @resp = RestClient.get ("#{url2}#{slug}/#{@rodada}")
                @nome_time_slug = JSON.parse(@resp.body)["time"]["nome"]
                @nome_cartoleiro_slug = JSON.parse(@resp.body)["time"]["nome_cartola"]
                @pontos_time_slug = JSON.parse(@resp.body)["time"]["tipo_estampa_camisa"] # aqui será pontuação, só mudar para pontos

                encontrar_slug = Equipe.all.where(slug: slug)  
                @nome_escudo_slug = encontrar_slug[0]["escudo"]

            end
        end

    end

    private

    def set_api

        url = 'https://api.cartolafc.globo.com/mercado/status'
        @resp = RestClient.get "#{url}"   

    end


    def set_mercado
        @mercado = JSON.parse(@resp.body)["status_mercado"]

    end

    def set_rodada
           
        @rodada_atual = JSON.parse(@resp.body)["rodada_atual"]

    end
end
