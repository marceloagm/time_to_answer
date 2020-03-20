class UsersBackoffice::ApostasController < UsersBackofficeController
    before_action :rodadas  
    before_action :set_user
    before_action :set_equipe 
    before_action :set_equipe_rodada_atual, only: [:create]
    before_action :set_action, only: [:create]
    
    def index
        
    end

    def create
        
        unless Apostum.exists?(equipe_id: set_equipe_rodada_atual[:equipe_id], rodada: set_equipe_rodada_atual[:rodada])
        @aposta = Apostum.new(set_equipe_rodada_atual)
        if @aposta.save
            set_total_rodada(set_equipe_rodada_atual[:rodada])
            flash[:success] = "Você está participando dessa aposta."
            redirect_to "/users_backoffice/#{set_action[:action]}"
          else
            
            redirect_to redirect_to "/users_backoffice/#{set_action[:action]}"
         end 

        else
            flash[:danger] = "Esse time já está participando dessa aposta."
            redirect_to "/users_backoffice/#{set_action[:action]}"
        end
       
    end

    def minhas_apostas        
        
        @apostas = Apostum.includes(:equipe).all.where(equipe_id: set_equipe)
          
    end

    def rodada_atual
        
        @rodada = @rodada_prox0 
        @apostas = Apostum.includes(:equipe).all.where(rodada: @rodada)
        @total_aposta = ApostaStatistic.all.where(rodada: @rodada_prox0)

        
    end

    def rodada_prox
        @rodada = @rodada_prox1 
        @apostas = Apostum.includes(:equipe).all.where(rodada: @rodada)
        
    end

    def rodada_dprox
        
        @rodada = @rodada_prox2
        @apostas = Apostum.includes(:equipe).all.where(rodada: @rodada)
    end
    
    def rodada_ddprox
        @rodada = @rodada_prox3 
        @apostas = Apostum.includes(:equipe).all.where(rodada: @rodada)
    end
    
    private

    def set_equipe
        @equipes = Equipe.all.where(user_id: @user)
    end

    def set_user
        @user = User.find(current_user.id)
        
    end

    def rodadas
        @rodada_atual = 6  #será uma consulta a API em qual rodada está
    
        @rodada_prox0 = @rodada_atual 
        @rodada_prox1 = @rodada_atual + 1
        @rodada_prox2 = @rodada_atual + 2
        @rodada_prox3 = @rodada_atual + 3
    end

    def set_equipe_rodada_atual
        params.require(:aposta).permit(:equipe_id, :rodada)
    end

    def set_action
    params.require(:aposta).permit(:action)
    
    end
    def set_total_rodada(rodada)
        aposta_statistic = ApostaStatistic.find_or_create_by(rodada: rodada)
        aposta_statistic.total += 1
        aposta_statistic.save
    end

end
