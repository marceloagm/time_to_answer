# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

set :output, 'log/whenever.log'
 #whenever --update-crontab --set environment=development - codigo para arivar alterações na schedule
# Chamando de 7 em 7 minuto
every 5.minute do

 #runner "Parcial.rodada_atual"
 
end

every 6.minute do

    #runner "Parcial.salvar_equipe"
    
end

every 11.minute do

    #runner "Parcial.salvar_atletas_pontuados"

end

every 13.minute do

    #runner "Parcial.parciais"

end
 