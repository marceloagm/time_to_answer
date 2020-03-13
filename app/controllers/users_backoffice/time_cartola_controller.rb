class UsersBackoffice::TimeCartolaController < UsersBackofficeController
    
    def show
        @time_cartola = TIME_CARTOLA.new(params[:time_cartola])
    end
        

end
