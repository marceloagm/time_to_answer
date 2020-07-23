class Site::WelcomeController < SiteController
    include ActionView::Helpers::NumberHelper
    require 'rest-client'
    require 'json'

  def index
    url = 'https://api.cartolafc.globo.com/mercado/status'
    @resp = RestClient.get "#{url}"  


    if user_signed_in?
        redirect_to users_backoffice_welcome_index_path
    end
    
    if admin_signed_in?
        redirect_to admins_backoffice_welcome_index_path
    end
    
    @rodada_atual = JSON.parse(@resp.body)["rodada_atual"]

    @rodada_prox0 = @rodada_atual 
    @rodada_prox1 = @rodada_atual + 1
    @rodada_prox2 = @rodada_atual + 2
    @rodada_prox3 = @rodada_atual + 3

    
    @total_aposta0 = ApostaStatistic.all.where(rodada: @rodada_prox0).first.attributes["total"]
    @valor_total01 = (@total_aposta0*10).to_f
    @valor_total02 = ((@valor_total01*15)/100).to_f
    @valor_total_aposta0 = number_to_currency(@valor_total01 - @valor_total02)

    if @rodada_atual <= 37
    @total_aposta1 = ApostaStatistic.all.where(rodada: @rodada_prox1).first.attributes["total"]
    @valor_total11 = (@total_aposta1*10).to_f
    @valor_total12 = ((@valor_total11*15)/100).to_f
    @valor_total_aposta1 = number_to_currency(@valor_total11 - @valor_total12)
    end

    if @rodada_atual <= 36
    @total_aposta2 = ApostaStatistic.all.where(rodada: @rodada_prox2).first.attributes["total"]
    @valor_total21 = (@total_aposta2*10).to_f
    @valor_total22 = ((@valor_total21*15)/100).to_f
    @valor_total_aposta2 = number_to_currency(@valor_total21 - @valor_total22)
    end

    if @rodada_atual <= 35
    @total_aposta3 = ApostaStatistic.all.where(rodada: @rodada_prox3).first.attributes["total"]
    @valor_total31 = (@total_aposta3*10).to_f
    @valor_total32 = ((@valor_total31*15)/100).to_f
    @valor_total_aposta3 = number_to_currency(@valor_total31 - @valor_total32)
    end
 
    @mercado = JSON.parse(@resp.body)["status_mercado"]
    if @mercado == 1
        @mercado_path = users_backoffice_rodada_atual_path
        @botao_text = "Participar"
        @botao_cor = "primary"
        @f = "20"
    else
        @mercado_path = @mercado_path = site_resultados_visualizar_resultados_path(:rodada => @rodada_prox0)
        @botao_text = "Acompanhar Resultados"
        @botao_cor = "success"
        @f = "15"
    end

end

end
