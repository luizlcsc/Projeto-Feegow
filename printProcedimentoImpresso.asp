<!--#include file="connect.asp"-->
<%
ProcedimentoID= req("ProcedimentoID")
PacienteID= req("PacienteID")
ProfissionalID= req("ProfissionalID")
UnidadeID= req("UnidadeID")
ImpressoID= req("I")


if ImpressoID<>"" then
    sqlImpresso = "SELECT * FROM procedimentosmodelosimpressos WHERE id="&ImpressoID
else
    sqlImpresso = "SELECT * FROM procedimentosmodelosimpressos WHERE Procedimentos LIKE '|%"&ProcedimentoID&"%|' AND (UnidadeID = '' OR UnidadeID IS NULL or UnidadeID LIKE '%|"&UnidadeID&"|%')"
end if

set ImpressosModeloSQL = db.execute(sqlImpresso)

if not ImpressosModeloSQL.eof then
    TextoImpresso  = replaceTags(ImpressosModeloSQL("Cabecalho"), PacienteID, session("User"), UnidadeID)

    set prof = db.execute("SELECT NomeProfissional FROM profissionais WHERE id="&treatvalzero(req("ProfissionalID")))
    if not prof.eof then
        NomeProfissional = prof("NomeProfissional")
        TextoImpresso = replace(TextoImpresso, "[Profissional.Nome]", NomeProfissional)
    else
        TextoImpresso = replace(TextoImpresso, "[Profissional.Nome]", "")
    end if


    set proc = db.execute("SELECT NomeProcedimento, TextoPreparo FROM procedimentos WHERE id="&ProcedimentoID)
    if not proc.eof then
        NomeProcedimento = proc("NomeProcedimento")
        TextoPreparo = proc("TextoPreparo")&""

        TextoImpresso = replace(TextoImpresso, "[Procedimento.Nome]", NomeProcedimento&"")
        TextoImpresso = replace(TextoImpresso, "[Procedimento.Preparo]", TextoPreparo&"")
    end if
    

%>
<body>

    <div class="modal-body" id="areaImpressao" >
        <%=TextoImpresso%>
    </div>

</body>


<script type="text/javascript">
print();
</script>
<%
end if
%>