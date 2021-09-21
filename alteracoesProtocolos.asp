<!--#include file="connect.asp"-->
<%

    notificacao=req("paciente")
    sqlAlteracoes =     " select                                                                                          "&chr(13)&_
                        " 	pma.id as id,                                                                                 "&chr(13)&_
                        " 	p3.id as pacienteId,                                                                          "&chr(13)&_
                        " 	p3.NomePaciente as nomePaciente,                                                              "&chr(13)&_
                        " 	pma.MedicamentoPrescritoID as medicamentoId,                                                  "&chr(13)&_
                        " 	p2.NomeProduto as medicamentoNome,                                                            "&chr(13)&_
                        " 	ppm.ProtocoloID as protocoloId,                                                               "&chr(13)&_
                        " 	p.NomeProtocolo as NomeProtocolo,                                                             "&chr(13)&_
                        " 	ppm.id as ppmId,                                                                              "&chr(13)&_
                        " 	pm.Dose as doseOriginal,                                                                      "&chr(13)&_
                        " 	pma.DoseMedicamento as doseAlterada,                                                          "&chr(13)&_
                        " 	pma.tipo as acao,                                                                             "&chr(13)&_
                        " 	pma.Obs as obs,                                                                               "&chr(13)&_
                        " 	pma.ProfissionalID as profissionalId,                                                         "&chr(13)&_
                        " 	sp_sysUserName(pma.ProfissionalID) as Nomeprofissional,                                       "&chr(13)&_
                        " 	unmed.Sigla as unidade                                                                        "&chr(13)&_
                        " from paciente_medicamentos_aprovacao pma                                                        "&chr(13)&_
                        " left join produtos p2 on p2.id = pma.MedicamentoPrescritoID                                     "&chr(13)&_
                        " left join pacientesprotocolosmedicamentos ppm on ppm.id = pma.pacientesProtocolosMedicamentosID "&chr(13)&_
                        " left join pacientesprotocolos pp on pp.id = ppm.PacienteProtocoloID                             "&chr(13)&_
                        " left join protocolosmedicamentos pm ON pm.id = ppm.ProtocoloMedicamentoID                       "&chr(13)&_
                        " left join pacientes p3 on p3.id = pp.PacienteID                                                 "&chr(13)&_
                        " left join protocolos p on p.id = ppm.ProtocoloID                                                "&chr(13)&_
                        " LEFT JOIN cliniccentral.unidademedida unMed ON unMed.id = p2.UnidadePrescricao                  "&chr(13)&_
                        " where pma.id = "&notificacao&"                                "

    set alteracoes = db.execute(sqlAlteracoes)


    if not alteracoes.eof then
        tipo = alteracoes("acao")
        if alteracoes("acao") = "E" then
            acao    = "Editar"
            cor     = "btn-warning"
        else
            acao    = "Remover"
            cor     = "btn-danger"
        end if
    end if
%>
<style>
    #acaoNotificacao .panel-title{
        display: flex;
        justify-content: space-between;
    }
    .fright{
        float:right
    }

</style>

<div class="panel mt20" id='acaoNotificacao'>
    <div class="panel-heading <%=cor%>">
        <div class="panel-title">
            <span>Pedido de alteração do protocolo <%=alteracoes("NomeProtocolo")%></span>
            <span> Ação: <%=acao%></span>
        </div>
    </div>
    <div class="panel-body">
        <div class="form-group col-md-12">
            <label for="nome">Nome paciente</label>
            <div class="form-control" style="background-color: #fafafa;">
                <a href="?P=Pacientes&I=<%=alteracoes("pacienteId")%>&Pers=1" target="_blank"><%=alteracoes("nomePaciente")%></a>
            </div>
        </div>
        <div class="form-group col-md-12">
            <label for="nome">Profissional solicitante</label>
            <input type="text" class="form-control" name="Nomeprofissional" id="Nomeprofissional" value='<%=alteracoes("Nomeprofissional")%>' disabled>
            <input type="hidden" class="form-control" name="profissionalId" id="profissionalId" value='<%=alteracoes("profissionalId")%>'>
        </div>
         <div class="form-group col-md-6">
            <label for="nome">Medicamento utilizado</label>
            <input type="text" class="form-control" name="medicamentoNome" id="medicamentoNome" value='<%=alteracoes("medicamentoNome")%>' disabled>
            <input type="hidden" class="form-control" name="medicamentoId" id="medicamentoId" value='<%=alteracoes("medicamentoId")%>'>
        </div>
        <div class="form-group col-md-3">
            <label for="nome">Dose Original</label>
            <div class="input-group">
                <input type="text" class="form-control" name="doseOriginal" id="doseOriginal" value='<%=alteracoes("doseOriginal")%>' disabled>
                <span class="input-group-addon"><%=alteracoes("unidade")%></span>
            </div>
        </div>
        <div class="form-group col-md-3">
            <label for="nome">Dose Alterada</label>
            <div class="input-group">
                <input type="text" class="form-control" name="doseAlterada" id="doseAlterada" value='<%=alteracoes("doseAlterada")%>' disabled>
                <span class="input-group-addon"><%=alteracoes("unidade")%></span>
            </div>
        </div>
        <div class="form-group col-md-12">
            <label for="nome">Obs</label>
            <textarea class="form-control" name="obs" id="obs" rows="5" disabled><%=alteracoes("obs")%></textarea>
        </div>
        <div class="form-group col-md-12">
            <label for="nome">Obs do Auditor</label>
            <textarea class="form-control" name="obsA" id="obsA" rows="5"></textarea>
        </div>
        <div class="form-group col-md-12">
            <div class='fright'>
                <button class='btn btn-danger' onclick='salvarNotificacao("<%=alteracoes("id")%>",0)' ><i class='far fa-times'  ></i> Reprovar</button>
                <button class='btn btn-success' onclick='salvarNotificacao("<%=alteracoes("id")%>",1)' ><i class='far fa-check'></i> Aprovar</button>
            </div>
        </div>
    </div>
</div>


<script type="text/javascript">
    $(".crumb-active a").html("Aprovações de alteração de protocolos");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("Aprovações de alteração de protocolos");
    $(".crumb-icon a span").attr("class", "far fa-table");

function salvarNotificacao(id,aprovacao){
    let tipo = '<%=tipo%>'; //E ou R
    let ppm = '<%=alteracoes("ppmId")%>';
    let paciente = '<%=alteracoes("pacienteId")%>'
    let obsA = $('#obsA').val()

    if(obsA.length == 0){
        new PNotify({
            title: "O campo de observação do auditor precisa ser preenchido",
            type: "danger",
            delay: 3000
        });
        return false
    }

    let data = {
        tipo,
        aprovacao,
        ppm,
        paciente,
        obsA,
        id
    }

    $.ajax({
    type: "POST",
    url: "resolveNotificacaoProtocolo.asp",
    data: data,
    contentType:"application/x-www-form-urlencoded"
    })
    .done((data)=>{
         if(data=="False"){
            new PNotify({
                title: "Algum Auditor já interagiu com este pedido",
                type: "info",
                delay: 3000
            });
        }else{
            // console.log(data)
            window.location.replace('./')
        }
    })
}

</script>