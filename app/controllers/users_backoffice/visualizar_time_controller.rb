class UsersBackoffice::VisualizarTimeController < UsersBackofficeController
    def time 
        @time = params["time"]

        @times = Equipe.all.where(id: @time)
    end

end
