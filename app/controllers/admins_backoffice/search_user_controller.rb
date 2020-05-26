class AdminsBackoffice::SearchUserController < AdminsBackofficeController
    def usuario_encontrado
        @user = params[:term]
        
        @user_encontrado = User.all.where(email: @user)

        
    end
end
