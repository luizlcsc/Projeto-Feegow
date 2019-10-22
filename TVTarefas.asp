<meta http-equiv="refresh" content="60" /> 

<%

conexao = "Driver={MySQL ODBC 5.3 ANSI Driver};Server=localhost;Database=clinic105;uid=root;pwd=pipoca453;"
Set db = Server.CreateObject("ADODB.Connection")
db.Open conexao

CentroCustoID = request.querystring("CC")

set cc = db.execute("select NomeCentroCusto from centrocusto where id="& CentroCustoID)
NomeCentroCusto = cc("NomeCentroCusto")



function accountName(AccountAssociationID, AccountID)
    if instr(AccountID, "_")>0 then
        splCreditado = split(AccountID, "_")
        AccountAssociationID = splCreditado(0)
        AccountID = splCreditado(1)
    end if
    if not isnull(AccountAssociationID) and not isnull(AccountAssociationID) then
	    set getAssociation = db.execute("select * from cliniccentral.sys_financialaccountsassociation where id="&AccountAssociationID)
	    if not getAssociation.eof then
		    set getAccount = db.execute("select `"&getAssociation("column")&"` from `"&getAssociation("table")&"` where id="&AccountID)
		    if not getAccount.EOF then
			    accountName = getAccount(""&getAssociation("column")&"")
		    end if
	    end if
    else
        if AccountID&""="0" then
            AccountName = "Posi��o"
        end if
    end if
end function

%>

<h1 style="text-align:center"><%= NomeCentroCusto %></h1>


<table border="1" width="100%">
    <thead>
        <tr>
            <th>Solicita��o</th>
            <th>Criador</th>
            <th>Prazo</th>
        </tr>
    </thead>
    <tbody>
        <%
        set tar = db.execute("select t.*, lu.Nome from tarefas t LEFT JOIN cliniccentral.licencasusuarios lu ON lu.id=t.De where t.Para like '%|-"& CentroCustoID &"|%' order by t.Urgencia desc")
        while not tar.eof



            %>
            <tr>
                <td><%= tar("Titulo") %>
                    <br />
                    <%
                    Solicitantes = tar("Solicitantes")
                    if not isnull(Solicitantes) then
                        splitSolicitantes = split(Solicitantes, ",")
                        for i=0 to ubound(splitSolicitantes)
                            ItemArray = splitSolicitantes(i)
                            response.write( accountName(NULL, ItemArray))
                        next
                    end if
                    %>
                </td>
                <td><%= tar("Nome") %></td>
                <td><%= tar("DtPrazo") %></td>
            </tr>
            <%
        tar.movenext
        wend
        tar.close
        set tar = nothing
        %>
    </tbody>
</table>