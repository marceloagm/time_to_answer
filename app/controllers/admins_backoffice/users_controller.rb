class AdminsBackoffice::UsersController < AdminsBackofficeController
    def destroy
      user = params[:user]
        deletar = User.destroy(user)
        if deletar.destroy
            redirect_to admins_backoffice_exibir_usuarios_path, notice: "Usuário excluído com sucesso."
            admin_statistic = AdminStatistic.find_or_create_by(event: "TOTAL_USERS")
            admin_statistic.value += -1
            admin_statistic.save
        else
            redirect_to admins_backoffice_exibir_usuarios_path, notice: "Usuário não excluído com sucesso."
        end

    end  

    def exibir_usuarios
        
        @usuarios = User.all.page(params[:page]).per(20)
    end

end
