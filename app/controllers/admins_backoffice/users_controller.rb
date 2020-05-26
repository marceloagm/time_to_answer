class AdminsBackoffice::UsersController < AdminsBackofficeController
    before_action :set_user, only: [:edit]


    def edit
    end
  
    def update
        @user = User.find(params_user[:id])    
          if @user.update(params_user)
            redirect_to admins_backoffice_users_path(:user =>params_user[:id])
            flash[:success] = "Usuário atualizado com sucesso."
          else
            redirect_to admins_backoffice_users_path
          end 
    end

    def exibir_usuarios
        
        @usuarios = User.all.page(params[:page]).per(20)
    end

    private

    def params_user
      params.require(:user).permit(:id, :email)
    end


    def set_user
        @user = User.find(params[:user])
    end

end
