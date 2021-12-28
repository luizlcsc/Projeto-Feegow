<%

function verificaSevicoIntegracaoLaboratorial(unidade)
    'Verifica se possui o servico adicional integração laboratorial habilitado e qual versão
    sql = "SELECT max(ServicoID) id FROM cliniccentral.clientes_servicosadicionais cs WHERE cs.LicencaID = '"&replace(session("Banco"),"clinic","")&"' AND  cs.ServicoID in(24,48) AND cs.`Status`=4"
    set rs1 = db.execute(sql)
    if not rs1.eof then
        if rs1("id") = 24 then 
           if unidade <> "" then
               set labAutenticacao = db.execute("SELECT * FROM labs_autenticacao WHERE UnidadeID="&treatvalzero(unidade))
               if labAutenticacao.eof then
                    verificaSevicoIntegracaoLaboratorial = "0|0"
               else
                    verificaSevicoIntegracaoLaboratorial = "1|1"
               end if 
            else 
               verificaSevicoIntegracaoLaboratorial = "1|1"
            end if 
        else 
            if unidade <> "" then
               set labAutenticacao = db.execute("SELECT * FROM slabs_autenticacao WHERE UnidadeID="&treatvalzero(unidade))
               if labAutenticacao.eof then
                    verificaSevicoIntegracaoLaboratorial = "0|0"
               else
                    verificaSevicoIntegracaoLaboratorial = "1|2"
               end if 
            else 
               verificaSevicoIntegracaoLaboratorial = "1|2"
            end if 
        end if
    else 
        verificaSevicoIntegracaoLaboratorial = "0|0"
    end if 
end function 

function verificaIntegracaoLaboratorial(tabela, id)
    ' x -Não possui o serviço habilitado 
    ' 0- Não disponibiliza a integração  (cinza)
    ' 1- abre seleção de laboratórios  (vermelho)
    ' 2- abre modal de impressão de etiquetas (verde)
    
    'Verifica se possui o servico adicional habilitado 
    sql = "SELECT max(ServicoID) id FROM cliniccentral.clientes_servicosadicionais cs WHERE cs.LicencaID = '"&replace(session("Banco"),"clinic","")&"' AND  cs.ServicoID in (24,48) AND cs.`Status`=4"
    set rs1 = db.execute(sql)
    if not rs1.eof then
        if rs1("id") = 24 then 
           versaoIl = "1"
        else 
           versaoIl = "2"
        end if
        'Verifica se a Unidade Possui credencial cadastrada
        sqlAutenticacao = "SELECT id FROM slabs_autenticacao sla WHERE sla.UnidadeID = '"&session("UnidadeID")&"' and sla.sysactive = 1"
        set rs2 = db.execute(sqlAutenticacao)
        if not rs2.eof then
            'Verifica se já existe integracao feita para a conta 
            sqlTabela = "SELECT * FROM slabs_solicitacoes AS sls WHERE sls.tabelaid = '"&id&"' AND  sls.tabela ='"&tabela&"' AND sls.success = 'S' AND sls.statusid=1 and sls.tiposolicitacao='1';"
            set rs3 = db.execute(sqlTabela)
            if not rs3.eof then
                verificaIntegracaoLaboratorial = "2|"&rs3("id")&"|"&versaoIl
            else
                select case tabela
                    ' Verifica se existem procedimentos possíveis de serem integrados na conta
                    case "sys_financialinvoices"
                        sqlTable = "SELECT ii.id "&_
                                    " FROM itensinvoice ii "&_
                                    " INNER JOIN labs_procedimentos_laboratorios lpl ON lpl.procedimentoID = ii.ItemID "&_
                                    " INNER JOIN procedimentos proc ON proc.id = ii.ItemID "&_
                                    " WHERE ii.invoiceid  = '"& id &"' "&_
                                    " AND ii.Executado = 'S' "&_
                                    " AND proc.IntegracaoPleres = 'S' "&_
                                    " AND proc.sysActive = 1"
                    case "tissguiasadt"
                        sqlTable =  " SELECT tpg.id qtd "&_
                                    " FROM tissprocedimentossadt tpg "&_
                                    " INNER JOIN labs_procedimentos_laboratorios lep ON lep.ProcedimentoID = tpg.procedimentoid "&_
                                    " INNER JOIN procedimentos proc ON proc.id = tpg.procedimentoid "&_
                                    " WHERE tpg.GuiaID = '"& id &"' "&_
                                    " AND proc.IntegracaoPleres = 'S' "&_
                                    " AND proc.sysActive = 1 " 
                    case else
                        sqlTable = ""
                        exit function                
                end select 
                if sqlTable = "" then
                    verificaIntegracaoLaboratorial = "0|Não foi possível determinar a tabela de origem da integração|" &versaoIl
                else
                    set rs4 = db.execute(sqlTable)
                    if not rs4.eof then
                        verificaIntegracaoLaboratorial = "1|0|"&versaoIl
                    else
                        verificaIntegracaoLaboratorial = "0|Não existem procedimentos nesta conta habilitados para Integração laboratorial. Verifique se existem ítens executados e se estão todos vinculados a exames no laboratório."&versaoIl 'Não existem procedimentos para integrar
                    end if
                end if
            end if 
        else
            verificaIntegracaoLaboratorial = "0|Não existem credenciais cadastradas para integração Laboratorial|0" ' Não possui credenciais para integracao
        end if
    else    
         verificaIntegracaoLaboratorial = "X|0|0" ' Não possui o serviço habilitado
    end if
end function 

function retornaBotaoIntegracaoLaboratorial (vartabela, varid)
    arrayintegracao = split(verificaIntegracaoLaboratorial(vartabela, varid),"|")
    if vartabela="tissguiasadt" then
        radical = "tgs"
    else
        radical = "sfi"
    end if
    select case arrayintegracao(0)
        case "0"       
            retornaBotaoIntegracaoLaboratorial = "<div id=""div-btn-abrir-integracao-"&radical&varid&""" class=""btn-group""><button type=""button"" style=""margin-right:5px;"" onclick=""javascritpt:alert('"&arrayintegracao(1)&"');"" class=""btn btn-secondary btn-xs"" id=""btn-abrir-integracao-"&radical&varid&""" title="""&arrayintegracao(1)&""">" &_ 
                                                 "<i class=""fa fa-flask""></i> </button></div>"
       
        case "1"
            retornaBotaoIntegracaoLaboratorial = "<div id=""div-btn-abrir-integracao-"&radical&varid&""" class=""btn-group""><button type=""button"" style=""margin-right:5px;"" onclick=""abrirSelecaoLaboratorio('"&vartabela&"','"&varid&"','"&arrayintegracao(2)&"')"" class=""btn btn-danger btn-xs"" id=""btn-abrir-integracao-"&radical&varid&""" title=""Abrir Integração Laboratorial (v."&arrayintegracao(2)&") "">" &_
                                                 "<i class=""fa fa-flask""></i></button></div>"
            
        case "2"
            retornaBotaoIntegracaoLaboratorial = "<div id=""div-btn-abrir-integracao-"&radical&varid&""" class=""btn-group""><button type=""button"" style=""margin-right:5px;"" onclick=""abrirSolicitacao('"&arrayintegracao(1)&"','"&arrayintegracao(2)&"')"" class=""btn btn-success btn-xs"" id=""btn-abrir-integracao-"&radical&varid&""" title=""Ver detalhes da Integração (v."&arrayintegracao(2)&")""> "&_
                                                 "<i class=""fa fa-flask""></i></button></div>"
            
        case else
            retornaBotaoIntegracaoLaboratorial = "<div id=""div-btn-abrir-integracao-"&radical&varid&""" class=""btn-group""> </div>"
    end select  
end function 

function retornaChamadaIntegracaoLaboratorial(link)
    arrayintegracao = split(verificaSevicoIntegracaoLaboratorial(""),"|")
    if arrayintegracao(0) = 1  then 'Verifica se a licença está habilitada para integração laboratorial
        if arrayintegracao(1) = 1 then 'Verica a versao da integracao
            retornaChamadaIntegracaoLaboratorial =  "getUrl(""labs-integration/"&link&""",{}, function(data) { " &_
                                                    " $("".app"").hide(); " &_
                                                    " $("".app"").html(data); " &_
                                                    " $("".app"").fadeIn('slow');}); "
        else
            retornaChamadaIntegracaoLaboratorial =  "getUrl(""labs-integration/"&link&""",{}, function(data) { " &_
                                                    " $("".app"").hide(); " &_
                                                    " $("".app"").html(data); " &_
                                                    " $("".app"").fadeIn('slow');},""integracaolaboratorial""); "
        end if 
    else
        retornaChamadaIntegracaoLaboratorial = "Esta licença não está habilitada para integração laboratorial" 
    end if 
end function 

function verificaStatusIntegracaoConta(tabela,id)
    arrayintegracao = split(verificaSevicoIntegracaoLaboratorial(""),"|")
    resultado = 0
    if arrayintegracao(0) = 1  then 'Verifica se a licença está habilitada para integração laboratorial
        if arrayintegracao(1) = 1 then 'Verica a versao da integracao
            sqlintegracao = " SELECT lia.id, lie.StatusID FROM labs_invoices_amostras lia "&_
                            " inner JOIN labs_invoices_exames lie ON lia.id = lie.AmostraID "&_
                            " WHERE lia.InvoiceID = "&treatvalzero(id)&" AND lia.ColetaStatusID <> 5 "
        else
            sqlintegracao = "SELECT id FROM slabs_solicitacoes WHERE tabelaid = "&treatvalzero(id)&" AND tabela  = '"&tabela&"' AND success='S' AND statusid = 1;"
        end if 
       
        set integracaofeita = db_execute(sqlintegracao)
        if integracaofeita.eof then
            resultado = 0
        else
            resultado = 1
        end if     
    else
        resultado = 0
    end if 
    verificaStatusIntegracaoConta = resultado
end function

%>