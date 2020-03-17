class UsersBackoffice::EquipesController < UsersBackofficeController
    before_action :set_user
    before_action :set_equipe, only: [:destroy]
        
    def new
        @equipe = Equipe.new
    end
   
    def index
        @equipes = Equipe.all.where(user_id: @user)
    end

    def create
        
        @equipe = Equipe.new(params_equipe)
        if @equipe.save
            redirect_to users_backoffice_equipes_path, notice: "Time Adicionado com Sucesso"
          else
            redirect_to users_backoffice_equipes_path
          end 
    end

    def destroy
        if @equipe.destroy
          redirect_to users_backoffice_equipes_path, notice: "Time excluído com sucesso"
        else
            redirect_to users_backoffice_equipes_path
        end 
      
      end

    private

    def set_user
        @user = User.find(current_user.id)
        
    end

    def set_equipe
        @equipe = Equipe.find(params[:id])
    end

    def params_equipe
        params.require(:equipe).permit(:nome_time, :cartoleiro, :slug, :user_id, :escudo)
               
    end
    
end
