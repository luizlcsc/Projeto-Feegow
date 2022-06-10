<!--#include file="connect.asp"-->
<!--#include file="Classes/Logs.asp"-->
<%
TabelaInputID = req("I")
IDTabelaInversa = ref("idoutratabela")
Unidades = ref("Unidades")
Atuacao  = ref("Atuacao")
TabelaBase = ref("TabelaBase")
if Unidades = "0" then
    Unidades = "|0|"
end if

function updateProcedimentosTabelaValor(TabelaID, ProcedimentoPrefixoID)

    set ProcedimentosSQL = db.execute("select p.id, ptv.id ValorTabelaID from procedimentos p LEFT JOIN procedimentostabelasvalores ptv ON ptv.ProcedimentoID=p.id AND ptv.TabelaID="&treatvalzero(TabelaID)&" where p.sysActive=1 and p.ativo='on'")
    while not ProcedimentosSQL.eof
        ProcedimentoID = ProcedimentosSQL("id")
        ValorTabelaID = ProcedimentosSQL("ValorTabelaID")
        ValorTabela = ref("ValorTabela"& ProcedimentoPrefixoID & ProcedimentoID)
        ValorInputPreenchido = ValorTabela<>"" AND isnumeric(ValorTabela)

        LogDetalhe = ""

        if ProcedimentoPrefixoID&""<>"" then
            LogDetalhe = " (Tabela Inversa)"
        end if

        if ValorInputPreenchido then
            if isnull(ValorTabelaID) then
                sqlInsert = "insert into procedimentostabelasvalores (ProcedimentoID, TabelaID, Valor , TabelaBase ) VALUES ("& ProcedimentoID &", "& TabelaID &", "&treatvalzero(ValorTabela)&", '"&TabelaBase&"'   )"
               
                db.execute(sqlInsert)
                call gravaLogs(sqlInsert ,"AUTO", "Valor do procedimento na tabela adicionado"&LogDetalhe,"TabelaID")

            else
                sqlUpdate = "update procedimentostabelasvalores set Valor="& treatvalzero(ValorTabela) & ", TabelaBase='"&Atuacao&"' WHERE TabelaID="&TabelaID&" AND id="&ValorTabelaID

                call gravaLogs(sqlUpdate ,"AUTO", "Valor do procedimento na tabela alterado"&LogDetalhe, "TabelaID")
                db.execute(sqlUpdate)
            end if
       
        end if
    ProcedimentosSQL.movenext
    wend
    ProcedimentosSQL.close
    set ProcedimentosSQL=nothing
end function

Title = "Sucesso!"
Erro = "Valores da tabela alterado."
Tipo = "success"

if ref("NomeTabela")&"" <> "" then
    sqlUpdateTabela = "update procedimentostabelas set NomeTabela='"& ref("NomeTabela") &"', Inicio="& mydatenull(ref("Inicio")) &", Tipo='"& ref("Tipo") &"', Fim="& mydatenull(ref("Fim")) &", TabelasParticulares='"& ref("TabelasParticulares") &"', Profissionais='"& ref("Profissionais") &"', Especialidades='"& ref("Especialidades") &"', Unidades='"& Unidades &"',  tabelabase ='"&TabelaBase&"' , Atuacao ='"&Atuacao&"' , sysActive=1 where id="& TabelaInputID

    call gravaLogs(sqlUpdateTabela ,"AUTO", "Tabela de preço alterada","")
    db.execute(sqlUpdateTabela)

    call updateProcedimentosTabelaValor(TabelaInputID, "")

    if IDTabelaInversa&""<>"" then
        call updateProcedimentosTabelaValor(IDTabelaInversa, IDTabelaInversa&"_")
    end if
else
    Title = "Erro!"
    Erro = "Não foi possível atualizar tabela."
    Tipo = "danger"
end if

%>

new PNotify({
    title: '<%=Title%>',
    text: '<%=Erro%>',
    type: '<%=Tipo%>',
    delay: 3000
});
