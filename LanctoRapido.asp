<!--#include file="connect.asp"-->
<%
db_execute("delete from tempinvoice where sysUser="&session("User")&";")



Tipo = ref("TipoBotao")
if Tipo="" then
    Tipo = req("TipoBotao")
end if
PacienteID = req("PacienteID")

if Tipo="AReceber" then
	sqlInv = "select * from sys_financialinvoices where sysActive=0 and sysUser="&session("User")&" and CD='C'"
	'Ve se tem alguma invoice CD=C com sysActive=0 no user=session, se não tiver cria e guarda o id
	set inv = db.execute(sqlInv)
	if inv.eof then
		db_execute("insert into sys_financialinvoices (`Name`,`Value`, Tax, Currency, Recurrence, RecurrenceType, CD, sysActive, sysUser) values ('Gerado a partir de agendamento {1}', 0, 1, 'BRL', 1, 'm', 'C', 0, "&session("User")&")")
		set inv = db.execute(sqlInv)
	end if
	InvoiceID = inv("id")
	'Apaga todos os itensinvoice desta invoice
	db_execute("delete from tempinvoice where InvoiceID="&InvoiceID)
	'Splita os Lancto e adiciona nos itens invoice de acordo com as informações
	spl = split(ref("Lancto"), ", ")
    if ubound(spl) = -1 then
       'Busca a tabela cadastrada no cadastro do Paciente para ser usada na tela de conta 
       set rs = db.execute("select tabela from pacientes where id=" & PacienteID)
       if not rs.eof then
            TabelaID = rs("tabela")
            rs.close
       end if      
    end if 
    
    set rs = nothing

	UnidadeIDAgendada=""
	for i=0 to ubound(spl)
        if spl(i)<>"" then
		    spl2 = split(spl(i), "|")
		    AgeAte = spl2(1)
		    idAgeAte = spl2(0)
		    Executado = "S"
		    if AgeAte = "executado" then
			    sqlAtendimentoID = idAgeAte
			    set aEa = db.execute("select '' UnidadeID, ap.id, at.Data, at.HoraInicio, at.HoraFim, ap.ProcedimentoID, at.ProfissionalID, 0 EspecialidadeID, ap.Obs, ap.ValorPlano, ap.rdValorPlano, at.PacienteID, 'executado', 'executado', at.AgendamentoID, at.TabelaID, '' indicadopor from atendimentosprocedimentos as ap left join atendimentos as at on at.id=ap.AtendimentoID where ap.id="&idAgeAte)
		    else
			    sqlAtendimentoID = "NULL"
			    set aEa = db.execute("select loc.UnidadeID, ag.id, ag.Data, ag.Hora as HoraInicio, ag.HoraFinal as HoraFim, ag.TipoCompromissoID as ProcedimentoID, ag.ProfissionalID, ag.EspecialidadeID, ag.Notas as Obs, ag.ValorPlano, ag.rdValorPlano, ag.PacienteID, ag.StaID as Icone, 'agendamento' as Tipo, ag.id as AgendamentoID, ag.TabelaParticularID TabelaID, ag.indicadopor from agendamentos as ag LEFT JOIN locais loc ON loc.id=ag.LocalID where ag.id="&idAgeAte&" UNION  "&_
                "SELECT loc.UnidadeID, ag.id, ag.Data, ag.Hora as HoraInicio, DATE_ADD(ag.Hora,INTERVAL agproc.Tempo MINUTE) as HoraFim, "&_
                " agproc.TipoCompromissoID as ProcedimentoID, ag.ProfissionalID, ag.EspecialidadeID, ag.Notas as Obs, "&_
                "agproc.ValorPlano, agproc.rdValorPlano, ag.PacienteID, ag.StaID as Icone, 'agendamento' as Tipo, ag.id as AgendamentoID, ag.TabelaParticularID TabelaID, '' indicadopor   "&_
                "FROM agendamentosprocedimentos agproc "&_
                "LEFT JOIN agendamentos ag ON ag.id=agproc.AgendamentoID "&_
                "LEFT JOIN locais loc ON loc.id=ag.LocalID "&_
                "WHERE AgendamentoID="&idAgeAte)
		    end if

		    'set aEa = db.execute("select * from agendamentoseatendimentos where id="&spl2(0)&" and Tipo='"&spl2(1)&"'")
		    if not aEa.eof then
                UnidadeIDAgendada=aEa("UnidadeID")&""
                EspecialidadeID=""

                while not aEa.eof
                    if EspecialidadeID&""="" or EspecialidadeID="0" then
                        EspecialidadeID=aEa("EspecialidadeID")
                    end if
                    if cdate(formatdatetime(aEa("Data"), 2))>date() then
                        Executado=""
                    end if
                    TabelaID = aEa("TabelaID")

                    ProcedimentoID = aEa("ProcedimentoID")
                    DataExecucao = aEa("Data")
                    if isdate(aEa("HoraInicio")) then
                        HoraExecucao = formatdatetime(aEa("HoraInicio"),3)
                    end if
                    AgendamentoID = aEa("AgendamentoID")
                    ProfissionalID = aEa("ProfissionalID")
                    indicadopor = aEa("indicadopor")
                    if isdate(aEa("HoraFim")) then
                        HoraFim = formatdatetime(aEa("HoraFim"),3)
                    end if
                    if aEa("rdValorPlano")="V" then
                        Valor = aEa("ValorPlano")
                        set KitParticularSQL = db.execute("SELECT pk.* FROM procedimentoskits pk WHERE pk.ProcedimentoID="&ProcedimentoID&" AND pk.Casos LIKE '%|P|%'")

                        if not KitParticularSQL.eof then

                            while not KitParticularSQL.eof

                                set pct = db.execute("select pdk.ProdutoID, pdk.Valor, pdk.Quantidade from produtosdokit pdk INNER JOIN produtos p ON p.id=pdk.ProdutoID where pdk.KitID="&KitParticularSQL("KitID"))
                                while not pct.EOF
                                    ItemID = pct("ProdutoID")'id do procedimento
                                    ValorUnitario = pct("Valor")
                                    Quantidade = pct("Quantidade")&""
                                    if Quantidade = "" then
                                        Quantidade = 0
                                    end if 
                                    Subtotal = ValorUnitario * Quantidade
                                    PacoteID = II
                                    Executado="U"

                                    db_execute("insert into tempinvoice (InvoiceID, Tipo, Quantidade, CategoriaID, ItemID, ValorUnitario, Desconto, Executado, DataExecucao, HoraExecucao, GrupoID, AgendamentoID, sysUser, ProfissionalID, HoraFim, AtendimentoID) values ("&InvoiceID&", 'M', "&Quantidade&", 0, "&ItemID&", "&treatvalzero(ValorUnitario)&", 0, '"&Executado&"', "&mydatenull(DataExecucao)&", '"&HoraExecucao&"', 0, "&AgendamentoID&", "&session("User")&", "&treatvalzero(ProfissionalID)&", '"&HoraFim&"', "&sqlAtendimentoID&")")

                                pct.movenext
                                wend
                                pct.close
                                set pct=nothing


                            KitParticularSQL.movenext
                            wend
                            KitParticularSQL.close
                            set KitParticularSQL=nothing
                        end if
                    else
                        set Proc = db.execute("select * from procedimentos where id="&ProcedimentoID)
                        if Proc.EOF then
                            Valor = 0
                        else
                            Valor = Proc("Valor")
                        end if
                    end if

                    db_execute("insert into tempinvoice (InvoiceID, Tipo, Quantidade, CategoriaID, ItemID, ValorUnitario, Desconto, Executado, DataExecucao, HoraExecucao, GrupoID, AgendamentoID, sysUser, ProfissionalID, EspecialidadeID, HoraFim, AtendimentoID) values ("&InvoiceID&", 'S', 1, 0, "&ProcedimentoID&", "&treatvalzero(Valor)&", 0, '"&Executado&"', "&mydatenull(DataExecucao)&", '"&HoraExecucao&"', 0, "&AgendamentoID&", "&session("User")&", "&treatvalzero(ProfissionalID)&",  "&treatvalzero(EspecialidadeID)&", '"&HoraFim&"', "&sqlAtendimentoID&")")
                aEa.movenext
                wend
                aEa.close
                set aEa = nothing
		    end if
        end if
	next
	if UnidadeIDAgendada<>"" then
	    db.execute("UPDATE sys_financialinvoices SET CompanyUnitID="&treatvalnull(UnidadeIDAgendada)&" WHERE id="&InvoiceID)
	end if
	'Redireciona para a invoice informando Pac
	response.Redirect("invoice.asp?Pers=1&T=C&I="&InvoiceID&"&PacienteID="&PacienteID&"&Lancto=Dir&TabelaID="&TabelaID&"&ProfissionalSolicitante="&indicadopor )
elseif Tipo="GuiaConsulta" then
	if ref("Lancto")="" then
		Lancto = PacienteID&"|Paciente"
    else
        splLancto = split(ref("Lancto"), ", ")
        for i=0 to ubound(splLancto)
            if Lancto="" then
                Lancto = splLancto(i)
            end if
        next
'        response.write(Lancto &"<br>")
	end if
	'Redireciona para a guia de consulta passando o id|tipo
	response.Redirect("tissguiaconsulta.asp?P=tissguiaconsulta&I=N&Pers=1&Lancto="&Lancto)
elseif Tipo="GuiaSADT" then
	Lancto = ref("Lancto")
	if Lancto="" then
		Lancto = PacienteID&"|Paciente"
	end if
	response.Redirect("tissguiasadt.asp?P=tissguiasadt&I=N&Pers=1&Lancto="&Lancto)
elseif Tipo="GuiaHonorarios" then
	Lancto = ref("Lancto")
	if Lancto="" then
		Lancto = PacienteID&"|Paciente"
	end if
	response.Redirect("tissguiahonorarios.asp?P=tissguiahonorarios&I=N&Pers=1&Lancto="&Lancto)
elseif Tipo="GuiaInternacao" then
    Lancto = ref("Lancto")
    if Lancto="" then
    	Lancto = PacienteID&"|Paciente"
    end if
    response.Redirect("tissguiainternacao.asp?P=tissguiainternacao&I=N&Pers=1&Lancto="&Lancto)
end if
%>