class AdminsBackoffice::SearchEquipeController < AdminsBackofficeController
    def equipe_encontrada
        @equipe = params[:term]
        
        @equipe_encontrada = Equipe.all.where(nome_time: @equipe)
        
    end
end
