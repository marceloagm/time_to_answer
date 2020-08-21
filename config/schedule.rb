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
set :bundle_command, "/vagrant/time_to_answer/bin/bundle exec"
set :output, 'log/whenever.log'
 #whenever --update-crontab --set environment=development - codigo para arivar alterações na schedule
# Chamando de 7 em 7 minuto
every 1.minute do

    runner "Parcial.rodada_atual"
 
end

every 2.minute do

    runner "Parcial.salvar_equipe"
    
end

every 3.minute do

    runner "Parcial.salvar_atletas_pontuados"

end

every 5.minute do

    runner "Parcial.parciais"

end
 