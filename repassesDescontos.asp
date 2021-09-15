<!--#include file="connect.asp"-->
<!--#include file="Classes/StringFormat.asp"-->
<%
if req("X")<>"" then
    db_execute("delete from repassesdescontos where id="&req("X"))
end if

set desc = db.execute("select * from repassesdescontos")
if desc.eof then
    %>
    Nenhum desconto adicional cadastrado.
    <%
else
    %>
    <table class="table table-condensed">
        <thead>
            <tr>
                <th colspan="2">Forma</th>
                <th>Desconto</th>
                <th>Parcelas entre</th>
                <th width="10"></th>
                <th width="10"></th>
            </tr>
        </thead>
        <tbody>
            <%
            set dr = db.execute("select dr.*, m.PaymentMethod from repassesdescontos dr left join sys_financialpaymentmethod m on m.id=dr.MetodoID")
            while not dr.eof
                if not isnull(dr("Contas")) and instr(dr("Contas"), "|") then
                    Contas = replace(dr("Contas"), "|", "")

                    Contas =  fix_array_comma(Contas)

                    set pcontas = db.execute("select group_concat(AccountName) gContas from sys_financialcurrentaccounts where id in("&Contas&")")
                    Contas = pcontas("gContas")
                else
                    Contas = ""
                end if
                if dr("tipoValor")="P" then
                    suf = "%"
                    pref = ""
                else
                    suf = ""
                    pref = "R$ "
                end if
                %>
                <tr>
                    <td><%=dr("PaymentMethod") %></td>
                    <td><%=Contas %></td>
                    <td><%=pref & fn(dr("Desconto")) & suf %></td>
                    <td><%
                            if dr("MetodoID") <> "1" then
                               response.write( dr("De") &" e "& dr("Ate") ) 
                            end if
                        %>
                    </td>
                    <td><button type="button" onclick="repasseDesconto(<%=dr("id") %>)" class="btn btn-xs btn-success"><i class="far fa-edit"></i></button></td>
                    <td><button type="button" onclick="if(confirm('Tem certeza de que deseja apagar este desconto de repasse?'))ajxContent('repassesDescontos&X=<%=dr("id") %>', '', 1, 'repassesDescontos')" class="btn btn-xs btn-danger"><i class="far fa-remove"></i></button></td>
                </tr>
                <%
            dr.movenext
            wend
            dr.close
            set dr=nothing
            %>
        </tbody>
    </table>
    <%
end if
%>