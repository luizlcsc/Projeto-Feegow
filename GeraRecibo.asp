<!--#include file="connect.asp"-->
<!--#include file="extenso.asp"-->
<%

set pro = db.execute("select * from profissionais where id="&ref("EmitenteRecibo"))
if not pro.EOF then
	set Trat = db.execute("select * from tratamento where id="&pro("TratamentoID"))
	if not Trat.eof then
		Tratamento = trat("Tratamento")
	end if
	NomeProfissional = Tratamento&" "&pro("NomeProfissional")
	set codigoConselho = db.execute("select * from conselhosprofissionais where id = '"&pro("Conselho")&"'")
	if not codigoConselho.eof then
		DocumentoProfissional = codigoConselho("codigo")&": "&pro("DocumentoConselho")&"-"&pro("UFConselho")
	end if
end if

PacienteID=ref("PacienteID")

set AgendamentoSQL = db.execute("SELECT proc.NomeProcedimento, age.ProfissionalID,age.Data,IF(age.rdValorPlano='P',0,age.ValorPlano)Valor FROM agendamentos age INNER JOIN procedimentos proc ON proc.id=age.TipoCompromissoID WHERE age.Data = CURDATE() AND age.PacienteID="&PacienteID)

Data = ref("DataRecibo")
Valor = ref("ValorRecibo")
Servicos= ref("ServicosRecibo")

if not AgendamentoSQL.eof then
    Emitente = AgendamentoSQL("ProfissionalID")
    Servicos = AgendamentoSQL("NomeProcedimento")
    Data = AgendamentoSQL("Data")
    Valor = AgendamentoSQL("Valor")
end if

set ReciboAvulsoSQL = db.execute("SELECT ReciboAvulso FROM impressos WHERE id=1 and ReciboAvulso IS NOT NULL AND ReciboAvulso<>''")
if not ReciboAvulsoSQL.eof then
    Texto = ReciboAvulsoSQL("ReciboAvulso")
    Texto = replaceTags(Texto&"", PacienteID, session("User"), session("Unidade"))

    Function PadZero(strIn, lngPad)
        If Len(strIn) < lngPad Then strIn = Right(String(lngPad+1,"0") & strIn, lngPad)
        PadZero = strIn
    End Function

    'replace tags recibo
    ReciboID = 1
    set UltimoReciboSQL = db.execute("SELECT id FROM recibos ORDER BY id DESC LIMIT 1")
    if not UltimoReciboSQL.eof then
        ReciboID = UltimoReciboSQL("id")+1
    end if

    Texto = replace(Texto, "[Recibo.ID]", PadZero(ReciboID, 5))
    Texto = replace(Texto, "[Recibo.Mes]", MonthName(month(Data)))
    Texto = replace(Texto, "[Recibo.Dia]", day(Data))
    Texto = replace(Texto, "[Recibo.Ano]", year(Data))
    Texto = replace(Texto, "[Recibo.Valor]", "R$ "&fn(Valor))
    Texto = replace(Texto, "[Recibo.ValorExtenso]", extenso(Valor))
    Texto = replace(Texto, "[Recibo.Servicos]", Servicos)

    response.write(Texto)
else
    %>
<h2 style="text-align: center;">RECIBO</h2>
<br>
<p style="text-align: center;"><%= NomeProfissional %><br><%= DocumentoProfissional %></p>
<br>
<p>Valor: R$ <%=Valor%></p>
<p>Recebi de <%=ref("NomeRecibo")%> a quantia supra mencionada de <%=lcase(Extenso( Valor ))%> referente a <%=Servicos%>.</p>
<br>
<br>
<p style="text-align:right"><%=formatdatetime(Data, 1)%></p>
    <%
end if

%>