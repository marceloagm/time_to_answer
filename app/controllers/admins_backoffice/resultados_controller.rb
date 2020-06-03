class AdminsBackoffice::ResultadosController < AdminsBackofficeController
    before_action :set_rodada
    before_action :set_aposta, only: [:edit]
    def edit
       
    end

    def update
        rodada_antiga = params["apostum"]["rodada_antiga"]
        @aposta = Apostum.find(params_aposta[:id])
        if @aposta.update(params_aposta)
            flash[:success] = "Aposta atualizada com sucesso."
            aposta_statistic = ApostaStatistic.find_or_create_by(rodada: params_aposta[:rodada])
            aposta_statistic.total += 1
            aposta_statistic.save

            aposta_statistic2 = ApostaStatistic.find_or_create_by(rodada: rodada_antiga)
            aposta_statistic2.total -= 1
            aposta_statistic2.save

            redirect_to admins_backoffice_resultados_visualizar_resultados_path(:rodada => rodada_antiga)
          else
            render :edit
          end 
    end

    def visualizar_resultados
        
        rodada = params[:rodada].to_i
        @apostas = Apostum.includes(:equipe).all.where(rodada: rodada).page(params[:page]).per(20)
                
         
    end

    private
    def set_rodada
        @rodada_atual = 38
    end

    def set_aposta        
        @aposta = Apostum.find(params[:id])
    end

    def params_aposta
        params.require(:apostum).permit(:id, :rodada, :nome_time)
     end
     
end
