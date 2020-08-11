class Site::SearchResultadosController < SiteController
    include ActionView::Helpers::NumberHelper
    require 'rest-client'
    require 'json'
    before_action :set_api
    before_action :set_rodada
    before_action :set_mercado

    def resultado_encontrado
        @equipe = params[:term]
        @rodada = params[:rodada].to_i
        @equipes_total = Equipe.all.where(nome_time: @equipe)



        unless @equipes_total.blank?

            if @rodada > @rodada_atual ||  @rodada < 1
                    redirect_to users_backoffice_resultados_index_path

            else      

                    if @mercado == 1 && @rodada == @rodada_atual
                        @apostas = Apostum.includes(:equipe).all.where(rodada: @rodada, equipe_id: @equipes_total)
                    
                    else

                        @equipe_slug = @equipes_total[0]["slug"]

                        url2 = 'https://api.cartolafc.globo.com/time/id/'

                        @times_slug = RestClient.get ("#{url2}#{@equipe_slug}/#{@rodada}")

                        @nome_time_slug = JSON.parse(@times_slug.body)["time"]["nome"]
                        pontos_time_slug_verificar = JSON.parse(@times_slug.body)["pontos"]
                        @pontos_time_slug = number_with_precision(pontos_time_slug_verificar, precision: 2, separator: '.')
                    end
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
