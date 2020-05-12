class UsersBackoffice::VisualizarTimeController < UsersBackofficeController
    def time 
        @time = params["time"]
        @times = Equipe.all.where(nome_time: @time)
    end

end
