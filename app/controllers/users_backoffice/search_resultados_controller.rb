class UsersBackoffice::SearchResultadosController < UsersBackofficeController
    include ActionView::Helpers::NumberHelper
    require 'rest-client'
    require 'json'
    before_action :set_mercado_rodada

    def resultado_encontrado
        @equipe = params[:term]
        @rodada = params[:rodada].to_i
        @equipes_total = Equipe.all.where(nome_time: @equipe)



        unless @equipes_total.blank?

            if @rodada > @rodada_atual ||  @rodada < 1
                    redirect_to users_backoffice_resultados_index_path

            else      

                    if @mercado == "1" && @rodada == @rodada_atual
                        @apostas = Apostum.includes(:equipe).all.where(rodada: @rodada, equipe_id: @equipes_total)
                    end

                    if @mercado == "1" && @rodada != @rodada_atual
                        @equipe_slug = @equipes_total[0]["slug"]
                        atletas_encontrados = SalvarAtletumAnterior.all.where(rodada: @rodada, slug: @equipe_slug)
                        pontos = atletas_encontrados[0]["pontos"]
                        @nome_time_slug = atletas_encontrados[0]["equipe_nome"]
                        @pontos_time_slug = number_with_precision(pontos, precision: 2, separator: '.')

                    end

                    if @mercado == "2" && @rodada != @rodada_atual
                        @equipe_slug = @equipes_total[0]["slug"]
                        atletas_encontrados = SalvarAtletumAnterior.all.where(rodada: @rodada, slug: @equipe_slug)
                        pontos = atletas_encontrados[0]["pontos"]
                        @nome_time_slug = atletas_encontrados[0]["equipe_nome"]
                        @pontos_time_slug = number_with_precision(pontos, precision: 2, separator: '.')
                    end

                    if @mercado == "2" && @rodada == @rodada_atual
                        @equipe_slug = @equipes_total[0]["slug"]
                        atletas_encontrados = Parcial.all.where(rodada: @rodada, slug: @equipe_slug)
                        pontos = atletas_encontrados[0]["pontos"]
                        @nome_time_slug = atletas_encontrados[0]["equipe_nome"]
                        @pontos_time_slug = number_with_precision(pontos, precision: 2, separator: '.')
                    end

                   
            end

        end
        
    end
    private

    def set_mercado_rodada

        buscar_mercado_rodada = SalvarRodadaMercado.all
        @rodada_atual = buscar_mercado_rodada[0]["rodada_atual"].to_i
        @mercado = buscar_mercado_rodada[0]["mercado"]

    end



end
