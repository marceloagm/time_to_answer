class UsersBackoffice::EquipesController < UsersBackofficeController
    before_action :set_user
    before_action :set_equipe, only: [:destroy]
        
    def new
        @equipe = Equipe.new
    end
   
    def index
        @equipes = Equipe.all.where(user_id: @user).page(params[:page]).per(6)
        
    end

    def create
        unless params_equipe[:nome_time].blank?
            unless Equipe.exists?(nome_time: params_equipe[:nome_time], user_id: @user)
                @equipe = Equipe.new(params_equipe)
                    if @equipe.save
                        flash[:success] = "Time Adicionado com Sucesso."
                        redirect_to users_backoffice_equipes_path
                        
                    else
                        redirect_to users_backoffice_equipes_path
                    end 
            else
                redirect_to users_backoffice_equipes_path
                flash[:danger] = "Esse time já está cadastrado na sua conta."
            end
        else
            flash[:danger] = "Por favor todos os campos devem está preenchidos."
            redirect_to users_backoffice_equipes_path
        end
    end

           

    def destroy
        unless @equipe.blank?
            unless Apostum.exists?(equipe_id: @equipe)
                if @equipe.destroy
                admin_statistic = AdminStatistic.find_or_create_by(event: "TOTAL_EQUIPES")
                admin_statistic.value += -1
                admin_statistic.save
                flash[:success] = "Time excluído com sucesso"
                redirect_to users_backoffice_equipes_path 
                else
                    redirect_to users_backoffice_equipes_path
                end 
            else
                redirect_to users_backoffice_equipes_path
                flash[:danger] = "Esse time está participando de uma aposta, para exclui-lo entre em contato conosco."
            end
        
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
