<!--#include file="connect.asp"-->
<!--#include file="Classes/TagsConverte.asp"-->
<!--#include file="./Classes/Json.asp"-->
<!--#include file="Classes/StringFormat.asp"-->
<%
PrintSpan = True

if req("Tipo")="F" then
	set getFormula = db.execute("select * from PacientesFormulas where id="&ref("id"))
	if not getFormula.eof then
		if len(getFormula("Uso"))>0 and req("JaTemUso")<>"true" or (session("Banco")= "clinic6073" or session("Banco")= "clinic6056") then
			TextoFinal = "<p><strong>Uso "& getFormula("Uso") &"</strong></p>"
		end if
		TextoFinal = TextoFinal
		set comps = db.execute("select * from componentesformulas where not Substancia like '' and sysActive=1 and FormulaID="&ref("id"))
		while not comps.EOF
		    strong1 = ""
            strong2 = ""
            if session("Banco")="clinic6056" or session("Banco")="clinic105" then
                strong1 = "<strong>"
                strong2 = "</strong>"
            end if
			TextoFinal = TextoFinal & strong1&comps("Substancia")&strong2
			pontos = 60 - len(comps("Substancia")) - len(comps("Quantidade"))
			if pontos<0 then
				pontos = 0
			end if
			c=0
			while c<pontos
				c=c+1
				TextoFinal = TextoFinal &"."
			wend
			TextoFinal = TextoFinal &strong1&comps("Quantidade") &strong2&"<br>"
		comps.movenext
		wend
		comps.close
		set comps = nothing
'		TextoFinal = "<span style=""font-family:courier new,courier,monospace"">" & TextoFinal & getFormula("Prescricao") &"</span>"
		TextoFinal = TextoFinal & getFormula("Prescricao")
	end if
elseif req("Tipo")="M" then
	set listaMedicamentos = db.execute("select * from PacientesMedicamentos where id="&ref("id"))
	if not listaMedicamentos.eof then
		Tamanho = len(listaMedicamentos("Medicamento")) + len(listaMedicamentos("Apresentacao")) + len(listaMedicamentos("Quantidade"))
		Pontilhados = 60-Tamanho
		Prescricao = "<strong>Uso "&listaMedicamentos("Uso")&"</strong><br />"
		if req("JaTemUso")="true" and session("Banco")<>"clinic6056" then
		    Prescricao=""
		end if
		strong1 = ""
		strong2 = ""
		if session("Banco")="clinic6056" or session("Banco")="clinic105" then
		    strong1 = "<strong>"
		    strong2 = "</strong>"
		end if
		Prescricao = "<p>"&Prescricao&strong1&"<b>"&ref("qtdMedicamentos")&".</b> "&listaMedicamentos("Medicamento")&" "&strong2
            		cp=0
		while cp<Pontilhados
			Prescricao = Prescricao&"."
			cp = cp+1
		wend
		Prescricao = Prescricao &"."& strong1&listaMedicamentos("Quantidade")&" "&listaMedicamentos("Apresentacao")&strong2&"<br />"&listaMedicamentos("Prescricao")&"</p>"
'		TextoFinal = "<span style=""font-family:courier new,courier,monospace"">" & Prescricao & "</span>"
		TextoFinal = Prescricao
	end if
elseif req("Tipo")="A" then
	set listaAtestado = db.execute("select * from pacientesatestadostextos where id="&ref("id"))
	if not listaAtestado.eof then
		TituloAtestado = listaAtestado("TituloAtestado")
		if TituloAtestado <> "" then
			Atestado = "<p><strong>"&TituloAtestado&"</strong><br /><br />"
		end if
		Atestado = Atestado &listaAtestado("TextoAtestado")&"</p>"
		TextoFinal = Atestado

		PacienteID = req("PacienteID")
		if session("Table")="profissionais" then
			ProfissionalID = session("idInTable")
			qAtendimentosSQL = 	" SELECT a.id                               "														&chr(13)&_
													" FROM atendimentos AS a                    "														&chr(13)&_
													" WHERE PacienteID="&PacienteID&" AND a.ProfissionalID="&ProfissionalID	&chr(13)&_
													" ORDER BY a.id DESC                        "														&chr(13)&_
													" LIMIT 1                                   "
			SET AtendimentoSQL = db.execute(qAtendimentosSQL)
				if not AtendimentoSQL.eof then
					AtendimentoID = AtendimentoSQL("id")
					TextoFinal = tagsConverte(TextoFinal,"AtendimentoID_"&AtendimentoID,"")
				end if
			AtendimentoSQL.close
			set AtendimentoSQL = nothing
		else
			ProfissionalID=0
		end if
		
	end if
elseif req("Tipo")="E" then
    if ref("Tipo")="Exame" then
        set ProcedimentosNomeSQL = db.execute("SELECT NomeProcedimento, id, TextoPedido FROM procedimentos WHERE ID = "&ref("id"))
            PrintSpan=False

            call responseJson(recordToJSON(ProcedimentosNomeSQL))
     else
        set listaPedido = db.execute("select * from pacientespedidostextos where id="&ref("id"))
        if not listaPedido.eof then
            Pedido = "<p><strong>"&listaPedido("TituloPedido")&"</strong>"
            Pedido = Pedido &listaPedido("TextoPedido")&"</p>"
            TextoFinal = Pedido
        end if
    end if
'	var PedidoExame = "<p><strong>"+$("#TituloPedido"+id).html()+"</strong><br /><br />";
'	PedidoExame = PedidoExame + $("#TextoPedido"+id).html()+"</p>";
'	$("#pedidoexame").val($("#pedidoexame").val()+PedidoExame);
end if

'CONVERTER ALGUNS BUGS DE TAGS DE PACIENTE QUE NÃO CONVERTEM
TextoFinal = tagsConverte(TextoFinal,"PacienteID_"&req("PacienteID"),"")

'MANTIVE O CONVERSOR DE TAGS ANTIGO PARA NÃO AFETAR OUTRAS POSSÍVEIS CONVERSÕES.
TextoFinal = replaceTags(TextoFinal, req("PacienteID"), session("User"), session("UnidadeID"))



if PrintSpan then
    response.Write("<span style=""font-family:courier new,courier,monospace"">" & TextoFinal & "</span>")
end if
%>