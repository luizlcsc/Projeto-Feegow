<!--#include file="connect.asp"-->

<%
id_profissional = request.form("id_profissional")

sqlEmpresa = " SELECT DISTINCT fcu.NomeFantasia, fcu.id id_unidade "&_
             " FROM procedimento_profissional_unidade ppu "&_
             " JOIN sys_financialcompanyunits fcu ON fcu.id = ppu.id_unidade "&_
             " WHERE id_profissional = "&id_profissional&_
             " ORDER BY 1, 2"

set resEmpresa = db.execute(sqlEmpresa)

%>
<div class="col-md-12">
<%
while not resEmpresa.eof

%>
    <table class="table table-bordered">
        <thead>
            <tr class="primary">
                <th>
                    <%=resEmpresa("NomeFantasia")%>
                </th>
                <th>
                    Grupo
                </th>
                <th>

                </th>
            </tr>
        </thead>
        <tbody>
<%

    sqlProcedimento = " SELECT DISTINCT p.nomeprocedimento, p.id id_procedimento, pg.nomegrupo "&_
      " FROM procedimento_profissional_unidade ppu "&_
      " JOIN procedimentos p ON p.id= ppu.id_procedimento "&_
      " JOIN procedimentosgrupos pg ON pg.id = p.GrupoID"&_
      " WHERE id_profissional = "&id_profissional&_
      " AND id_unidade = "&resEmpresa("id_unidade")&_
      " ORDER BY 1, 2"

    set resProcedimento = db.execute(sqlProcedimento)

    while not resProcedimento.eof 

%>
        <tr>
            <td width="75%">
                <%=resProcedimento("nomeprocedimento")%>
            </td>
            <td width="20%">
                <%=resProcedimento("nomegrupo")%>
            </td>
            <td style="text-align:center">
                <button type="button" class="btn btn-xs btn-danger dark" onclick="persistProcedimento('D',<%=resEmpresa("id_unidade")%>,<%=resProcedimento("id_procedimento")%>)">
                    <i class="fa fa-trash"></i>
                </button>
            </td>
        </tr>
<%

        resProcedimento.movenext
    wend

    resProcedimento.close
    set resProcedimento = nothing
%>
        </tbody>
    </table>
    <br>
<%
    resEmpresa.movenext
wend

resEmpresa.close
set resEmpresa = nothing
%>
</div>

