<!--#include file="connect.asp"-->
<%
response.Charset="utf-8"

convenio    = req("convenio")
acao        = req("acao")
id          = ref("id")&""
Imposto     = ref("Imposto")
Contratos   = ref("Contratos")
planoConta  = ref("planoConta")
centroCusto = ref("centroCusto")
valor       = ref("valor")
de          = ref("de")
ate         = ref("ate")


if contratos&"" = "" then
    dd(contratos)
    ' trowError("a","Contratos")
end if 

contratosSpl  =  split(contratos,",")




function eNull(val)
    if not isnumeric(Val) or val&"" = "" then
        eNull = "null"
    end if
    eNull = val
end function 

function trowError(Val,campo)
	valorTratado = eNull(Val)
    if retorno = "null" then
        %>
        new PNotify({
            title: 'Erro',
            text:'O valor do campo',
            type:'erro',
            delay:500
        });
        <%
        response.end
    end if 
    trowError = val
end function



Select Case acao
    case "N"
        sqlInsert = "INSERT INTO impostos_associacao (convenio,imposto,planoContas,CentroCusto,valor,de,ate) value ('"&trowError(convenio,"Convenio")&"','"&trowError(Imposto,"imposto")&"','"&trowError(planoConta,"Plano de contas")&"','"&trowError(CentroCusto,"Centro de custo")&"','"&trowError(treatVal(valor),"Valor")&"','"&trowError(treatVal(de),"De")&"','"&trowError(treatVal(ate),"Ate")&"');"
        db.execute(sqlInsert)
        set lastInsert = db.execute("SELECT LAST_INSERT_ID() as Last")
        for i=0 to ubound(contratosSpl)
            sqlContratoInsert = "insert into impostos_contratos_convenio (impostos_associacao_id,contratosConvenio_id) value("&lastInsert("last")&","&replace(contratosSpl(i),"|","")&")"
            db.execute(sqlContratoInsert)
        next
    case "X"
        call trowError(id,"Regra nao selecionada")
        sqlDelete = "DELETE FROM impostos_associacao WHERE id="&id
        sqlDeleteContrato = "DELETE FROM impostos_contratos_convenio WHERE impostos_associacao_id="&id
        db.execute(sqlDelete)
        db.execute(sqlDeleteContrato)
End Select

%>