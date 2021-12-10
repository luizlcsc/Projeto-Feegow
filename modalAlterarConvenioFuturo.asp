<!--#include file="connect.asp"-->
<% 

pacienteID = reqf("PacienteID") 
convenioID = reqf("convenioID") 

agendamentosFuturosSQL = "SELECT a.id, p.NomeProcedimento, prof.NomeProfissional, a.Data, a.ValorPlano AS convenioID, a.rdValorPlano, c.NomeConvenio FROM agendamentos a LEFT JOIN profissionais prof ON prof.id=a.ProfissionalID LEFT JOIN procedimentos p ON a.TipoCompromissoID=p.id LEFT JOIN convenios c ON c.id=a.ValorPlano WHERE DATE(a.`Data`) >= CURDATE() AND a.PacienteID="&pacienteID&" ORDER BY a.Data ASC, a.Hora ASC"

set agendamentosFuturos = db.execute(agendamentosFuturosSQL)
%>

<style>
    .margin-left{
        display: flex; 
        margin-left: 3.2rem;
    }
</style>

<div class="container" id="modalAlterarConvenioFuturo" style="width:100%; border:1px solid #f0f0f0;padding:15px">
    <div class="modal-header">
        <h3 class="modal-title">
            <strong>Foram encontrados agendamentos que serão afetados pela sua mudança</strong>
            <p>Deseja continuar?</p>
        </h3>
        <p>Marque quais agendamentos deseja que seja feito a atualização e clique em Salvar</p>
    </div>
    <div class="modal-body">

        <input type="hidden" name="convenioID" value="<%=convenioID%>"/>
        <input type="hidden" name="pacienteID" value="<%=pacienteID%>"/>

        <table class="table table-condensed">
            <thead>
                <tr class="primary">
                    <th scope="col">
                        <input id="marcarTodos" class="form-check-input" type="checkbox" onchange="marcarTodosAgendamentos(this.checked)">
                    </th>
                    <th scope="col">PROCEDIMENTO</th>
                    <th scope="col">PROFISSIONAL</th>
                    <th scope="col">DATA</th>
                    <th scope="col">FORMA DE PAGAMENTO</th>
                </tr>
            </thead>
            <tbody>
                <%
                i = 1
                while not agendamentosFuturos.EOF
                    
                    NomeProcedimento = agendamentosFuturos("NomeProcedimento")
                    NomeProfissional = agendamentosFuturos("NomeProfissional")
                    Convenio = agendamentosFuturos("convenioID")
                    AgendamentoID = agendamentosFuturos("id")

                    if agendamentosFuturos("rdValorPlano")="V" then
                        formaPagamento = "Dinheiro"
                    else
                        formaPagamento = "Convenio / "+agendamentosFuturos("NomeConvenio")
                    end if

                    data = agendamentosFuturos("Data")
                    if not isnull(data) then
                        data = formatdatetime(data)
                    end if
                %>
                    <tr>
                        <td><input id="AgendamentoID-<%=i%>" value="<%=AgendamentoID%>" class="form-check-input" type="checkbox" name="agendamentoID"></td>
                        <td><%=NomeProcedimento%></td>
                        <td><%=NomeProfissional%></td>
                        <td><%=data%></td>
                        <td class="margin-left"><%=formaPagamento%></td>
                    </tr>
                <%
                i = i+1
                agendamentosFuturos.MoveNext
                wend
                agendamentosFuturos.close
                set agendamentosFuturos = nothing
                %>
            </tbody>
        </table>
    </div>
    <div class="">
        <button id="btnSalvar" type="button" onclick="updateConveniosFuturos(this)" class="btn btn-primary" disabled>Salvar</button>
        <button id="btnCancelar" type="button" class="btn btn-danger">Cancelar</button>
    </div>
</div>

<script>
    
    $('#btnCancelar').on('click', function() {
        $("#modal-table").modal("hide");
    });

    $("[name=agendamentoID], #marcarTodos").on("change", function() {
        
        $("#btnSalvar").attr("disabled", false);
    });

    function updateConveniosFuturos(ev) {

        if ($("[name=agendamentoID]").is(':checked')) {
            $("#btnSalvar").attr("disabled", true);
            
            $.post("updateConveniosFuturos.asp", 
            $("input[name=agendamentoID], input[name=convenioID], input[name=pacienteID]").serialize(), 
            function (data) {
                $("#updateConvenio").html(data);
                showMessageDialog("Agendamentos atualizados", "success");
                $("#modal-table").modal("hide");
                $("#btnSalvar").attr("disabled", false);
            });
        }else {
            $("#btnSalvar").attr("disabled", true);
            showMessageDialog("Selecione os agendamentos que serão atualizados", "warning");
            ev.preventDefault();
        }
    }

    function marcarTodosAgendamentos(value){
        $("[name=agendamentoID]").prop("checked",value)
    }

</script>