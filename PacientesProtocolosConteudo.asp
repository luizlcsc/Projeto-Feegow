<!--#include file="connect.asp"-->
<!--#include file="geraPacientesProtocolosCiclos.asp"-->
<%
if ID&"" = "" then
    ID = req("i")
end if

tipoprescricao = req("tipoprescricao")
profissional = req("profissional")
assoc = req("assoc")

Tipo = req("Tipo")
readOnly = false
if req("readonly") = "1" then
    readOnly = true
end if

set usuario = db.execute("SELECT Auditor FROM profissionais where id = "&session("User")&" and sysActive= 1")
if not usuario.eof then
    auditor = usuario("Auditor")
end if 

inserted = false
if Tipo = "I" then
    ID = req("ID")
    PacienteID = req("PacienteID")
    ProtocoloID = req("ProtocoloID")
    if ID&""<>"" then
        set getPacientesProtocolos = db.execute("SELECT * FROM pacientesprotocolos WHERE id="&ID)
        if getPacientesProtocolos.eof then
            if tipoprescricao&"" <> "" then
                sqlInsertProtocolo ="INSERT INTO pacientesprotocolos (id,PacienteID,ProfissionalID, UnidadeID, sysUser, sysActive,tipoprescricao, AccountAssociationID) VALUES ("&ID&","&PacienteID&","&profissional&",  "&session("UnidadeID")&", "&session("User")&", 1,'"&tipoprescricao&"',"&assoc&")"
            else
                sqlInsertProtocolo ="INSERT INTO pacientesprotocolos (id,PacienteID,ProfissionalID, UnidadeID, sysUser, sysActive ) VALUES ("&ID&","&PacienteID&","&profissional&",  "&session("UnidadeID")&", "&session("User")&", 1)"
            end if 
            db.execute(sqlInsertProtocolo)
        end if
        set getMedicamentosProtocolos = db.execute("SELECT * FROM protocolosmedicamentos WHERE ProtocoloID="&ProtocoloID)
        while not getMedicamentosProtocolos.eof
            db.execute("INSERT INTO pacientesprotocolosmedicamentos (PacienteProtocoloID, ProtocoloID, ProtocoloMedicamentoID) VALUES ("&ID&", "&ProtocoloID&", "&getMedicamentosProtocolos("id")&") ")
        getMedicamentosProtocolos.movenext
        wend
        getMedicamentosProtocolos.close
        set getMedicamentosProtocolos=nothing

        call geraPacientesProtocolosCiclos(ID)
        inserted = true
    end if
end if


'if ref("X")<>"" then
    'db_execute("delete from pedidossadtprocedimentos where id="& ref("X"))
'end if
%>

<style type="text/css">
    #table-protocolo .form-control[readonly] {
        cursor: default;
    }
</style>

<div class="row">
    <% if not readOnly then %>
    <hr class="short alt">
    <%end if %>
    <div class="col-md-12 protocolo-content" id="ProtocoloLista" ><br>
        <input type="hidden" name="ProtocoloListaID" id="ProtocoloListaID" value="100">
        <table id="table-protocolo" class="table" width="100%" style="padding: 4px;!important;">
            <%
            sql = "SELECT promed.*, promed.id ProtocoloMedicamentoID, promed.MedicamentoPrescritoID MedicamentoPrescritoID, prodMedPres.NomeProduto NomeMedicamentoPrescrito, protmed.Medicamento MedicamentoID, prot.NomeProtocolo, prodMed.NomeProduto NomeMedicamento, proDil.NomeProduto Diluente, unMed.Sigla SiglaMed, unDil.Sigla SiglaDil, protmed.Dose, protmed.QtdDiluente, protmed.Obs ObservacaoMedicamento, pac.ConvenioID1 ConvenioID, pac.PlanoID1 PlanoID "&_
                  "FROM pacientesprotocolosmedicamentos promed "&_
                  "LEFT JOIN pacientesprotocolos pacpro ON promed.PacienteProtocoloID=pacpro.id "&_
                  "LEFT JOIN protocolos prot ON prot.id=promed.ProtocoloID "&_
                  "LEFT JOIN protocolosmedicamentos protmed ON protmed.id = promed.ProtocoloMedicamentoID  AND protmed.ProtocoloID = promed.ProtocoloID  "&_
                  "LEFT JOIN produtos prodMed ON prodMed.id = protmed.Medicamento "&_
                  "LEFT JOIN produtos prodMedPres ON prodMedPres.id = promed.MedicamentoPrescritoID "&_
                  "LEFT JOIN pacientes pac ON pac.id=pacpro.PacienteID "&_
                  "LEFT JOIN cliniccentral.unidademedida unMed ON prodMed.UnidadePrescricao=unMed.id "&_
                  "LEFT JOIN produtos proDil ON proDil.id=protmed.DiluenteID "&_
                  "LEFT JOIN cliniccentral.unidademedida unDil ON proDil.UnidadePrescricao=unDil.id "&_
                  "WHERE pacpro.id="&ID&" and promed.sysActive =1 ORDER BY promed.id"

            set getProtocolo = db.execute(sql)
            while not getProtocolo.eof
                ProtocoloID = getProtocolo("ProtocoloID")
                DoseMedicamento = getProtocolo("DoseMedicamento")
                MedicamentoID = getProtocolo("MedicamentoPrescritoID")
                Obs = getProtocolo("Obs")
                ConvenioID = getProtocolo("ConvenioID")
                PlanoID = getProtocolo("PlanoID")
                Obs = getProtocolo("Obs")
                ProtocoloMedicamentoID = getProtocolo("ProtocoloMedicamentoID")
                if NomeProtocolo&"" <> getProtocolo("NomeProtocolo") then
                    NomeProtocolo = getProtocolo("NomeProtocolo")
                %>
                <tr style="background-color: #ededed;">
                    <th colspan="4" class="text-center"><h4><%=getProtocolo("NomeProtocolo")%> </h4></th>
                </tr>
                <%
                end if

                Medicamento = getProtocolo("NomeMedicamentoPrescrito")
                MedicamentoID = getProtocolo("MedicamentoPrescritoID")

                if MedicamentoID&""="" then

                    Medicamento = getProtocolo("NomeMedicamento")
                    MedicamentoID = getProtocolo("MedicamentoID")

                    if isnumeric(ConvenioID) then
                        sqlRegraConv = " AND (medconv.convenioID LIKE '%|"&ConvenioID&"|%' OR medconv.convenioID IS NULL OR medconv.convenioID='')"
                    end if
                    if isnumeric(PlanoID) then
                        sqlRegraPlan = " AND (medconv.planoID LIKE '%|"&PlanoID&"|%' OR medconv.planoID IS NULL OR medconv.planoID='')"
                    end if

                    if sqlRegraConv <> "" or sqlRegraPlan <> "" then
                        set getRegraMedicamento = db.execute("SELECT prod.id MedicamentoID, prod.NomeProduto "&_
                                                            "FROM medicamentos_convenio medconv "&_
                                                            "LEFT JOIN produtos prod ON prod.id=medconv.produtoReferencia "&_
                                                            "WHERE medconv.produtoReferencia!=0 AND medconv.sysActive=1 "&sqlRegraConv & sqlRegraPlan&" LIMIT 1")

                        if not getRegraMedicamento.eof then
                            Medicamento = getRegraMedicamento("NomeProduto")
                            MedicamentoID = getRegraMedicamento("MedicamentoID")
                        end if
                    end if

                end if

                if DoseMedicamento&""="" then
                    DoseMedicamento = getProtocolo("Dose")
                end if
                DoseDiluente = getProtocolo("QtdDiluente")
                Diluente = getProtocolo("Diluente")
                SiglaMed = getProtocolo("SiglaMed")
                SiglaDil = getProtocolo("SiglaDil")
                ObservacaoMedicamento = getProtocolo("ObservacaoMedicamento")
                %>
                <tr>
                    <td colspan="4"></td>
                </tr>
                <%
                if Medicamento&""<>"" then
                %>
                <tr style="background-color: #f9f9f9;" class="mt10">
                    <td width="60%" colspan="2">
                        <input id="MedicamentoID_<%=ProtocoloMedicamentoID%>" hidden name="MedicamentoID_<%=ProtocoloMedicamentoID%>" value="<%=MedicamentoID%>">
                        <b>Medicamento:</b> <%=Medicamento%>
                    </td>
                    <td width="10%">
                        <div class="input-group">
                            <input id="DoseMedicamento_<%=ProtocoloMedicamentoID%>" class="form-control input-mask-brl text-right" placeholder="0,00" type="text" style="text-align:right" name="DoseMedicamento_<%=ProtocoloMedicamentoID%>" value="<%=fn(DoseMedicamento)%>" <% if readOnly then%> readonly <%end if%>>
                            <span class="input-group-addon">
                                <strong><%=SiglaMed%></strong>
                            </span>
                        </div>
                    </td>
                    <td class='row' width="9%">
                        <% if not readonly then %>
                        <i class='ml5 col-md-5 btn-xs btn btn-warning far fa-pencil' onclick="pedirMudanca('E','<%=ProtocoloMedicamentoID%>','<%=MedicamentoID%>')"  data-toggle="tooltip" data-placement="top" title="Pedir edição de protocolo"> </i>
                        <i class='ml5 col-md-5 btn-xs btn btn-danger far fa-remove' onclick="pedirMudanca('R','<%=ProtocoloMedicamentoID%>','<%=MedicamentoID%>')" data-toggle="tooltip" data-placement="top" title="Pedir remoção de protocolo"> </i>
                        <% end if %>
                    </td>
                </tr>
                <%
                end if
                if Diluente&""<>"" then
                %>
                <tr>
                    <td class="text-right"><i class="far fa-chevron-right"></i></td>
                    <td ><b>Diluente:</b> <%=Diluente%>
                    <b>
                        <%if DoseDiluente&""<>"" then%>
                        <%=DoseDiluente&" "&SiglaDil%>
                        <%end if%>
                    </b>
                    </td>
                    <td></td>
                    <td></td>
                </tr>
                <%
                end if
                if Medicamento&""<>"" then
                %>
                <tr>
                    <td colspan="2"><textarea id="Obs_<%=ProtocoloMedicamentoID%>" name="Obs_<%=ProtocoloMedicamentoID%>" style='float:left;<%=styleText%>' class='obs-exame form-control' placeholder='Observações'  <% if readOnly then%> readonly <%end if%>><%=Obs %></textarea></td>
                    <td colspan="2"><%if ObservacaoMedicamento&""<>"" then%><b><i class="far fa-exclamation-circle"></i> Obs.: </b><%end if%><%=ObservacaoMedicamento%></td>
                </tr>
                <%
                end if

            getProtocolo.movenext
            wend
            getProtocolo.close
            set getProtocolo=nothing
            %>
        </table>
    </div>
</div>
<script>
$(function () {
  $('[data-toggle="tooltip"]').tooltip()
})



function pedirMudanca(tipo,id,medicamentoId){
    const dose = parseFloat(($(`#DoseMedicamento_${id}`).val()).replace(',','.'));
    const obs = $(`#Obs_${id}`).val();
    const paciente = "<%=req("PacienteID")%>";
    const auditor = "<%=auditor%>";
    const pacienteProtocoloId = "<%=ID%>";
    const data = {
        id,
        dose,
        obs,
        medicamentoId,
        paciente,
        tipo,
        pacienteProtocoloId
    }

    // valida os campos
    if(dose.length==0 || obs.length ==0){
        msg('Os campos de dose e observação devem estar preenchidos','warning')
        return false
    }

    if (auditor==1){
        $.ajax({
        type: "POST",
        url: "PacientesProtocolosConteudoSave.asp",
        data: data,
        contentType:"application/x-www-form-urlencoded"
        })
        .done((data)=>{
            msg('Atualização feita com sucesso', "success")
            $('.mfp-close').click()
        })
    }else{
        $.ajax({
        type: "POST",
        url: "notificacao_mudancaProtocolo.asp",
        data: data,
        contentType:"application/x-www-form-urlencoded"
        })
        .done((data)=>{
            msg('Sua solicitação foi enviada ao Auditor', "success")
        })
    }

}

function msg(titulo,tipo){
    new PNotify({
        title: titulo,
        type: tipo,
        delay: 3000
    });
}

<% if inserted then %>
pront('timeline.asp?PacienteID=<%=req("PacienteID")%>&Tipo=|Protocolos|');
<% end if %>

</script>
