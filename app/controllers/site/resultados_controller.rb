class Site::ResultadosController < SiteController
    def index
    
    end

    def visualizar_resultados
        @rodada = params[:rodada]
        @apostas = Apostum.includes(:equipe).all.where(rodada: @rodada)
        
        if @rodada >= "39" && @apostas == nil
            redirect_to users_backoffice_resultados_index_path
        end         
        
    end
end
