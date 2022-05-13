<!--#include file="./../connect.asp"-->
<!--#include file="./imagens.asp"-->
<!--#include file="./StringFormat.asp"-->

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

   ' response.write("<pre>"&item_nome&": "&item_id&"</pre>")
    
    '## Add prefixo item_ para evitar conflitos de variaveis
    select case item_nome
      case "PacienteID"
        item_PacienteID          = item_id
        'ALIAS DE TAGS RELACIONADAS AO PACIENTE
        conteudo = replace(conteudo,"[NomePaciente]","[Paciente.Nome]")
        conteudo = replace(conteudo,"[Responsavel.Nome]","[PacienteResponsavel.Nome]")
        conteudo = replace(conteudo,"[Responsavel.CPF]","[PacienteResponsavel.CPF]")
      case "ProfissionalExecutanteExternoID"
        item_ProfissionalExternoID          = item_id

      case "ProfissionalID"
        item_ProfissionalID                = item_id
        item_AssociacaoProfissionalID      = 5
        'ALIAS DE TAGS RELACIONADAS AO PROFISSIONAL
        conteudo = replace(conteudo, "[NomeProfissional]", "[Profissional.Nome]" )

        'TRATAMENTO DA VARIÁVEL item_ProfissionalID QUANDO VAZIA - Airton 11-08-2020
        if item_ProfissionalID = "" then
          item_ProfissionalID = 0
        end if

        if instr(item_ProfissionalID,"-")>0 then
            splitItem_ProfissionalID = split(item_ProfissionalID, "-")
            item_ProfissionalID=splitItem_ProfissionalID(1)
            item_AssociacaoProfissionalID=splitItem_ProfissionalID(0)
        end if

      case "ProfissionalLaudadorID"
        item_ProfissionalLaudadorID      = item_id

        if item_ProfissionalLaudadorID = "" then
          item_ProfissionalLaudadorID = 0
        end if

      case "ProfissionalSessao"
        item_ProfissionalSessao  = session("idInTable")
        'ALIAS DE TAGS RELACIONADAS AO PROFISSIONAL - SESSÃO
        conteudo = replace(conteudo, "[NomeProfissional]", "[Profissional.Nome]" )

      case "ProfissionalSolicitanteID"
        item_ProfissionalSolicitanteID  = item_id
        'ALIAS DE TAGS RELACIONADAS AO PROFISSIONAL - SESSÃO
        'Adicionar aqui...

      'CASE INCLUIDO PARA TRATAR ENVIO DE SOLICITANTE DO ARQUIVO printProcedimentoImpresso.asp - Airton 12-08-2020
      case "ProfissionalSolicitanteNome"
        if ProfissionalSolicitanteNome&"" <> "" then
          conteudo = replace(conteudo, "[ProfissionalSolicitante.Nome]", item_id)
        else
          conteudo = replace(conteudo, "[ProfissionalSolicitante.Nome]", " " )
        end if
      
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
        conteudo = replace(conteudo, "[Agendamento.ID]", item_id )

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
      
      case "ContratoID"
        item_ContratoID            = item_id
        'ALIAS DE TAGS RELACIONADAS AO RECIBO
        
      case "PropostaID"          
        item_PropostaID          = item_id
        'ALIAS DE TAGS RELACIONADAS APROPOSTA
        'Adicionar aqui...
      case "AtendimentoID"          
        item_AtendimentoID          = item_id
        
      case "FaturaID"          
        item_FaturaID          = item_id
        'ALIAS DE TAGS RELACIONADAS A FATURAS / Invoices
        conteudo = replace(conteudo, "[Fatura.Protocolo]", "[Fatura.Codigo]" )
      
      case "ReceitaID"
        item_ReceitaID = item_id

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

  'CONVERTE TAGS BASEADO NA SESSÃO PARA QUANDO NÃO FOR PASSADO O VALOR
  if item_UnidadeID&""="" then
    item_UnidadeID = session("UnidadeID")
  end if


  SET tagsCategoriasSQL = db.execute("select categoria from cliniccentral.tags_categorias")

  while not tagsCategoriasSQL.eof
    tagsCategoria = tagsCategoriasSQL("categoria")
    'CHECA SE FOI INSERIDA A TAG PERTENCENTE A UMA CATEGORIA EXISTENTE 
    if instr(conteudo, "["&tagsCategoria)>0 then
      select case tagsCategoria
        case "Paciente"

          if item_PacienteID>0 then
            qPacientesSQL = " SELECT                                                                                                "&chr(13)&_
                            " p.*,                                                                                                  "&chr(13)&_
                            " c1.NomeConvenio AS 'Convenio1', c2.NomeConvenio AS 'Convenio2',c3.NomeConvenio AS 'Convenio3',        "&chr(13)&_
                            " pla1.NomePlano AS 'Plano1', pla2.NomePlano AS 'Plano2',pla3.NomePlano AS 'Plano3',                    "&chr(13)&_
                            " ec.EstadoCivil, s.NomeSexo AS Sexo, g.GrauInstrucao, o.Origem, corPel.NomeCorPele,                    "&chr(13)&_
                            " pacrel.CPFParente AS ResponsavelCPF, pacrel.Nome AS ResponsavelNome                                   "&chr(13)&_
                            " FROM pacientes AS p                                                                                   "&chr(13)&_
                            " LEFT JOIN estadocivil AS ec ON ec.id=p.EstadoCivil                                                    "&chr(13)&_
                            " LEFT JOIN sexo AS s ON s.id=p.Sexo                                                                    "&chr(13)&_
                            " LEFT JOIN grauinstrucao AS g ON g.id=p.GrauInstrucao                                                  "&chr(13)&_
                            " LEFT JOIN origens AS o ON o.id=p.Origem                                                               "&chr(13)&_
                            " LEFT JOIN convenios c1 ON c1.id=p.ConvenioID1                                                         "&chr(13)&_
                            " LEFT JOIN convenios c2 ON c2.id=p.ConvenioID2                                                         "&chr(13)&_
                            " LEFT JOIN convenios c3 ON c3.id=p.ConvenioID3                                                         "&chr(13)&_
                            " LEFT JOIN conveniosplanos pla1 ON pla1.id=p.PlanoID1                                                  "&chr(13)&_
                            " LEFT JOIN conveniosplanos pla2 ON pla2.id=p.PlanoID2                                                  "&chr(13)&_
                            " LEFT JOIN conveniosplanos pla3 ON pla3.id=p.PlanoID3                                                  "&chr(13)&_
                            " LEFT JOIN corpele corPel ON corPel.id=p.`CorPele`                                                     "&chr(13)&_
                            " LEFT JOIN pacientesrelativos AS pacrel ON pacrel.PacienteID=p.id AND pacrel.Dependente='S'            "&chr(13)&_
                            " where p.id="&treatvalzero(item_PacienteID)                                                             &chr(13)&_
                            " GROUP BY p.id                                                                                         "
             
          end if
          'response.write("<pre>"&qPacientesSQL&"</pre>")
          if qPacientesSQL<>"" then
            SET PacientesSQL = db.execute(qPacientesSQL)

              if not PacientesSQL.eof then

                if PacientesSQL("NomeSocial")&""<>"" then
                  pacienteNomeSocial=PacientesSQL("NomeSocial")
                else
                  pacienteNomeSocial=PacientesSQL("NomePaciente")
                end if

                conteudo = replace(conteudo,"[Paciente.NomeSocial]",pacienteNomeSocial&"")
                
                conteudo = replace(conteudo,"[Paciente.Nome]",PacientesSQL("NomePaciente")&"")
                conteudo = replace(conteudo,"[Paciente.Sexo]",PacientesSQL("Sexo")&"")
                if isdate(PacientesSQL("Nascimento")) then
                  conteudo = replace(conteudo, "[Paciente.Idade]", idade(PacientesSQL("Nascimento")&""))
                else
                  conteudo = replace(conteudo, "[Paciente.Idade]", "")
                end if
                conteudo = replace(conteudo, "[Paciente.Nascimento]", PacientesSQL("Nascimento")&"")
                conteudo = replace(conteudo, "[Paciente.Documento]", PacientesSQL("Documento")&"")

                if inStr(conteudo,"[Paciente.Prontuario]")>0 then
                  Prontuario = PacientesSQL("id")
                  if getConfig("AlterarNumeroProntuario") = 1 then
                    Prontuario = PacientesSQL("idImportado")
                  end if
                  conteudo = replace(conteudo, "[Paciente.Prontuario]", Prontuario)
                end if

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
                conteudo = replace(conteudo, "[Paciente.Email1]", trim(PacientesSQL("Email1")&" ") )
                conteudo = replace(conteudo, "[Paciente.Email2]", trim(PacientesSQL("Email2")&"") )
                conteudo = replace(conteudo, "[Paciente.Religiao]", trim(PacientesSQL("Religiao")&" ") )
                conteudo = replace(conteudo, "[Paciente.EstadoCivil]", trim(PacientesSQL("EstadoCivil")&" ") )                

                conteudo = replace(conteudo, "[Paciente.CorIdentificacao]", trim(PacientesSQL("CorIdentificacao")&" ") )

                CPFFormatado = formatCPF(PacientesSQL("CPF")&"")
                conteudo = replace(conteudo, "[Paciente.CPF]", CPFFormatado)
                'CONTATOS
                conteudo = replace(conteudo, "[Paciente.Tel1]", "[Paciente.Telefone]" )
                conteudo = replace(conteudo, "[Paciente.Telefone]", trim(PacientesSQL("Tel1")&" ") )
                conteudo = replace(conteudo, "[Paciente.Tel2]", trim(PacientesSQL("Tel2")&" ") )
                conteudo = replace(conteudo, "[Paciente.Cel1]", "[Paciente.Celular]"&"" )
                conteudo = replace(conteudo, "[Paciente.Celular]", PacientesSQL("Cel1")&"" )
                conteudo = replace(conteudo, "[Paciente.Cel2]", PacientesSQL("Cel2")&"" )
                conteudo = replace(conteudo, "[Paciente.IndicadoPor]", trim(PacientesSQL("IndicadoPor")&" ") )
                conteudo = replace(conteudo, "[Paciente.Origem]", trim(PacientesSQL("Origem")&" ") )

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
                conteudo = replace(conteudo, "[Paciente.Peso]", trim(PacientesSQL("Peso")&" ") )
                conteudo = replace(conteudo, "[Paciente.Altura]", trim(PacientesSQL("Altura")&" ") )
                conteudo = replace(conteudo, "[Paciente.CorPele]", trim(PacientesSQL("NomeCorPele")&" ") )
                conteudo = replace(conteudo, "[Paciente.IMC]", trim(PacientesSQL("IMC")&" ") )
                conteudo = replace(conteudo, "[Paciente.CNS]", trim(PacientesSQL("CNS")&" ") )
                conteudo = replace(conteudo, "[Paciente.Observacoes]", trim(PacientesSQL("Observacoes")&" ") )
                'RESPONSAVEL PELO PACIENTE
                conteudo = replace(conteudo, "[PacienteResponsavel.Nome]", trim(PacientesSQL("ResponsavelNome")&" ") )
                conteudo = replace(conteudo, "[PacienteResponsavel.CPF]",  trim(PacientesSQL("ResponsavelCPF")&" ") )
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
            Estado = UnidadeSQL("Estado")&""
            Cidade = UnidadeSQL("Cidade")&""
            Bairro = UnidadeSQL("Bairro")&""
            Endereco = UnidadeSQL("Endereco")&""
            Numero = UnidadeSQL("Numero")&""
            Complemento = UnidadeSQL("Complemento")&""

            EnderecoCompleto = replace(Endereco&", "&Numero&", "&Complemento&", "&Bairro&", "&Cidade&", "&Estado, ", , ", ", " )


            conteudo = replace(conteudo, "[Unidade.Cep]", trim(UnidadeSQL("CEP")&" ") )
            conteudo = replace(conteudo, "[Unidade.Estado]", trim(UnidadeSQL("Estado")&" ") )
            conteudo = replace(conteudo, "[Unidade.Cidade]", trim(UnidadeSQL("Cidade")&" ") )
            conteudo = replace(conteudo, "[Unidade.Bairro]", trim(UnidadeSQL("Bairro")&" ") )
            conteudo = replace(conteudo, "[Unidade.Endereco]", trim(UnidadeSQL("Endereco")&" ") )
            conteudo = replace(conteudo, "[Unidade.Numero]", trim(UnidadeSQL("Numero")&" ") )
            conteudo = replace(conteudo, "[Unidade.Complemento]", trim(UnidadeSQL("Complemento")&" ") )
            conteudo = replace(conteudo, "[Unidade.EnderecoCompleto]", trim(EnderecoCompleto))
            'DOCUMENTOS
            conteudo = replace(conteudo, "[Unidade.CNPJ]", trim(UnidadeSQL("CNPJ")&" ") )
            'CONTATOS
            conteudo = replace(conteudo, "[Unidade.Tel1]", "[Unidade.Telefone]" )
            conteudo = replace(conteudo, "[Unidade.Telefone]", trim(UnidadeSQL("tel1")&" ") )
          end if
          'response.write("<pre>"&qUnidadeSQL&"</pre>")
               
        case "Profissional"

          'TRATANDO TAG DE PROFISSIONAL DENTRO DO MODELO ATESTADO
          if item_nome = "AtendimentoID" then

            'Não tem um atendimento e não é um profissional a variavel ProfissionalAtendimentoID fica vazia: a tag fica em branco
            ProfissionalAtendimentoID = ""
            set ProfissionalAtendimentoSQL = db_execute("SELECT HoraFim, ProfissionalID FROM atendimentos WHERE PacienteID="&req("PacienteID")&" ORDER BY id DESC LIMIT 1")

            if not ProfissionalAtendimentoSQL.eof then
              
              if session("Table")="profissionais" then
                'Tem atendimento: pegar profissional atendimento
                HoraFimAtendimento = ProfissionalAtendimentoSQL("HoraFim")&""
                ProfissionalAtendimentoID = ProfissionalAtendimentoSQL("ProfissionalID")
              end if

            else

              'Não tem um atendimento e é um profissional: pegar profissional logado
              if session("Table")="profissionais" then           
                ProfissionalAtendimentoID = session("idInTable")
              end if
              
            end if

            if ProfissionalAtendimentoID <> "" then
              set DadosProfissionalSQL = db_execute("SELECT f.id FornecedorID, prof.RQE, prof.Conselho, prof.NomeProfissional, t.Tratamento, cp.descricao, COALESCE(f.NomeFornecedor, prof.NomeProfissional) RazaoSocial, f.CPF CPFCNPJ , CONCAT(IF(t.Tratamento is null,'',concat(t.Tratamento,' ')),IF(prof.NomeSocial is null or prof.NomeSocial ='', SUBSTRING_INDEX(prof.NomeProfissional,' ', 1), prof.NomeSocial)) PrimeiroNome, "&_
                                                    "CONCAT(cp.descricao, ' ', prof.DocumentoConselho, ' ', prof.UFConselho) Documento, prof.Assinatura, prof.DocumentoConselho, prof.CPF, prof.NomeSocial, esp.especialidade Especialidade "&_
                                                    "FROM profissionais prof "&_
                                                    "LEFT JOIN conselhosprofissionais cp ON cp.id=prof.Conselho "&_
                                                    "LEFT JOIN especialidades esp ON esp.id=prof.EspecialidadeID "&_
                                                    "LEFT JOIN fornecedores f ON f.id=prof.FornecedorID "&_
                                                    "LEFT JOIN tratamento t ON t.id=prof.TratamentoID "&_
                                                    "WHERE prof.id="&ProfissionalAtendimentoID)
              if not DadosProfissionalSQL.eof then
                conteudo = replace(conteudo, "[Profissional.Nome]", trim(DadosProfissionalSQL("NomeProfissional")&""))
                conteudo = replace(conteudo, "[Profissional.RQE]", trim(DadosProfissionalSQL("RQE")&""))
                conteudo = replace(conteudo, "[Profissional.Documento]", trim(DadosProfissionalSQL("Documento")&""))
                conteudo = replace(conteudo, "[Profissional.DocumentoConselho]", trim(DadosProfissionalSQL("DocumentoConselho")&""))
                conteudo = replace(conteudo, "[Profissional.Tratamento]", trim(DadosProfissionalSQL("Tratamento")&""))
                conteudo = replace(conteudo, "[ProfissionalSolicitante.Nome]", trim(DadosProfissionalSQL("NomeProfissional")&""))
              
                if DadosProfissionalSQL("Assinatura")&"" = "" then
                  conteudo = replace(conteudo, "[Profissional.Assinatura]", "______________________________________________")
                else
                  conteudo = replace(conteudo, "[Profissional.Assinatura]", "<img style='max-width:200px;max-height:150px;width:auto;height:auto;' src='"&imgSRC("Imagens",trim(DadosProfissionalSQL("Assinatura"))&"&dimension=full")&"'>" )
                end if

              end if
            end if
          end if

          if item_ProfissionalExternoID>0 then
            qContentSQL = "SELECT pro.NomeProfissional, pro.DocumentoConselho "&_
            "FROM profissionalexterno AS pro "&_
            "LEFT JOIN conselhosprofissionais conPro ON conPro.id=pro.Conselho "&_
            "where pro.id="&item_ProfissionalExternoID
            'response.write("<pre>"&qContentSQL&"</pre>")
            SET ContentSQL = db.execute(qContentSQL)
            if not ContentSQL.eof then
              conteudo = replace(conteudo, "[ProfissionalExecutante.Nome]", trim(ContentSQL("NomeProfissional")&""))
              conteudo = replace(conteudo, "[ProfissionalExecutante.Conselho]", trim(ContentSQL("DocumentoConselho")&" ") )

            end if
           
          end if
        
          'QUERY ALTERADA PARA A MESMA QUERY DO FEEGOW API 27/07/2020
          qProfissionaisContentSQL = "SELECT f.id FornecedorID, prof.RQE, prof.Conselho, prof.NomeProfissional, t.Tratamento, cp.descricao, COALESCE(f.NomeFornecedor, prof.NomeProfissional) RazaoSocial, f.CPF CPFCNPJ , CONCAT(IF(t.Tratamento is null,'',concat(t.Tratamento,' ')),IF(prof.NomeSocial is null or prof.NomeSocial ='', SUBSTRING_INDEX(prof.NomeProfissional,' ', 1), prof.NomeSocial)) PrimeiroNome, "&_
          "CONCAT(cp.descricao, ' ', prof.DocumentoConselho, ' ', prof.UFConselho) Documento, prof.Assinatura, prof.DocumentoConselho, prof.CPF, prof.NomeSocial, esp.especialidade Especialidade "&_
          "FROM profissionais prof "&_
          "LEFT JOIN conselhosprofissionais cp ON cp.id=prof.Conselho "&_
          "LEFT JOIN especialidades esp ON esp.id=prof.EspecialidadeID "&_
          "LEFT JOIN fornecedores f ON f.id=prof.FornecedorID "&_
          "LEFT JOIN tratamento t ON t.id=prof.TratamentoID "&_
          "WHERE prof.id="
          'PROFISSIONAL LAUDADOR
          if inStr(conteudo, "[ProfissionalLaudador") <> 0 Then
            if item_ProfissionalLaudadorID>0 then
              SET ProfissionaisSQL = db.execute(qProfissionaisContentSQL&item_ProfissionalLaudadorID)
              if not ProfissionaisSQL.eof then
                  
                  conteudo = replace(conteudo, "[ProfissionalLaudador.Nome]",       trim(ProfissionaisSQL("NomeProfissional")&""))
                  conteudo = replace(conteudo, "[ProfissionalLaudador.Documento]",  trim(ProfissionaisSQL("Documento")&""))            
                
                if ProfissionaisSQL("Assinatura")&"" = "" then
                  conteudo = replace(conteudo, "[ProfissionalLaudador.Assinatura]", "______________________________________________")
                else
                  conteudo = replace(conteudo, "[ProfissionalLaudador.Assinatura]", "<img style='max-width:200px;max-height:150px;width:auto;height:auto;' src='"&imgSRC("Imagens",trim(ProfissionaisSQL("Assinatura"))&"&dimension=full")&"'>" )
                end if

              end if
              ProfissionaisSQL.close
              set ProfissionaisSQL = nothing
            end if
          end if
          'PROFISSIONAL SOLICITANTE
          if item_ProfissionalSolicitanteID>0 then
            SET ProfissionaisSQL = db.execute(qProfissionaisContentSQL&item_ProfissionalSolicitanteID)
            if not ProfissionaisSQL.eof then
                NomeProfissional = trim(ProfissionaisSQL("NomeProfissional")&" ")
                CPFCNPJProfissional = trim(ProfissionaisSQL("CPF")&" ")

                if not ProfissionaisSQL("FornecedorID")&""<>"" then
                    CPFCNPJProfissional = trim(ProfissionaisSQL("CPFCNPJ")&" ")
                end if

              conteudo = replace(conteudo, "[ProfissionalSolicitante.Nome]", NomeProfissional )
              conteudo = replace(conteudo, "[ProfissionalSolicitante.RazaoSocial]", trim(ProfissionaisSQL("RazaoSocial")&" ") )
              conteudo = replace(conteudo, "[ProfissionalSolicitante.PrimeiroNome]", trim(ProfissionaisSQL("PrimeiroNome")&" ") )
              conteudo = replace(conteudo, "[ProfissionalSolicitante.NomeSocial]", trim(ProfissionaisSQL("NomeSocial")&" ") )
              conteudo = replace(conteudo, "[ProfissionalSolicitante.Especialidade]", trim(ProfissionaisSQL("Especialidade")&" ") )
              conteudo = replace(conteudo, "[ProfissionalSolicitante.Documento]", trim(ProfissionaisSQL("Documento")&" ") )
              conteudo = replace(conteudo, "[ProfissionalSolicitante.CPF]", CPFCNPJProfissional )
              if ProfissionaisSQL("Assinatura")&"" = "" then
                conteudo = replace(conteudo, "[ProfissionalSolicitante.Assinatura]", "______________________________________________")
              else
                conteudo = replace(conteudo, "[ProfissionalSolicitante.Assinatura]", "<img style='max-width:200px;max-height:150px;width:auto;height:auto;' src='"&imgSRC("Imagens",trim(ProfissionaisSQL("Assinatura"))&"&dimension=full")&"'>" )
              end if
              
            end if
            ProfissionaisSQL.close
            set ProfissionaisSQL = nothing
          end if

          if item_ProfissionalID>0 then
            sqlFornecedorProfissional=""
            if item_AssociacaoProfissionalID&""="2" then
                sqlFornecedorProfissional = " AND false or (f.id="&item_ProfissionalID&")"
            end if


            qProfissionaisSQL=qProfissionaisContentSQL&item_ProfissionalID & sqlFornecedorProfissional
          elseif item_ProfissionalSessao>0 AND session("Table")=lcase("profissionais") then 'EXCEÇÃO POR CONTA DO MÓDULO DE RECIBOS E OUTROS LOCAIS QUE PODEM ESTAR UTILIZANDO TAGS [Profissional.ALGUMACOISA] E REFERENCIANDO A SESSÃO DO PROFISSIONAL LOGADO
            qProfissionaisSQL = qProfissionaisContentSQL&item_ProfissionalSessao
          elseif item_ProfissionalID=0 then
            'TRATAMENTO DAS TAGS QUE NÃO FORAM CONVERTIDAS - Airton 12-08-2020
            qtagsSQL="SELECT tagNome FROM cliniccentral.tags WHERE tagNome LIKE 'Profissional.%'"
            SET tagsSQL=db.execute(qtagsSQL)
            while not tagsSQL.eof
                If inStr(conteudo, tagsSQL("tagNome")) <> 0 Then
                    conteudo = replace(conteudo, "["&tagsSQL("tagNome")&"]", trim(" ") )
                  End if
              tagsSQL.movenext
            wend
            tagsSQL.close
          end if
          'FIM TRATAMENTODAS TAGS QUE NÃO FORAM CONVERTIDAS
          if qProfissionaisSQL<>"" then
            SET ProfissionaisSQL = db.execute(qProfissionaisSQL)
            if not ProfissionaisSQL.eof then

                NomeProfissional = trim(ProfissionaisSQL("NomeProfissional")&" ")
                CPFCNPJProfissional = trim(ProfissionaisSQL("CPF")&" ")

                if ProfissionaisSQL("FornecedorID")&""<>"" then
                    CPFCNPJProfissional = trim(ProfissionaisSQL("CPFCNPJ")&" ")
                end if


              conteudo = replace(conteudo, "[Profissional.Nome]", NomeProfissional )
              conteudo = replace(conteudo, "[Profissional.RazaoSocial]", trim(ProfissionaisSQL("RazaoSocial")&" ") )
              conteudo = replace(conteudo, "[Profissional.PrimeiroNome]", trim(ProfissionaisSQL("PrimeiroNome")&" ") )
              conteudo = replace(conteudo, "[Profissional.NomeSocial]", trim(ProfissionaisSQL("NomeSocial")&" ") )
              conteudo = replace(conteudo, "[Profissional.Especialidade]", trim(ProfissionaisSQL("Especialidade")&" ") )
              conteudo = replace(conteudo, "[Profissional.RQE]", trim(ProfissionaisSQL("RQE")&" ") )
              conteudo = replace(conteudo, "[Profissional.Documento]", trim(ProfissionaisSQL("Documento")&" ") )
              conteudo = replace(conteudo, "[Profissional.DocumentoConselho]", trim(ProfissionaisSQL("DocumentoConselho")&" ") )
              conteudo = replace(conteudo, "[Profissional.CPF]", CPFCNPJProfissional )

              if ProfissionaisSQL("Assinatura")&"" = "" then
                conteudo = replace(conteudo, "[Profissional.Assinatura]", "______________________________________________")
              else
                conteudo = replace(conteudo, "[Profissional.Assinatura]", "<img style='max-width:200px;max-height:150px;width:auto;height:auto;' src='"&imgSRC("Imagens",trim(ProfissionaisSQL("Assinatura"))&"&dimension=full")&"'>" )
              end if

              conteudo = replace(conteudo, "[Profissional.Tratamento]", trim(ProfissionaisSQL("Tratamento")&" ") )
              'NOVAS TAGS 06/07/2020
              conteudo = replace(conteudo, "[Profissional.CRM]", trim(ProfissionaisSQL("DocumentoConselho")&" ") )
              conteudo = replace(conteudo, "[Profissional.RQE]", trim(ProfissionaisSQL("RQE")&" ") )
              'Referencia ifrReciboIntegrado.asp ||| Recibo = replace(Recibo, "[ProfissionalExecutante.Conselho]", ProfissionalExecutanteConselho ) 'LINHA 561
              conteudo = replace(conteudo, "[ProfissionalExecutante.Conselho]", trim(ProfissionaisSQL("DocumentoConselho")&" ") )
              conteudo = replace(conteudo, "[ProfissionalExecutante.Nome]", NomeProfissional )
              conteudo = replace(conteudo, "[ProfissionalExecutante.CPF]", CPFCNPJProfissional )
            end if 
          end if
 
        case "Financeiro"

        case "Agendamento"

          if item_AgendamentoID>0 then
            qAgendamentosSQL = "SELECT a.id, a.Data,  a.Hora,  a.TipoCompromissoID,  a.StaID,  a.ValorPlano,  a.rdValorPlano,  a.Notas,  a.Falado,  a.FormaPagto,  a.LocalID,  a.Tempo,  a.HoraFinal,  a.SubtipoProcedimentoID,  a.HoraSta,  a.ConfEmail,  a.ConfSMS,  a.Encaixe,  a.EquipamentoID,  a.NomePaciente,  a.Tel1,  a.Cel1,  a.Email1, a.Procedimentos,  a.EspecialidadeID,  a.IndicadoPor,  a.TabelaParticularID,  a.CanalID,  a.Retorno,  a.RetornoID,  a.Primeira,  a.PlanoID, a.PermiteRetorno, esp.nomeEspecialidade, l.NomeLocal, uni.NomeFantasia,uni.Endereco,uni.Estado,uni.Cidade,uni.Bairro,uni.Endereco,uni.Numero, uni.NomeEmpresa , uni.Complemento, uni.CEP  "_
            &"FROM agendamentos a "_
            &"LEFT JOIN especialidades esp ON esp.id = a.EspecialidadeID "_
            &"LEFT JOIN locais l ON l.id = a.localid "_
            &"LEFT JOIN vw_unidades AS uni ON uni.id=l.UnidadeID "_
            &"WHERE a.id="&item_AgendamentoID

          end if
          if qAgendamentosSQL<>"" then
            SET AgendamentosSQL = db.execute(qAgendamentosSQL)
              if not AgendamentosSQL.eof then
                
                conteudo =  replace(conteudo, "[Agendamento.Data]", AgendamentosSQL("Data")&"" )
                conteudo =  replace(conteudo,"[Agendamento.Especialidade]", AgendamentosSQL("nomeEspecialidade")&"")
                conteudo =  replace(conteudo,"[Agendamento.Procedimento]", AgendamentosSQL("Procedimentos")&"")
                conteudo =  replace(conteudo,"[Agendamento.ID]", AgendamentosSQL("id")&"")

                if isnull(AgendamentosSQL("Hora")) then
                    conteudo = replace(conteudo, "[Agendamento.Hora]", "" )
                else
                    conteudo = replace(conteudo, "[Agendamento.Hora]", formatdatetime(AgendamentosSQL("Hora"),4)&"" )
                end if

                conteudo = replace(conteudo, "[Agendamento.Unidade.NomeFantasia]", trim(AgendamentosSQL("NomeFantasia")&" ") )
                conteudo = replace(conteudo, "[Agendamento.Unidade.Nome]", trim(AgendamentosSQL("NomeEmpresa")&" ") )
                'ENDERECO
                Estado = AgendamentosSQL("Estado")&""
                Cidade = AgendamentosSQL("Cidade")&""
                Bairro = AgendamentosSQL("Bairro")&""
                Endereco = AgendamentosSQL("Endereco")&""
                Numero = AgendamentosSQL("Numero")&""
                Complemento = AgendamentosSQL("Complemento")&""

                EnderecoCompleto = replace(Endereco&", "&Numero&", "&Complemento&", "&Bairro&", "&Cidade&", "&Estado, ", , ", ", " )

                conteudo = replace(conteudo, "[Agendamento.Unidade.Cep]", trim(AgendamentosSQL("CEP")&" ") )
                conteudo = replace(conteudo, "[Agendamento.Unidade.Estado]", trim(AgendamentosSQL("Estado")&" ") )
                conteudo = replace(conteudo, "[Agendamento.Unidade.Cidade]", trim(AgendamentosSQL("Cidade")&" ") )
                conteudo = replace(conteudo, "[Agendamento.Unidade.Bairro]", trim(AgendamentosSQL("Bairro")&" ") )
                conteudo = replace(conteudo, "[Agendamento.Unidade.Endereco]", trim(AgendamentosSQL("Endereco")&" ") )
                conteudo = replace(conteudo, "[Agendamento.Unidade.Numero]", trim(AgendamentosSQL("Numero")&" ") )
                conteudo = replace(conteudo, "[Agendamento.Unidade.Complemento]", trim(AgendamentosSQL("Complemento")&" ") )
                conteudo = replace(conteudo, "[Agendamento.Unidade.EnderecoCompleto]", trim(EnderecoCompleto))

              end if
            AgendamentosSQL.close
            set AgendamentosSQL = nothing
          end if
        case "Procedimento"

          if item_ProcedimentoID>0 then
            qProcedimentosSQL = "SELECT p.NomeProcedimento, p.DiasLaudo, p.TextoPreparo, t.TipoProcedimento "_
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
              conteudo = replace(conteudo, "[Procedimento.Preparo]", ProcedimentosSQL("TextoPreparo")&"" )
            end if
            ProcedimentosSQL.close
            set ProcedimentosSQL = nothing
          end if
          if item_ProcedimentoNome<>"" then
            conteudo = replace(conteudo, "[Procedimento.Nome]", item_ProcedimentoNome&"" )
          end if
        case "Atendimento"
          if item_AtendimentoID>0 then
            qAtendimentosSQL = " SELECT ate.Data,ate.HoraInicio,COALESCE(ate.HoraFim,'_____:______') AS HoraFim,COALESCE(TIMEDIFF(HoraFim,HoraInicio),'_____:______') AS Duracao,ate.Obs,IF(ate.Triagem='S','Sim','Não') AS Triagem,"&chr(13)&_
                            " pac.id AS PacienteID,                                          "&chr(13)&_
                            " uni.NomeEmpresa                                                "&chr(13)&_
                            " FROM atendimentos AS ate                                       "&chr(13)&_
                            " LEFT JOIN pacientes AS pac ON pac.id=ate.PacienteID            "&chr(13)&_
                            " LEFT JOIN profissionais AS pro ON pro.id=ate.ProfissionalID    "&chr(13)&_
                            " LEFT JOIN vw_unidades AS uni ON uni.id=ate.UnidadeID           "&chr(13)&_
                            " WHERE ate.id="&item_AtendimentoID

            SET AtendimentosSQL = db.execute(qAtendimentosSQL)
            if not AtendimentosSQL.eof then
              conteudo = replace(conteudo, "[Atendimento.Data]", AtendimentosSQL("Data")&"" )
              conteudo = replace(conteudo, "[Atendimento.HoraInicio]", right(AtendimentosSQL("HoraInicio"),8)&"" )
              conteudo = replace(conteudo, "[Atendimento.HoraFim]", AtendimentosSQL("HoraFim")&"" )
              conteudo = replace(conteudo, "[Atendimento.Duracao]", AtendimentosSQL("Duracao")&"" )
              conteudo = replace(conteudo, "[Atendimento.Obs]", AtendimentosSQL("Obs")&"" )
              conteudo = replace(conteudo, "[Atendimento.Triagem]", AtendimentosSQL("Triagem")&"" )
              conteudo = replace(conteudo, "[Atendimento.Unidade]", AtendimentosSQL("NomeEmpresa")&"" )

              'PUXA INFORMAÇÕES DO PACIENTE QUE FOI ATENDIDO
              if inStr(conteudo, "[Paciente.") > 0 Then
                Call TagsConverte(conteudo,"PacienteID_"&AtendimentosSQL("PacienteID"),"")
              end if

            end if
            AtendimentosSQL.close
            set AtendimentosSQL = nothing


            

          end if
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
            qRecibosSQL = "SELECT debito.sysDate as ReciboSysDate, COALESCE(CONCAT(debito.InvoiceID,'.',rec.id),debito.InvoiceID) AS ReciboID, IF(bm.id IS NOT NULL, 1, cartao_credito.Parcelas) Parcelas, IF(bm.id IS NOT NULL, 'Boleto', IF(credito.`Type` = 'Transfer','CrÃ©dito', forma_pagamento.PaymentMethod)) PaymentMethod, pagamento.MovementID, IF(bm.id IS NOT NULL, debito.Value,credito.`value`) Value, IF(bm.id IS NOT NULL, debito.sysUser, credito.sysUser) sysUser, debito.Date DataVencimento, credito.Date DataPagamento "_
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
              conteudo = replace(conteudo, "[Recibo.Data]", RecibosSQL("ReciboSysDate")&"" )
              conteudo = replace(conteudo, "[Recibo.DataExtenso]", formatdatetime(RecibosSQL("ReciboSysDate"),1)&"" )
            end if
            RecibosSQL.close
            set RecibosSQL = nothing
          end if


        case "Contrato"

          if item_ContratoID>0 then
            'REPLICADO COM BASE NO "addContrato.asp"
            qContratosSQL = "SELECT id FROM sys_financialinvoices WHERE id="&item_ContratoID
            SET ContratosSQL = db.execute(qContratosSQL)
            if not ContratosSQL.eof then
              conteudo = replace(conteudo, "[Contrato.Protocolo]", trim(ContratosSQL("id")&" ") )
            end if
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

        Case "Receita"
          if item_ReceitaID>0 then
            'QUERY DE REFERENCIA ifrReciboIntegrado.asp
            qReceitaSQL = "SELECT cartao_credito.Parcelas Parcelas, IF(credito.`Type` = 'Transfer','Crédito', forma_pagamento.PaymentMethod) PaymentMethod, "&_
                          "pagamento.MovementID, credito.`value` Value, credito.sysUser sysUser, debito.Date DataVencimento, credito.Date DataPagamento "&_
                          "FROM sys_financialmovement debito "&_
                          "LEFT JOIN sys_financialdiscountpayments pagamento ON pagamento.InstallmentID = debito.id  "&_
                          "LEFT JOIN sys_financialmovement credito ON credito.id=pagamento.MovementID "&_
                          "LEFT JOIN sys_financialpaymentmethod forma_pagamento ON forma_pagamento.id = credito.PaymentMethodID "&_
                          "LEFT JOIN sys_financialcreditcardtransaction cartao_credito ON cartao_credito.MovementID=credito.id "&_
                          "WHERE debito.InvoiceID="&item_ReceitaID &" "&_
                          "UNION ALL "&_
                          "SELECT 1 Parcelas, 'Boleto' PaymentMethod, NULL, debito.Value VALUE, debito.sysUser  sysUser, debito.Date DataVencimento, null DataPagamento "&_
                          "FROM sys_financialmovement debito "&_
                          "INNER JOIN boletos_emitidos bm ON bm.MovementID=debito.id AND bm.StatusID IN (3, 4) "&_
                          "INNER JOIN cliniccentral.boletos_status bs ON bs.id=bm.StatusID "&_
                          "WHERE debito.InvoiceID="&item_ReceitaID
          
          end if

          if qReceitaSQL<>"" then
            SET ReceitaSQL = db.execute(qReceitaSQL)
            if not ReceitaSQL.eof then
              while not ReceitaSQL.eof
                PaymentMethod = ReceitaSQL("PaymentMethod")&""
                Parcela = ReceitaSQL("Parcelas")&""
                value = ReceitaSQL("value")&""
                Vencimento = ReceitaSQL("DataVencimento")&""
                Pagamento = ReceitaSQL("DataPagamento")&""

                DataVencimento = DataVencimento&"<br>"&Vencimento
                DataPagamento = DataPagamento&"<br>"&Pagamento


                if PaymentMethod<>"" then

                    if Parcela<>"" then
                        Parcelas =  ccur(Parcela)
                    else
                        Parcelas = "1"
                    end if
                    if value<>"" then
                        valorForma = "R$ "&formatnumber(value, 2)
                    else
                        valorForma = "R$ 0,00"
                    end if

                    FormaPagtoTabelaHTML = "<tr><td width='100'>"&Parcelas&"</td><td>"&PaymentMethod &"</td><td>"&valorForma&"</td></tr>"

                    if tabelaConteudoHTML&""="" then
                      tabelaConteudoHTML = FormaPagtoTabelaHTML
                    else
                      tabelaConteudoHTML = tabelaConteudoHTML&FormaPagtoTabelaHTML
                    end if
                    FormaPagtoOri = "<br>"&"("& Parcelas &"x) "&PaymentMethod &" = "&valorForma
                    FormaPagto = FormaPagto &""& FormaPagtoOri
                    
                    if MetodoRecebimento&""="" then
                      MetodoRecebimento = PaymentMethod
                    else
                      MetodoRecebimento = MetodoRecebimento&", "&PaymentMethod
                    end if
                end if

              ReceitaSQL.movenext
              wend
            ReceitaSQL.close
            set ReceitaSQL = nothing

            tabelaInicioHTML  = "<table class='table table-striped table-condensed table-bordered table-hover'><thead><th>Parcela</th><th width='150'>Forma</th><th>Valor</th></thead><tbody>"
            tabelaFimHTML     = "</tbody></table>"
            
            if FormaPagto&""<>"" and instr(conteudo,"[Receita.FormaPagamento]") then
              conteudo = replace(conteudo, "[Receita.FormaPagamento]", tabelaInicioHTML&tabelaConteudoHTML&tabelaFimHTML)
            end if

            conteudo = replace(conteudo, "[Receita.MetodoRecebimento]", MetodoRecebimento&"" )
            'GERADO A PARTIR DO RECIBO
            'conteudo = replace(conteudo, "[Receita.ValorPagoExtenso]", ValorMonetarioExtenso(ValorPagoExtenso)&"" )
          end if
          

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
'response.write(TagsConverte("paciente: [Paciente.Nome]<br>Convenio: [Paciente.Convenio1]<br>Plano: [Paciente.Plano1]<br>Recibo: [Recibo.Data] ([Recibo.DataExtenso])","PacienteID_140243|AgendamentoID_274564|ProfissionalID_16|ReciboID_495278",""))
%>
