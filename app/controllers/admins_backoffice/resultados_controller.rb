class AdminsBackoffice::ResultadosController < AdminsBackofficeController
    before_action :set_rodada

    def visualizar_resultados
        
        rodada = params[:rodada].to_i
        @apostas = Apostum.includes(:equipe).all.where(rodada: rodada).page(params[:page]).per(20)

                 
         
    end


    def set_rodada
        @rodada_atual = 38
    end

end
