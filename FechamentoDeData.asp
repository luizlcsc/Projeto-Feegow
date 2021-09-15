<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<%

if req("T")="I" then
    db_execute("INSERT INTO fechamento_data (Data, sysActive, sysUser) VALUES ("&mydatenull(req("D"))&", 1, "&session("User")&")")
end if

if req("T")="X" then
    db_execute("UPDATE fechamento_data SET sysActive=-1 WHERE id="&req("I"))
end if

%>
<div class="row">
    <div class="col-md-12">
        <br>
        <div class="panel">
            <div class="panel-body">
                <%=quickfield("datepicker", "DataParaFechar", "Data", 4, date(), "", "", "")%>
                <div class="col-md-2">
                    <button onclick="insertFechamentoData()" class="btn btn-primary mt25">
                        <i class="far fa-search"></i> Visualizar data
                    </button>
                </div>

                <table class="table mt10">
                    <thead>
                        <tr>
                            <th>Data de referência</th>
                            <th>Data do fechamento</th>
                            <th>Usuário</th>
                            <th>#</th>
                        </tr>
                    </thead>
                    <tbody>
                    <%
                    set FechamentoDataSQL = db.execute("SELECT * FROM fechamento_data WHERE sysActive=1 ORDER BY Data ASC")

                    i=0
                    while not FechamentoDataSQL.eof
                        %>
                        <tr>
                            <td>
                                <%=FechamentoDataSQL("Data")%>
                            </td>
                            <td>
                                <%=FechamentoDataSQL("sysDate")%>
                            </td>
                            <td>
                                <%=nameInTable(FechamentoDataSQL("sysUser"))%>
                            </td>
                            <td>
                                <button <% if i>0 then %>disabled <% else %> onclick="deletaFechamentoData('<%= FechamentoDataSQL("id")%>')" <% end if %> class="btn btn-danger btn-xs" type="button"><i class="far fa-trash"></i></button>
                            </td>
                        </tr>
                        <%
                        i=i+1
                    FechamentoDataSQL.movenext
                    wend
                    FechamentoDataSQL.close
                    set FechamentoDataSQL=nothing
                    %>
                    </tbody>
                </table>

            </div>
        </div>
    </div>
</div>
<script type="text/javascript">
    $(".crumb-active a").html("Fechamento de Data");
    $(".crumb-icon a span").attr("class", "far fa-calendar");

    function deletaFechamentoData(id) {
        if(confirm("Tem certeza que deseja excluir este registro?")){
            location.href = "?P=FechamentoDeData&Pers=1&T=X&I="+id
        }
    }
    function insertFechamentoData() {
        var Data = $("#DataParaFechar").val();

        location.href = "?P=FechamentoDeData&Pers=1&T=I&D="+Data
    }
</script>