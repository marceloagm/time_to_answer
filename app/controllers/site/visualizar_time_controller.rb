class Site::VisualizarTimeController < SiteController
    def time 
        @time = params["time"]
        @times = Equipe.all.where(nome_time: @time)
    end
end
