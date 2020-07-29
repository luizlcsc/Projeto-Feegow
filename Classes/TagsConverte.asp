<!--#include file="./../connect.asp"-->
<!--#include file="./imagens.asp"-->
<%
function tagsConverte(conteudo,itens,moduloExcecao)
  'EXEMPLO: DE USO DESTA FUNÇÃO
  'conteudo = "Atesto que o paciente [Paciente.Nome]<br>foi atendido as [Sistema.Hora]<br>pelo profissional [Profissional.Nome]"
  'response.write(tagsConverte(conteudo,Profissional_4754|Paciente_7854|Sistema_0,""))
  'moduloExcecao: São configurações específicas que um módulo pode ter, neste caso crie a exceção em um CASE/IF

  LicencaID_session = replace(session("Banco"), "clinic", "")
  'CONVERSAO DA CATEGORIA SISTEMA É PADRÃO
  itens = itens
  '### FILTRA OS ITENS SEPARADOS POR PIPE
  itensArray=Split(itens,"|")
  
  for each itensValor in itensArray
    '### <SEPARA OS ITENS SEPARADOS POR UNDERLINE>
    itemArray = split(itensValor, "_")
    item_nome = itemArray(0)&""
    item_id   = itemArray(1)&""
    conteudo = conteudo&""
    '## Add prefixo item_ para evitar conflitos de variaveis
    
    select case item_nome
      case "PacienteID"
        item_PacienteID          = item_id
        'ALIAS DE TAGS RELACIONADAS AO PACIENTE
        conteudo = replace(conteudo,"[NomePaciente]","[Paciente.Nome]")
      case "ProfissionalID"
        item_ProfissionalID      = item_id
        'ALIAS DE TAGS RELACIONADAS AO PROFISSIONAL
        conteudo = replace(conteudo, "[NomeProfissional]", "[Profissional.Nome]" )
        
      case "ProfissionalSessao"
        item_ProfissionalSessao  = session("idInTable")
        'ALIAS DE TAGS RELACIONADAS AO PROFISSIONAL - SESSÃO
        conteudo = replace(conteudo, "[NomeProfissional]", "[Profissional.Nome]" )

      case "ProfissionalSolicitanteID"
        item_ProfissionalSolicitanteID  = item_id
        'ALIAS DE TAGS RELACIONADAS AO PROFISSIONAL - SESSÃO
        'Adicionar aqui...
      

      case "UnidadeSessao"
        item_UnidadeSessao       = item_id
        'ALIAS DE TAGS RELACIONADAS A UNIDADE SESSAO
        'Adicionar aqui...
      
      
      case "UnidadeID"          
        item_UnidadeID           = item_id
        'ALIAS DE TAGS RELACIONADAS A UNIDADE
        conteudo = replace(conteudo, "[Empresa.Endereco]", "[Unidade.Endereco]")
        conteudo = replace(conteudo, "[Empresa.Nome]", "[Unidade.Nome]")
        conteudo = replace(conteudo, "[Empresa.Numero]", "[Unidade.Numero]")
        conteudo = replace(conteudo, "[Empresa.Complemento]", "[Unidade.Complemento]")
        conteudo = replace(conteudo, "[Empresa.Bairro]", "[Unidade.Bairro]")
        conteudo = replace(conteudo, "[Empresa.Tel1]", "[Unidade.Tel1]")
        conteudo = replace(conteudo, "[Empresa.Email1]", "[Unidade.Email1]")
        conteudo = replace(conteudo, "[Empresa.Cep]", "[Unidade.Cep]")
        conteudo = replace(conteudo, "[Empresa.Estado]", "[Unidade.Estado]")
      case "AgendamentoID"
        item_AgendamentoID       = item_id
        'ALIAS DE TAGS RELACIONADAS AO AGENDAMENTO
        conteudo = replace(conteudo, "[DataAgendamento]", "[Agendamento.Data]" )
        conteudo = replace(conteudo, "[HoraAgendamento]", "[Agendamento.Hora]" )
      case "ProcedimentoID"
        item_ProcedimentoID      = item_id
        'ALIAS DE TAGS RELACIONADAS AO PROCEDIMENTO
        'Adicionar aqui...
      case "ProcedimentoNome"     'NO CASO DO AGENDAMENTO QUE O NOME DO AGENDAMENTO PODE != DO PADRÃO
        item_ProcedimentoNome    = item_id
        'ALIAS DE TAGS RELACIONADAS AO NOME DO PROCEDIMENTO
        'Adicionar aqui...
      case "ReciboID"
        item_ReciboID            = item_id
        'ALIAS DE TAGS RELACIONADAS AO RECIBO
        
      case "PropostaID"          
        item_PropostaID          = item_id
        'ALIAS DE TAGS RELACIONADAS APROPOSTA
        'Adicionar aqui...

      case "FaturaID"          
        item_FaturaID          = item_id
        'ALIAS DE TAGS RELACIONADAS A FATURAS / Invoices
        conteudo = replace(conteudo, "[Fatura.Protocolo]", "[Fatura.Codigo]" )
    end select
  next
  '### <FILTRA OS ITENS SEPARADOS POR PIPE/>
  if conteudo<>"" then
    conteudo = conteudo
    '<TAGS RELACIONADAS AO SISTEMA>
    conteudo = replace(conteudo, "[Sistema.Extenso]", formatdatetime(date(),1) )
    conteudo = replace(conteudo, "[Data.DDMMAAAA]", "[Sistema.Data]" )
    conteudo = replace(conteudo, "[Sistema.Data]",date())
    conteudo = replace(conteudo, "[Sistema.Hora]", time())
    conteudo = replace(conteudo, "[Data.Extenso]", formatdatetime(date(),1))
    'TRATAMENTO DE ITENS QUE GERAM SESSÃO (USUÁRIO, UNIDADE)
    conteudo = replace(conteudo, "[Usuario.Nome]", session("NameUser"))

    '</TAGS RELACIONADAS AO SISTEMA>
    
  else
    conteudo = ""
  end if
  SET tagsCategoriasSQL = db.execute("select categoria from cliniccentral.tags_categorias")
  while not tagsCategoriasSQL.eof
    tagsCategoria = tagsCategoriasSQL("categoria")
    'CHECA SE FOI INSERIDA A TAG PERTENCENTE A UMA CATEGORIA EXISTENTE 
    if instr(conteudo, "["&tagsCategoria)>0 then
      select case tagsCategoria
        case "Paciente"
          if item_PacienteID>0 then
            qPacientesSQL = "SELECT  "&_
            "c1.NomeConvenio AS 'Convenio1', c2.NomeConvenio AS 'Convenio2',c3.NomeConvenio AS 'Convenio3'  "&_
            ",pla1.NomePlano AS 'Plano1', pla2.NomePlano AS 'Plano2',pla3.NomePlano AS 'Plano3'  "&_
            ",p.*, ec.EstadoCivil, s.NomeSexo as Sexo, g.GrauInstrucao, o.Origem  "&_
            "from pacientes as p  "&_
            "left join estadocivil as ec on ec.id=p.EstadoCivil  "&_
            "left join sexo as s on s.id=p.Sexo  "&_
            "left join grauinstrucao as g on g.id=p.GrauInstrucao  "&_
            "left join origens as o on o.id=p.Origem  "&_
            "LEFT JOIN convenios c1 ON c1.id=p.ConvenioID1  "&_
            "LEFT JOIN convenios c2 ON c2.id=p.ConvenioID2  "&_
            "LEFT JOIN convenios c3 ON c3.id=p.ConvenioID3  "&_
            "LEFT JOIN conveniosplanos pla1 ON pla1.ConvenioID=c1.id  "&_
            "LEFT JOIN conveniosplanos pla2 ON pla2.ConvenioID=c2.id  "&_
            "LEFT JOIN conveniosplanos pla3 ON pla3.ConvenioID=c3.id  "&_
            "where p.id="&treatvalzero(item_PacienteID) 
          end if
          'response.write("<pre>"&qPacientesSQL&"</pre>")
          if qPacientesSQL<>"" then
            SET PacientesSQL = db.execute(qPacientesSQL)
              if not PacientesSQL.eof then
                conteudo = replace(conteudo,"[Paciente.Nome]",PacientesSQL("NomePaciente")&"")
                conteudo = replace(conteudo,"[Paciente.Sexo]",PacientesSQL("Sexo")&"")
                if isdate(PacientesSQL("Nascimento")) then
                  conteudo = replace(conteudo, "[Paciente.Idade]", idade(PacientesSQL("Nascimento")&""))
                else
                  conteudo = replace(conteudo, "[Paciente.Idade]", "")
                end if
                conteudo = replace(conteudo, "[Paciente.Nascimento]", PacientesSQL("Nascimento")&"")
                conteudo = replace(conteudo, "[Paciente.Documento]", PacientesSQL("Documento")&"")
                conteudo = replace(conteudo, "[Paciente.Prontuario]", PacientesSQL("id"))
                'POSSIBILIDADE DE UTILIZAR PLANOS E CONVENIOS SECUNDÁRIOS
                conteudo = replace(conteudo, "[Paciente.Convenio1]", PacientesSQL("Convenio1")&"")
                conteudo = replace(conteudo, "[Paciente.Convenio2]", PacientesSQL("Convenio2")&"")
                conteudo = replace(conteudo, "[Paciente.Convenio3]", PacientesSQL("Convenio3")&"")
                conteudo = replace(conteudo, "[Paciente.Plano1]", PacientesSQL("Plano1")&"")
                conteudo = replace(conteudo, "[Paciente.Plano2]", PacientesSQL("Plano2")&"")
                conteudo = replace(conteudo, "[Paciente.Plano3]", PacientesSQL("Plano3")&"")
                'REDUNDANCIA NOS PLANOS E CONVENIOS 1 TAGs EXISTENTES
                conteudo = replace(conteudo, "[Paciente.Convenio]", trim(PacientesSQL("Convenio1")&" ") )
                conteudo = replace(conteudo, "[Paciente.Plano]", trim(PacientesSQL("Plano1")&" ") )
                conteudo = replace(conteudo, "[Paciente.Matricula]", trim(PacientesSQL("Matricula1")&" ") )
                conteudo = replace(conteudo, "[Paciente.Validade]", trim(PacientesSQL("Validade1")&" ") )
                conteudo = replace(conteudo, "[Paciente.Email]", trim(PacientesSQL("Email1")&" ") )
                conteudo = replace(conteudo, "[Paciente.CPF]", trim(PacientesSQL("CPF")&" ") )
                'CONTATOS
                conteudo = replace(conteudo, "[Paciente.Tel1]", "[Paciente.Telefone]" )
                conteudo = replace(conteudo, "[Paciente.Telefone]", trim(PacientesSQL("Tel1")&" ") )
                conteudo = replace(conteudo, "[Paciente.Tel2]", trim(PacientesSQL("Tel2")&" ") )
                conteudo = replace(conteudo, "[Paciente.Cel1]", "[Paciente.Celular]"&"" )
                conteudo = replace(conteudo, "[Paciente.Celular]", PacientesSQL("Cel1")&"" )
                conteudo = replace(conteudo, "[Paciente.Cel2]", PacientesSQL("Cel2")&"" )
                conteudo = replace(conteudo, "[Paciente.IndicadoPor]", trim(PacientesSQL("IndicadoPor")&" ") )
                'ENDEREÇO
                conteudo = replace(conteudo, "[Paciente.Estado]", trim(PacientesSQL("Estado")&" ") )
                conteudo = replace(conteudo, "[Paciente.Cidade]", trim(PacientesSQL("Cidade")&" ") )
                conteudo = replace(conteudo, "[Paciente.Bairro]", trim(PacientesSQL("Bairro")&" ") )
                conteudo = replace(conteudo, "[Paciente.Endereco]", trim(PacientesSQL("Endereco")&" ") )
                conteudo = replace(conteudo, "[Paciente.Numero]", trim(PacientesSQL("Numero")&" ") )
                conteudo = replace(conteudo, "[Paciente.Complemento]", trim(PacientesSQL("Complemento")&" ") )
                conteudo = replace(conteudo, "[Paciente.Cep]", trim(PacientesSQL("Cep")&" ") )
                
                'GERAIS
                conteudo = replace(conteudo, "[Paciente.Profissao]", trim(PacientesSQL("Profissao")&" ") )
                conteudo = replace(conteudo, "[Paciente.CNS]", trim(PacientesSQL("CNS")&" ") )
                conteudo = replace(conteudo, "[Paciente.Observacoes]", trim(PacientesSQL("Observacoes")&" ") )
              end if
            PacientesSQL.close
            set PacientesSQL = nothing
          end if
        case "Unidade"
          if item_UnidadeID=0 then
            qUnidadeSQL = "select *, NomeEmpresa Nome from empresa"
            'response.write("<script>console.log('Empresa ("&item_UnidadeID&")')</script>")
          else
            qUnidadeSQL = "select *, unitName Nome from sys_financialcompanyunits where id="&item_UnidadeID
            'response.write("<script>console.log('Unidade')</script>")
          end if
          SET UnidadeSQL = db.execute(qUnidadeSQL)
          if not UnidadeSQL.eof then
            if item_UnidadeID=0 then
              conteudo = replace(conteudo, "[Unidade.Nome]", trim(UnidadeSQL("NomeEmpresa")&" ") )
            else
              conteudo = replace(conteudo, "[Unidade.Nome]", trim(UnidadeSQL("UnitName")&" ") )
            end if
            conteudo = replace(conteudo, "[Unidade.NomeFantasia]", trim(UnidadeSQL("NomeFantasia")&" ") )
            'ENDERECO
            conteudo = replace(conteudo, "[Unidade.Cep]", trim(UnidadeSQL("CEP")&" ") )
            conteudo = replace(conteudo, "[Unidade.Estado]", trim(UnidadeSQL("Estado")&" ") )
            conteudo = replace(conteudo, "[Unidade.Cidade]", trim(UnidadeSQL("Cidade")&" ") )
            conteudo = replace(conteudo, "[Unidade.Bairro]", trim(UnidadeSQL("Bairro")&" ") )
            conteudo = replace(conteudo, "[Unidade.Endereco]", trim(UnidadeSQL("Endereco")&" ") )
            conteudo = replace(conteudo, "[Unidade.Numero]", trim(UnidadeSQL("Numero")&" ") )
            conteudo = replace(conteudo, "[Unidade.Complemento]", trim(UnidadeSQL("Complemento")&" ") )
            'DOCUMENTOS
            conteudo = replace(conteudo, "[Unidade.CNPJ]", trim(UnidadeSQL("CNPJ")&" ") )
            'CONTATOS
            conteudo = replace(conteudo, "[Unidade.Tel1]", "[Unidade.Telefone]" )
            conteudo = replace(conteudo, "[Unidade.Telefone]", trim(UnidadeSQL("tel1")&" ") )
          end if
          'response.write("<pre>"&qUnidadeSQL&"</pre>")
        case "Profissional"
          
          'QUERY ALTERADA PARA A MESMA QUERY DO FEEGOW API 27/07/2020
          
          qProfissionaisContentSQL = "SELECT prof.RQE, prof.Conselho, prof.NomeProfissional, t.Tratamento, CONCAT(IF(t.Tratamento is null,'',concat(t.Tratamento,' ')),IF(prof.NomeSocial is null or prof.NomeSocial ='', SUBSTRING_INDEX(prof.NomeProfissional,' ', 1), prof.NomeSocial)) PrimeiroNome, "&_
          "CONCAT(cp.descricao, ' ', prof.DocumentoConselho, ' ', prof.UFConselho) Documento, prof.Assinatura, prof.DocumentoConselho, prof.CPF, prof.NomeSocial, esp.especialidade Especialidade "&_
          "FROM profissionais prof "&_
          "LEFT JOIN conselhosprofissionais cp ON cp.id=prof.Conselho "&_
          "LEFT JOIN especialidades esp ON esp.id=prof.EspecialidadeID LEFT JOIN tratamento t ON t.id=prof.TratamentoID "&_
          "WHERE prof.id="


          'PROFISSIONAL SOLICITANTE
          if item_ProfissionalSolicitanteID>0 then
            SET ProfissionaisSQL = db.execute(qProfissionaisContentSQL&item_ProfissionalSolicitanteID)
            if not ProfissionaisSQL.eof then
              conteudo = replace(conteudo, "[ProfissionalSolicitante.Nome]", trim(ProfissionaisSQL("NomeProfissional")&" ") )
              conteudo = replace(conteudo, "[ProfissionalSolicitante.PrimeiroNome]", trim(ProfissionaisSQL("PrimeiroNome")&" ") )
              conteudo = replace(conteudo, "[ProfissionalSolicitante.NomeSocial]", trim(ProfissionaisSQL("NomeSocial")&" ") )
              conteudo = replace(conteudo, "[ProfissionalSolicitante.Especialidade]", trim(ProfissionaisSQL("Especialidade")&" ") )
              conteudo = replace(conteudo, "[ProfissionalSolicitante.Documento]", trim(ProfissionaisSQL("Documento")&" ") )
              conteudo = replace(conteudo, "[ProfissionalSolicitante.CPF]", trim(ProfissionaisSQL("CPF")&" ") )
              if ProfissionaisSQL("Assinatura")&"" = "" then
                conteudo = replace(conteudo, "[ProfissionalSolicitante.Assinatura]", "______________________________________________")
              else
                conteudo = replace(conteudo, "[ProfissionalSolicitante.Assinatura]", "<img style='max-width:200px;max-height:150px;width:auto;height:auto;' src='"&imgSRC("Imagens",trim(ProfissionaisSQL("Assinatura")))&"'>" )
              end if
              
            end if
            ProfissionaisSQL.close
            set ProfissionaisSQL = nothing
          end if

          
          if item_ProfissionalID>0 then
            qProfissionaisSQL=qProfissionaisContentSQL&item_ProfissionalID
          elseif item_ProfissionalSessao>0 AND session("Table")=lcase("profissionais") then 'EXCEÇÃO POR CONTA DO MÓDULO DE RECIBOS E OUTROS LOCAIS QUE PODEM ESTAR UTILIZANDO TAGS [Profissional.ALGUMACOISA] E REFERENCIANDO A SESSÃO DO PROFISSIONAL LOGADO
            qProfissionaisSQL = qProfissionaisContentSQL&item_ProfissionalSessao
          end if
          if qProfissionaisSQL<>"" then
            SET ProfissionaisSQL = db.execute(qProfissionaisSQL)
            if not ProfissionaisSQL.eof then
               
              conteudo = replace(conteudo, "[Profissional.Nome]", trim(ProfissionaisSQL("NomeProfissional")&" ") )
              conteudo = replace(conteudo, "[Profissional.PrimeiroNome]", trim(ProfissionaisSQL("PrimeiroNome")&" ") )
              conteudo = replace(conteudo, "[Profissional.NomeSocial]", trim(ProfissionaisSQL("NomeSocial")&" ") )
              conteudo = replace(conteudo, "[Profissional.Especialidade]", trim(ProfissionaisSQL("Especialidade")&" ") )
              conteudo = replace(conteudo, "[Profissional.Documento]", trim(ProfissionaisSQL("Documento")&" ") )
              conteudo = replace(conteudo, "[Profissional.CPF]", trim(ProfissionaisSQL("CPF")&" ") )
              if ProfissionaisSQL("Assinatura")&"" = "" then
                conteudo = replace(conteudo, "[Profissional.Assinatura]", "______________________________________________")
              else
                conteudo = replace(conteudo, "[Profissional.Assinatura]", "<img style='max-width:200px;max-height:150px;width:auto;height:auto;' src='"&imgSRC("Imagens",trim(ProfissionaisSQL("Assinatura")))&"'>" )
              end if
              conteudo = replace(conteudo, "[Profissional.Tratamento]", trim(ProfissionaisSQL("Tratamento")&" ") )
              'NOVAS TAGS 06/07/2020
              conteudo = replace(conteudo, "[Profissional.RQE]", trim(ProfissionaisSQL("RQE")&" ") )

              'Referencia ifrReciboIntegrado.asp ||| Recibo = replace(Recibo, "[ProfissionalExecutante.Conselho]", ProfissionalExecutanteConselho ) 'LINHA 561
              conteudo = replace(conteudo, "[ProfissionalExecutante.Conselho]", trim(ProfissionaisSQL("DocumentoConselho")&" ") )
              conteudo = replace(conteudo, "[ProfissionalExecutante.Nome]", trim(ProfissionaisSQL("NomeProfissional")&" ") )
              conteudo = replace(conteudo, "[ProfissionalExecutante.CPF]", trim(ProfissionaisSQL("CPF")&" ") )

              if ProfissionaisSQL("Conselho")=1 then
                conteudo = replace(conteudo, "[Profissional.CRM]", trim(ProfissionaisSQL("DocumentoConselho")&" ") )
              end if
              conteudo = replace(conteudo, "[Profissional.DocumentoConselho]", trim(ProfissionaisSQL("DocumentoConselho")&" ") )
            end if 
          end if
        
          
        case "Financeiro"

        case "Agendamento"
          if item_AgendamentoID>0 then
            qAgendamentosSQL = "SELECT id, Data,  Hora,  TipoCompromissoID,  StaID,  ValorPlano,  rdValorPlano,  Notas,  Falado,  FormaPagto,  LocalID,  Tempo,  HoraFinal,  SubtipoProcedimentoID,  HoraSta,  ConfEmail,  ConfSMS,  Encaixe,  EquipamentoID,  NomePaciente,  Tel1,  Cel1,  Email1, Procedimentos,  EspecialidadeID,  IndicadoPor,  TabelaParticularID,  CanalID,  Retorno,  RetornoID,  Primeira,  PlanoID, PermiteRetorno "_
            &"FROM agendamentos "_
            &"WHERE id="&item_AgendamentoID
          end if
          if qAgendamentosSQL<>"" then
            SET AgendamentosSQL = db.execute(qAgendamentosSQL)
              if not AgendamentosSQL.eof then
                
                conteudo = replace(conteudo, "[Agendamento.Data]", AgendamentosSQL("Data")&"" )
                conteudo = replace(conteudo, "[Agendamento.Hora]", formatdatetime(AgendamentosSQL("Hora"),4)&"" )
              end if
            AgendamentosSQL.close
            set AgendamentosSQL = nothing
          end if
        case "Procedimento"
          if item_ProcedimentoID>0 then
            qProcedimentosSQL = "SELECT p.NomeProcedimento, p.DiasLaudo, t.TipoProcedimento "_
            &"FROM procedimentos p "_
            &"LEFT JOIN tiposprocedimentos t ON t.id=p.TipoProcedimentoID "_
            &"WHERE p.id="&item_ProcedimentoID
          end if
          if qProcedimentosSQL<>"" then
            SET ProcedimentosSQL = db.execute(qProcedimentosSQL)
            if not ProcedimentosSQL.eof then
              conteudo = replace(conteudo, "[Procedimento.Nome]", ProcedimentosSQL("NomeProcedimento")&"" )
              conteudo = replace(conteudo, "[Procedimento.DiasLaudo]", ProcedimentosSQL("DiasLaudo")&"" )
              conteudo = replace(conteudo, "[Procedimento.Tipo]", ProcedimentosSQL("TipoProcedimento")&"" )
            end if
            ProcedimentosSQL.close
            set ProcedimentosSQL = nothing
          end if
          if item_ProcedimentoNome<>"" then
            conteudo = replace(conteudo, "[Procedimento.Nome]", item_ProcedimentoNome&"" )
          end if
        case "Devolucao"
        case "Proposta"
          if item_PropostaID>0 then
            qPropostasSQL = "SELECT NomeProfissional, propostas.sysUser, tabelaparticular.NomeTabela FROM propostas "_
            &"LEFT JOIN profissionais ON profissionais.id = propostas.ProfissionalID "_
            &"LEFT JOIN tabelaparticular ON  tabelaparticular.id = propostas.TabelaID "_
            &"WHERE propostas.id ="&item_PropostaID
          end if
          'response.write("<pre>"&qPropostasSQL&"</pre>")
          if qPropostasSQL<>"" then
            SET PropostasSQL = db.execute(qPropostasSQL)
              
              conteudo = replace(conteudo, "[Proposta.ID]",item_PropostaID&"")
              conteudo = replace(conteudo, "[Proposta.ProfissionalSolicitante]", PropostasSQL("NomeProfissional")&"" )
              conteudo = replace(conteudo, "[Proposta.Criador]", nameInTable(PropostasSQL("sysUser"))&"" )
              conteudo = replace(conteudo, "[Proposta.Tabela]",PropostasSQL("NomeTabela")&"")
            PropostasSQL.close
            set PropostasSQL = nothing
          end if
        case "Encaminhamento"
        
        case "Recibo"
          'response.write("RECIBOID:::::: "&item_ReciboID)
          if item_ReciboID>0 then
            'QUERY DE REFERENCIA ifrReciboIntegrado.asp
            qRecibosSQL = "SELECT COALESCE(CONCAT(debito.InvoiceID,'.',rec.id),debito.InvoiceID) AS ReciboID, IF(bm.id IS NOT NULL, 1, cartao_credito.Parcelas) Parcelas, IF(bm.id IS NOT NULL, 'Boleto', IF(credito.`Type` = 'Transfer','CrÃ©dito', forma_pagamento.PaymentMethod)) PaymentMethod, pagamento.MovementID, IF(bm.id IS NOT NULL, debito.Value,credito.`value`) Value, IF(bm.id IS NOT NULL, debito.sysUser, credito.sysUser) sysUser, debito.Date DataVencimento, credito.Date DataPagamento "_
            &"FROM sys_financialmovement debito "_
            &"LEFT JOIN sys_financialdiscountpayments pagamento ON pagamento.InstallmentID = debito.id "_
            &"LEFT JOIN sys_financialmovement credito ON credito.id=pagamento.MovementID "_
            &"LEFT JOIN sys_financialpaymentmethod forma_pagamento ON forma_pagamento.id = credito.PaymentMethodID "_
            &"LEFT JOIN sys_financialcreditcardtransaction cartao_credito ON cartao_credito.MovementID=credito.id "_
            &"LEFT JOIN boletos_emitidos bm ON bm.MovementID=debito.id AND bm.StatusID NOT IN (3, 4) "_
            &"LEFT JOIN cliniccentral.boletos_status bs ON bs.id=bm.StatusID "_
            &"LEFT JOIN recibos rec ON rec.InvoiceID=debito.InvoiceID "_
            &"WHERE debito.InvoiceID="&item_ReciboID&" "_
            &"ORDER BY rec.id DESC"
          
          end if
          'response.write("<pre>"&qRecibosSQL&"</pre>")
          if qRecibosSQL<>"" then
            SET RecibosSQL = db.execute(qRecibosSQL)
            if not RecibosSQL.eof then
              conteudo = replace(conteudo, "[Recibo.Protocolo]", RecibosSQL("ReciboID")&"" )
              conteudo = replace(conteudo, "[Recibo.DataVencimento]", RecibosSQL("DataVencimento")&"" )
              conteudo = replace(conteudo, "[Recibo.DataPagamento]", RecibosSQL("DataPagamento")&"" )
            end if
            RecibosSQL.close
            set RecibosSQL = nothing
          end if
        case "Fatura"
          '***QUERY DE PROFISSIONAIS QUE EXECUTARAM UM SERVIÇO***
          'SELECT GROUP_CONCAT(p.NomeProfissional SEPARATOR ', ') FROM itensinvoice ii
          'LEFT JOIN profissionais p ON p.id=ii.ProfissionalID
          'WHERE ii.InvoiceID='9298' AND ii.Associacao=5 AND NOT ISNULL(p.NomeProfissional)
          'VALIDAR NOME DA TAG QUE OBTERÁ ESTA INFORMAÇÃO [Fatura.ProfissionaisExexutantes]

          if item_FaturaID>0 then
            qFaturasSQL = "SELECT CONCAT('IN',UPPER(left(md5(id), 7))) as Codigo FROM sys_financialinvoices WHERE id="&item_FaturaID
            SET FaturasSQL = db.execute(qFaturasSQL)
            if not FaturasSQL.eof then
              conteudo = replace(conteudo, "[Fatura.Codigo]", trim(FaturasSQL("Codigo")&" ") )
            end if
            FaturasSQL.close
            set FaturasSQL = nothing
          end if 
    
      end select
    end if
  tagsCategoriasSQL.movenext
  wend
  tagsCategoriasSQL.close
  SET tagsCategoriasSQL = nothing
  tagsConverte = conteudo
  
'response.write("<script>console.log('VALOR::: "&UnidadeID&"')</script>")
end function
'***** EXEMPLO DE USO DA FUNÇÃO ******
'conteudoParaConverter = "Atesto que o paciente [Paciente.Nome]<br>"&_
'"foi atendido as [Sistema.Hora]<br>pelo profissional [Profissional.Nome] |Nome: [Profissional.Nome] Documento: [Profissional.Documento] CRM: [Profissional.CRM] Assinatura: [Profissional.Assinatura]<br>"&_
'"Profissional Solicitante: [ProfissionalSolicitante.Nome]"
'itens = "PacienteID_6365|UserID_478|ProfissionalID_1|UnidadeID_8741|ProfissionalSolicitanteID_200"
'response.write(tagsConverte(conteudoParaConverter,itens,""))
'response.write("<br>"&TagsConverte("[Profissional.Nome]","ProfissionalID_1",""))
'response.write("<br>"&TagsConverte("[Profissional.Nome]","ProfissionalSessao_1",""))
'response.write("<br>"&TagsConverte("[ProfissionalSolicitante.Nome]","ProfissionalSolicitanteID_200",""))
'response.write(TagsConverte("Fatura: [Fatura.Codigo]","FaturaID_2",""))
%>