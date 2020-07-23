namespace :dev do


  DEFAULT_PASSWORD = 123456

  desc "Configura o ambiente de desenvolvimento"
  task setup: :environment do
    if Rails.env.development?
      show_spinner("Apagando BD...") { %x(rails db:drop:_unsafe) }
      show_spinner("Criando BD...") { %x(rails db:create) }
      show_spinner("Migrando BD...") { %x(rails db:migrate) }
      show_spinner("Criando o Administrador padrão...") { %x(rails dev:add_default_admin) }
      show_spinner("Criando o Usuário padrão...") { %x(rails dev:add_default_user) }
     # show_spinner("Criando o Equipe padrão...") { %x(rails dev:add_default_equipe) }
      
      show_spinner("Adiciona o valor total das rodadas...") { %x(rails dev:add_default_value_aposta) }
      #show_spinner("Criando o Equipe Aposta Teste...") { %x(rails dev:add_default_equipe_aposta) }
    else
      puts "Você não está em ambiente de desenvolvimento!"
    end
  end

  desc "Adiciona o administrador padrão"
  task add_default_admin: :environment do
      Admin.create!(
         email: 'admin@admin.com',
         password: DEFAULT_PASSWORD,
         password_confirmation: DEFAULT_PASSWORD
      )
   end
 
   desc "Adiciona o usuário padrão"
    task add_default_user: :environment do
      User.create!(
        email: 'user@user.com',
        password: DEFAULT_PASSWORD,
        password_confirmation: DEFAULT_PASSWORD
      )
    end

    desc "Adiciona o equipe padrao"
    task add_default_equipe: :environment do
      Equipe.create!(
        nome_time: "Ligas do Cartola Teste Site",
        cartoleiro: "Admin Padrao",
        slug: "admin",
        user_id: 1,
        escudo: "Admin"
      )
    end

    desc "Adiciona o valor total das rodadas"
    task add_default_value_aposta: :environment do
      
       for contador in 1..39 do 
        ApostaStatistic.create!(
           rodada: "#{contador}",
           total: 0
        )
     end
    end

    desc "Adiciona Equipes na Aposta"
    task add_default_equipe_aposta: :environment do
      
       for contador in 1..50 do 
        Apostum.create!(
           rodada: "1",
           equipe_id: 1,
           equipe_nome: "teste#{contador}4"
        )
        aposta_statistic = ApostaStatistic.find_or_create_by(rodada: "1")
        aposta_statistic.total += 1
        aposta_statistic.save
     end
    end

  private

  def show_spinner(msg_start, msg_end = "Concluído!")
    spinner = TTY::Spinner.new("[:spinner] #{msg_start}")
    spinner.auto_spin
    yield
    spinner.success("(#{msg_end})")    
  end
end


