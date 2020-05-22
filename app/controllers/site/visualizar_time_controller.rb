class Site::VisualizarTimeController < SiteController
    def time 
        @time = params["time"]
        @times = Equipe.all.where(id: @time)
    end
end
