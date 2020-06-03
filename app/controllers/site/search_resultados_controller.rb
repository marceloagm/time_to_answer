class Site::SearchResultadosController < SiteController
    def resultado_encontrado
        @equipe = params[:term]
        @rodada = params[:rodada]
        @equipes_total = Equipe.all.where(nome_time: @equipe)

        @apostador = Apostum.includes(:equipe).all.where(rodada: @rodada, equipe_id: @equipes_total)
        
    end
end
