class AdminsBackoffice::EquipesController < AdminsBackofficeController
    
    before_action :set_equipe, only: [:edit]

    def edit
        
    end

    def update
        @equipe = Equipe.find(params_equipe[:id])
        if @equipe.update(params_equipe)
            flash[:success] = "Usuário atualizado com sucesso."
            redirect_to admins_backoffice_equipes_path(:id =>params_equipe[:id])
          else
            render :edit
          end 
        
    end


    def visualizar_equipes

        @equipes = Equipe.includes(:user).all.page(params[:page]).per(20)
        
    end
    private
    def set_equipe
        @equipe = Equipe.find(params[:id])
    end

    def params_equipe
       params.require(:equipe).permit(:id, :nome_time, :cartoleiro, :slug, :user_id, :escudo)
    end

end
