class UsersBackoffice::ProfileController < UsersBackofficeController
   before_action :set_user
   before_action :verify_password, only: [:update]
   
    def edit
      @user.build_user_profile if @user.user_profile.blank?
    end

    def update
        if @user.update(params_user)
            bypass_sign_in(@user) #após alterar a senha do usuario ele faz login de novo
            unless params_user[:user_profile_attributes][:avatar]
                redirect_to users_backoffice_profile_path, notice: "Usuário atualizado com sucesso"
            end

          else
            render :edit
          end 
    end

    private
    def params_user
        params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, 
        user_profile_attributes: [:id, :address, :gender, :birthdate, :avatar])
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
