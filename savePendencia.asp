<!--#include file="connect.asp"-->
<!--#include file="Classes/Json.asp"-->
<%
Acao = ref("Acao")
PendenciaID = ref("PendenciaID")
ProcedimentoID = ref("ProcedimentoID")
ComplementoID = ref("ComplementoID")
AgendamentoID = ref("AgendamentoID")
SalvarObservacao = ref("SalvarObservacao")

if ref("SalvarObservacao")&"" = "true" or ref("SalvarObservacao")=true then
    db.execute("INSERT INTO pendenciaadministracaoobservacao (ObsGeral, sysUser,PendenciaID) VALUES ('"&ref("ObsGeral")&"', "&session("User")&", "&PendenciaID&")")
response.end
end if

if Acao = "Salvar" then

    if PendenciaID <> "" then
        procedimentoExcecaoConcorda = ref("procedimento_excecao_concorda")&""

        if procedimentoExcecaoConcorda = "" then 
            procedimentoExcecaoConcorda = 0
        end if

        db.execute("UPDATE pendencias SET sysActive = 1, datacontato = now(), assinouTermoProcedimentosExcecoes='"&procedimentoExcecaoConcorda&"', UnidadeID = "&treatvalzero(ref("UnidadeID"))&", StatusID = "& treatvalzero(ref("StatusID"))&_ 
                    ", PacienteID = "& treatvalzero(ref("PacienteID")) &", Zonas = '"&ref("zona[]")&"' , Requisicao = '"& ref("Requisicao") &"', Contato = '"& ref("Contato") &"', " &_ 
                    "  ObsRequisicao = '"&ref("ObsRequisicao")&"', ObsContato='"&ref("ObsContato")& "'" &_ 
                    " , sysUser = "&session("User")&" WHERE id = "& PendenciaID  )

        db.execute("UPDATE pendencia_data SET sysActive=-1, sysUser="&session("User")&" WHERE PendenciaID = "& PendenciaID)
        db.execute("DELETE FROM pendencia_data WHERE PendenciaID = "& PendenciaID)

        diasSelecionados = ref("diasSelecionados")

        if ref("StatusIDAnterior") <> "" then

            if ref("StatusIDAnterior") <> ref("StatusID") then

                if ref("StatusID") = 6 then

                    set resProcedimentos = db.execute("SELECT pp.id, ProcedimentoID "&_
                                                       " FROM pendencia_procedimentos pp "&_
                                                       " JOIN agendacarrinho ac ON ac.id = pp.BuscaID "&_
                                                       " JOIN procedimentos p ON p.id = ac.ProcedimentoID "&_
                                                      " WHERE pendenciaid = "&PendenciaID&_
                                                      "   AND pp.sysActive = 1")

                    while not resProcedimentos.eof

                        set resExecutante = db.execute("SELECT valor, data, hora, observacoes, executanteid, LocalID "&_
                                                        " FROM pendencia_contatos_executantes "&_
                                                       " WHERE pendenciaprocedimentoid = "&resProcedimentos("id")&_
                                                       " ORDER BY sysDate DESC LIMIT 1")

                        db.execute("INSERT INTO agendamentos (LocalID, PacienteID,                          ProfissionalID,                    Data,                                  Hora,                              TipoCompromissoID,                      StaID, rdValorPlano, ValorPlano,                                  Notas) VALUES "&_
                                                           " ("&resExecutante("LocalID")&", "&treatvalzero(ref("PacienteID"))&", "&resExecutante("executanteid")&", "&mydatenull(resExecutante("data"))&", "&mytime(resExecutante("hora"))&", "&resProcedimentos("ProcedimentoID")&", 1,     'V',          "&treatvalzero(resExecutante("valor"))&", '"&resExecutante("observacoes")&"')")
                        
                        set agendamentoID = db.execute("SELECT LAST_INSERT_ID() AS id")

                        db.execute("INSERT INTO pendenciasagendamentos (PendenciaID, AgendamentoID) VALUES ("&PendenciaID&", "&agendamentoID("id")&")")

                        set agendaCarrinhoID = db.execute("SELECT ac.id "&_
                                                           " FROM pendencia_procedimentos pp "&_
                                                     " INNER JOIN agendacarrinho ac ON ac.id=pp.BuscaID "&_
                                                          " WHERE pp.PendenciaID = "&PendenciaID&_
                                                          "   AND pp.sysActive = 1" )

                        db.execute("UPDATE agendacarrinho SET AgendamentoID = "&agendamentoID("id")&", ProfissionalID = "&resExecutante("executanteid")&" WHERE id = "&agendaCarrinhoID("id"))

                        db.execute("INSERT INTO LogsMarcacoes (PacienteID,                          ProfissionalID,                    ProcedimentoID,                      DataHoraFeito,                          Data,                                  Hora,                              Sta, Usuario,             Motivo, Obs,                        ARX, ConsultaID) "&_
                                                    "  VALUES ("&treatvalzero(ref("PacienteID"))&", "&resExecutante("executanteid")&", "&resProcedimentos("ProcedimentoID")&", DATE_FORMAT(NOW(),'%d/%m/%Y %H:%i:%s'), "&mydatenull(resExecutante("data"))&", "&mytime(resExecutante("hora"))&", 1,   "&session("User")&", 0,      'Agendamento de pendência', 'A', "&agendamentoID("id")&" )")

                        resProcedimentos.movenext
                    wend
                        resProcedimentos.close
                        set resProcedimentos = nothing
                end if

                db.execute("UPDATE pendencia_timeline SET Ativo = -1, DataFim = CURRENT_TIMESTAMP, sysUser="&session("User")&" WHERE Ativo = 1 AND PendenciaID = "&PendenciaID)
                db.execute("INSERT INTO pendencia_timeline (PendenciaID, StatusID, DataInicio, Ativo, sysUser) VALUES ("&PendenciaID&","&ref("StatusID")&",CURRENT_TIMESTAMP,1,"&session("User")&")")

            end if

        end if

        if diasSelecionados <> "" then

            splDias = split(diasSelecionados,"|")

			for ind = 0 to ubound(splDias)
                splCampos = split(splDias(ind),",")
                
                if splCampos(1) = "undefined" then
                    splCampos(1) = ""
                end if

                if splCampos(2) = "undefined" then
                    splCampos(2) = ""
                end if

                db.execute("INSERT INTO pendencia_data (PendenciaID, Data, TurnoManha, TurnoTarde, Observacao, sysUser, sysActive) VALUES ("&PendenciaID&",'"&splCampos(0)&"','"&splCampos(1)&"','"&splCampos(2)&"','"&splCampos(3)&"',"&session("User")&",1)")
            next
        end if

    end if 

elseif Acao = "RemoverProcedimento" then

    ppid = ref("ppid")

    db.execute("UPDATE pendencia_procedimentos SET sysActive = -1, sysUser="&session("User")&" WHERE id = "&ppid)

elseif Acao = "Excluir" then

    db.execute("UPDATE pendencias SET sysActive=-1, sysUser="&session("User")&" WHERE id="&PendenciaID)

elseif Acao = "ExcluirSessao" then

    db.execute("DELETE FROM pendencia_sessao WHERE UsuarioID = "&session("User"))

elseif Acao = "ExcluirSessaoInativa" then

    db.execute("DELETE FROM pendencia_sessao WHERE TIMESTAMPDIFF(MINUTE,`Data`,CURRENT_TIMESTAMP()) >= 5 ")

elseif Acao = "VoltarParaPendencia" then
    

    set PendenciaID = db.execute("SELECT PendenciaID FROM pendenciasagendamentos WHERE AgendamentoID = "&AgendamentoID)

    set resProcedimentos = db.execute("SELECT pp.id, ProcedimentoID "&_
                                                       " FROM pendencia_procedimentos pp "&_
                                                       " JOIN agendacarrinho ac ON ac.id = pp.BuscaID "&_
                                                       " JOIN procedimentos p ON p.id = ac.ProcedimentoID "&_
                                                      " WHERE pendenciaid = "&PendenciaID("PendenciaID")&_ 
                                                      "   AND pp.sysActive = 1")

    set resExecutante = db.execute("SELECT valor, data, hora, observacoes, executanteid "&_
                                                        " FROM pendencia_contatos_executantes "&_
                                                       " WHERE pendenciaprocedimentoid = "&resProcedimentos("id")&_
                                                       " ORDER BY sysDate DESC LIMIT 1")
    
    db.execute("INSERT INTO LogsMarcacoes (PacienteID,                          ProfissionalID,                    ProcedimentoID,                      DataHoraFeito,                          Data,                                  Hora,                              Sta, Usuario,             Motivo, Obs,                        ARX, ConsultaID) "&_
                                "  VALUES ("&treatvalzero(ref("PacienteID"))&", "&resExecutante("executanteid")&", "&resProcedimentos("ProcedimentoID")&", DATE_FORMAT(NOW(),'%d/%m/%Y %H:%i:%s'), "&mydatenull(resExecutante("data"))&", "&mytime(resExecutante("hora"))&", 1,   "&session("User")&", 0,      'Agendamento de pendência', 'A', "&AgendamentoID&" )")
                                
    db.execute("UPDATE pendencias SET sysActive = 1, StatusID = 4, sysUser="&session("User")&" WHERE id = "&PendenciaID("PendenciaID"))
    db.execute("DELETE FROM agendamentos WHERE id = "&AgendamentoID)
    %>
        new PNotify({
            title: 'RETORNO DE PENDÊNCIA',
            text: 'Reabertura de pendência concluída.',
            sticky: true,
            type: 'success',
            delay: 500
        });
    <%
elseif Acao = "InserirProcedimento" then 

     if ComplementoID = "" then 
        db.execute("INSERT INTO `agendacarrinho` (`ProcedimentoID`) VALUES ("&ProcedimentoID&");")
        ultimoID = db.execute("SELECT LAST_INSERT_ID() id;")
        db.execute("INSERT INTO `pendencia_procedimentos` (`PendenciaID`, `BuscaID`, `StatusID`, `sysActive`, sysUser) VALUES ("&PendenciaID&", "&ultimoID("id")&", 1, 1,"&session("User")&");")
    else
        db.execute("INSERT INTO `agendacarrinho` (`ProcedimentoID`, `ComplementoID`) VALUES ("&ProcedimentoID&", "&ComplementoID&");")
        ultimoID = db.execute("SELECT LAST_INSERT_ID() id;")
        db.execute("INSERT INTO `pendencia_procedimentos` (`PendenciaID`, `BuscaID`, `StatusID`, `sysActive`) VALUES ("&PendenciaID&", "&ultimoID("id")&", 1, 1);")
    end if

    'verificar pedencia
    sql = "SELECT COUNT(*) total FROM procedimentosrestricaofrase WHERE ProcedimentoID = "&ProcedimentoID

    set totalRestricoes = db.execute(sql)

    Response.Write recordToJSON(totalRestricoes)
    
end if %>