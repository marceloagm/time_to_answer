class UsersBackoffice::ResultadosController < UsersBackofficeController
    before_action :set_rodada
    def index 
            
    end
    def visualizar_resultados
        
        rodada = params[:rodada].to_i
        @apostas = Apostum.includes(:equipe).all.where(rodada: rodada).page(params[:page]).per(20)

        @ppp = params["page"].to_i 
        if @ppp == 0
            @contador = 1
        else
            @contador = (params["page"].to_i * 20) - 19
        end

        
        if rodada > @rodada_atual ||  rodada < 1
            redirect_to users_backoffice_resultados_index_path
        end
          
    end
    private
    def set_rodada
        @rodada_atual = 38
    end
end
