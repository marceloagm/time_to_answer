class ApplicationController < ActionController::Base
    layout :layout_by_resource
    
    add_flash_types :danger, :info, :warning, :success

    protected 

    def layout_by_resource

        if devise_controller?
            "#{resource_class.to_s.downcase}_devise"
        else
            "application"
        end
    end
    
end
