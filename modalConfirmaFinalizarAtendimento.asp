<!--#include file="connect.asp"-->
<%
    AtendimentoID = req("AtendimentoID")
    PacienteID = ccur(req("PacienteID"))
    Origem  = req("Origem")
    Solicitacao = req("Solicitacao")
    AgendamentoID  = req("AgendamentoID")

%> 
<style>
.ace {
    display: none;
}
.ace {
    position: absolute;
    overflow: hidden;
    clip: rect(0 0 0 0);
    height: 1px;
    width: 1px;
    margin: -1px;
    padding: 0;
    border: 0;
}
.eh-label {
    -webkit-touch-callout: none;
    -webkit-user-select: none;
    -khtml-user-select: none;
    -moz-user-select: none;
    -ms-user-select: none;
    user-select: none;
}
.eh-label:after {
    content:'';
    position: absolute;
    left: 10px;
    border: 1px solid #000;
    height: 12px;
    width: 12px;
}
.ace + .eh-label {
    padding-left: 26px;
    height: 19px;
    display: inline-block;
    line-height: 19px;
    background-repeat: no-repeat;
    background-position: 0 0;
    font-size: 20px;
    vertical-align: middle;
    cursor: pointer;
}
.ace:checked + .eh-label:before {
    content:'\2713';
    position: absolute;
    left: 12px;
    font-size: 24px;
    color: #008000;
    top: 4px;
}

.duplo>tbody>tr:nth-child(4n+1)>td,
.duplo>tbody>tr:nth-child(4n+2)>td
{    background-color: #f9f9f9;
}
.duplo>tbody>tr:nth-child(4n+3)>td,
.duplo>tbody>tr:nth-child(4n+4)>td
{    background-color: #ffffff;
}
</style>

<!-- <div  id="exampleModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" > -->
 <!--  <div class="modal-dialog" role="document"> -->
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="exampleModalLabel">Finalizar Atendimento</h5>
        
      </div>
      <div class="modal-body">
        Deseja realmente encerrar o atendimento sem registrar nenhuma evolução?
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-dismiss="modal">Não</button>
        <button type="button" class="btn btn-primary" onclick="finalizaratendimento()" >Sim</button>
      </div>
    </div>
 <!-- </div> -->    
<!-- </div> -->
<script>
    function finalizaratendimento(){
        $.ajax({
            type:"POST",
            url:"modalInfAtendimento.asp?AgendamentoID=<%=AgendamentoID%>&AtendimentoID=<%=AtendimentoID%>&Origem=Atendimento&PacienteID=<%=PacienteID%>&Solicitacao=<%=Solicitacao%>",
            success: function(data){
                $("#modal").html(data);
                setTimeout(function() {
                    $("#modal-table").modal("show");
                }, 400);
            }
        });                
    }
</script>
