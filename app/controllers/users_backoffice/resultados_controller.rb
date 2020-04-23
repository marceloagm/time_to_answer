class UsersBackoffice::ResultadosController < UsersBackofficeController
    before_action :set_rodada
    def index 
            
    end
    def visualizar_resultados
        
        rodada = params[:rodada].to_i
        @apostas = Apostum.includes(:equipe).all.where(rodada: rodada)
        
        if rodada > @rodada_atual ||  rodada < 1
            redirect_to users_backoffice_resultados_index_path
        end
          
    end
    private
    def set_rodada
        @rodada_atual = 1
    end
end
