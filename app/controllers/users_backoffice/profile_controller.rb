class UsersBackoffice::ProfileController < UsersBackofficeController
   before_action :set_user
   before_action :verify_password, only: [:update]
   
    def edit
     
    end

    def update
        if @user.update(params_user)
            sign_in(@user, bypass:true) #após alterar a senha do usuario ele faz login de novo
            redirect_to users_backoffice_profile_path, notice: "Usuário atualizado com sucesso"
          else
            render :edit
          end 
    end

    private
    def params_user
        params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)
      end

    def set_user
        @user = User.find(current_user.id)
    end

    def verify_password 
        if params[:user][:password].blank? && params[:user][:password_confirmation].blank?
         params[:user].extract!(:password, :password_confirmation)
         
       end
     end
end
