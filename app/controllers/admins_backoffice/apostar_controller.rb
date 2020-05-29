class AdminsBackoffice::ApostarController < AdminsBackofficeController

    def apostar_manual
        unless params["equipe_id"].blank?
            equipe_verificar_salvar = Equipe.all.where(id: params["equipe_id"])
                equipe_nome_salvar = equipe_verificar_salvar[0]["nome_time"]
                equipe_salvar = Hash["equipe_id"=> params["equipe_id"], "rodada"=> params["rodada"], "equipe_nome"=> equipe_nome_salvar]
                    unless Apostum.exists?(equipe_id: params["equipe_id"], rodada: params["rodada"])
                        @aposta = Apostum.new(equipe_salvar)
                            if @aposta.save
                                equipe_pagamento_aprovado = Hash["equipe_id"=> params["equipe_id"], "rodada"=> params["rodada"], "status"=> "Aprovado"]
                                @rodada = params["rodada"]
                                pagamento_aprovado = StatusPagamento.new(equipe_pagamento_aprovado)
                                pagamento_aprovado.save
                                set_total_rodada(@rodada)
                                flash[:success] = "Time adicionado a aposta com sucesso."
                                redirect_to "/admins_backoffice/apostar"
                            else
                                redirect_to "/admins_backoffice/apostar"
                            end 
                    else
                        flash[:danger] = "Esse time já está participando dessa aposta"
                        redirect_to "/admins_backoffice/apostar"
                    end
        end
    end

    private
    def set_total_rodada(rodada)
        aposta_statistic = ApostaStatistic.find_or_create_by(rodada: rodada)
        aposta_statistic.total += 1
        aposta_statistic.save
    end


end