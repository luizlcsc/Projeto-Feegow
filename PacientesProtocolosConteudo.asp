<!--#include file="connect.asp"-->
<%
Tipo = req("Tipo")
if Tipo = "I" then
    ID = req("ID")
    PacienteID = req("PacienteID")
    ProtocoloID = req("ProtocoloID")
    if ID&""<>"" then
        set getPacientesProtocolos = db.execute("SELECT * FROM pacientesprotocolos WHERE id="&ID)
        if getPacientesProtocolos.eof then
            db.execute("INSERT INTO pacientesprotocolos (id, sysUser, sysActive, PacienteID) VALUES ("&ID&", "&session("User")&", 1, "&PacienteID&")")
        end if
        set getMedicamentosProtocolos = db.execute("SELECT * FROM protocolosmedicamentos WHERE ProtocoloID="&ProtocoloID)
        while not getMedicamentosProtocolos.eof
            db.execute("INSERT INTO pacientesprotocolosmedicamentos (PacienteProtocoloID, ProtocoloID, ProtocoloMedicamentoID) VALUES ("&ID&", "&ProtocoloID&", "&getMedicamentosProtocolos("id")&") ")
        getMedicamentosProtocolos.movenext
        wend
        getMedicamentosProtocolos.close
        set getMedicamentosProtocolos=nothing
    end if
end if


'if ref("X")<>"" then
    'db_execute("delete from pedidossadtprocedimentos where id="& ref("X"))
'end if
%>

<div class="row">
    <hr class="short alt">
    <div class="col-md-12 protocolo-content" id="ProtocoloLista" ><br>
        <input type="hidden" name="ProtocoloListaID" id="ProtocoloListaID" value="100">
        <table class="table" width="100%" style="padding: 4px;!important;">
            <%
            sql = "SELECT promed.*, promed.id ProtocoloMedicamentoID, prot.NomeProtocolo, prodMed.NomeProduto Medicamento, proDil.NomeProduto Diluente, unMed.Sigla SiglaMed, unDil.Sigla SiglaDil, protmed.Dose, protmed.QtdDiluente, protmed.Obs ObservacaoMedicamento "&_
                  "FROM pacientesprotocolosmedicamentos promed "&_
                  "LEFT JOIN pacientesprotocolos pacpro ON promed.PacienteProtocoloID=pacpro.id "&_
                  "LEFT JOIN protocolos prot ON prot.id=promed.ProtocoloID "&_
                  "LEFT JOIN protocolosmedicamentos protmed ON protmed.id = promed.ProtocoloMedicamentoID  AND protmed.ProtocoloID = promed.ProtocoloID  "&_
                  "LEFT JOIN produtos prodMed ON prodMed.id=protmed.Medicamento "&_
                  "LEFT JOIN cliniccentral.unidademedida unMed ON prodMed.UnidadePrescricao=unMed.id "&_
                  "LEFT JOIN produtos proDil ON proDil.id=protmed.DiluenteID "&_
                  "LEFT JOIN cliniccentral.unidademedida unDil ON proDil.UnidadePrescricao=unDil.id "&_
                  "WHERE pacpro.id="&ID&" ORDER BY promed.id"
            set getProtocolo = db.execute(sql)
            while not getProtocolo.eof
                ProtocoloID = getProtocolo("ProtocoloID")
                ProtocoloMedicamentoID = getProtocolo("ProtocoloMedicamentoID")
                DoseMedicamento = getProtocolo("DoseMedicamento")
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

                if DoseMedicamento&""="" then
                    DoseMedicamento = getProtocolo("Dose")
                end if
                DoseDiluente = getProtocolo("QtdDiluente")
                Medicamento = getProtocolo("Medicamento")
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
                    <td width="60%" colspan="2"><b>Medicamento:</b> <%=Medicamento%></td>
                    <td width="10%">
                        <div class="input-group">
                            <input id="DoseMedicamento_<%=ProtocoloMedicamentoID%>" class="form-control input-mask-brl text-right" placeholder="0,00" type="text" style="text-align:right" name="DoseMedicamento_<%=ProtocoloMedicamentoID%>" value="<%=fn(DoseMedicamento)%>">
                            <span class="input-group-addon">
                                <strong><%=SiglaMed%></strong>
                            </span>
                        </div>
                    </td>
                    <td width="1%"><i class='ml20 mt5 btn-xs btn btn-danger fa fa-remove' disabled="disabled"> </i></td>
                </tr>
                <%
                end if
                if Diluente&""<>"" then
                %>
                <tr>
                    <td class="text-right"><i class="fa fa-chevron-right"></i></td>
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
                    <td colspan="2"><textarea id="Obs_<%=ProtocoloMedicamentoID%>" name="Obs_<%=ProtocoloMedicamentoID%>" style='float:left;<%=styleText%>' class='obs-exame form-control' placeholder='Observações'><%=Obs %></textarea></td>
                    <td colspan="2"><%if ObservacaoMedicamento&""<>"" then%><b><i class="fa fa-exclamation-circle"></i> Obs.: </b><%end if%><%=ObservacaoMedicamento%></td>
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

</script>
