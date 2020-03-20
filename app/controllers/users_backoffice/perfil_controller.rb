class UsersBackoffice::PerfilController < UsersBackofficeController
    before_action :set_user
    before_action :verify_password, only: [:update]
    
    
    def edit
        
    end

    def update
             
        if @user.update(params_user)
          flash[:success] = "Usuário atualizado com sucesso."
          redirect_to users_backoffice_perfil_path
        else
          render :edit
        end 
  end

    private

    def set_user
        @user = User.find(current_user.id)
    end
    def params_user
        params.require(:user).permit(:nome, :sobrenome, :rg, :email, :password, :password_confirmation)
      end

      def verify_password 
        if params[:user][:password].blank? && params[:user][:password_confirmation].blank?
         params[:user].extract!(:password, :password_confirmation)
         
       end
     end
end
