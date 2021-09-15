<!--#include file="connect.asp"-->
<%
CampoId = req("CampoId")
TipoCampoId = req("TipoCampoId")
FormId = req("FormId")
PacienteId = req("PacienteId")

set getDadosCampos = db.execute("SELECT * FROM buicamposforms WHERE id="&CampoId)
if not getDadosCampos.eof then
    NomeCampo = getDadosCampos("RotuloCampo")
    Estruturacao = getDadosCampos("Estruturacao")
end if



%>
<div class="panel">
    <div class="panel-heading">
        <span class="panel-title"><i class="far fa-history"></i> <b>Histórico do Campo</b></span>
        <span style="color: #cccccc;"> / </span>
        <span style="font-size: 12px;"><b> <%=NomeCampo%> </b></span>
    </div>

    <div class="panel-body">

        <div class="row" style="display:none">
            <div class="col-md-12">
                <button class="btn btn-block btn-info text-left" type="button" onclick="$('#HistoricoCampo').slideToggle()"><i class="far fa-chevron-right"></i> Histórico de Ações</button>
            </div>
        </div>
        <div class="row pt10" id="HistoricoCampo" style="display:">

            <div class="col-md-12">
                <table class="table table-striped table-bordered">
                    <thead>
                        <tr>
                            <th width="1"></th>
                            <th>Data</th>
                            <th>Usuário</th>
                            <th>Conteúdo</th>
                        </tr>
                    </thead>
                    <tbody>
                    <%

                    if FormId&""<>"" then
                        set getDadosForm = db.execute("SELECT form.* FROM _"&FormId&" form "&_
                                                       "LEFT JOIN buiformspreenchidos bfp ON bfp.id=form.id AND bfp.PacienteID=form.PacienteID "&_
                                                       "WHERE bfp.sysActive=1 AND form.PacienteID="&PacienteId&" ORDER BY form.id DESC")
                        if getDadosForm.eof then
                            TemHistorico = false
                        end if

                        while not getDadosForm.eof
                            TemHistorico = true
                            DataAtendimento = formatdatetime(getDadosForm("DataHora"), 2)&" "&formatdatetime(getDadosForm("DataHora"), 4)
                            Usuario = nameInTable(getDadosForm("sysUser"))
                            ConteudoAtendimento = getDadosForm(CampoId)
                            FormConteudoId = getDadosForm("id")

                           select case TipoCampoId


                               case 1, 4, 5, 8 'TEXTO CHECKBOX RADIO MEMORANDO

                                    if ConteudoAtendimento&""<>"" then

                                        if TipoCampoId=4 or TipoCampoId=5 then 'CHECKBOX & RADIO
                                            Opcoes = replace(ConteudoAtendimento, "|", "")
                                            set getChekForm = db.execute("SELECT GROUP_CONCAT(Nome SEPARATOR ', ')OpcoesSelecionadas FROM buiopcoescampos "&_
                                                                          "WHERE id IN("&Opcoes&") ")
                                            if not getChekForm.eof then
                                                ConteudoAtendimento = getChekForm("OpcoesSelecionadas")
                                            end if
                                        end if

                                        %>
                                        <tr>
                                            <td><button type="button" onClick="aplicarConteudoLog(<%=CampoId%>, <%=FormConteudoId%>, <%=TipoCampoId%>, '<%=Opcoes%>')" class="btn btn-xs btn-primary"><i class="far fa-angle-right"></i> Aplicar</button></td>
                                            <td nowrap><%=DataAtendimento%></td>
                                            <td nowrap><%=Usuario%></td>
                                            <td id="conteudo-<%=FormConteudoId%>"><%=ConteudoAtendimento%></td>
                                        </tr>
                                        <%
                                    end if

                               case 9'TABELA



                               case 19'PRESCRIÇÃO
                                    set getPrescricao = db.execute("SELECT pp.*, med.NomeMedicamento, meduni.Descricao NomeApresentacao, medfreq.Descricao NomeFrequencia, meddur.Descricao NomeDuracao, meduso.Uso NomeVia, per.Descricao TipoPeriodo FROM memed_prescricoes pp "&_
                                                               "LEFT JOIN cliniccentral.medicamentos2 med ON med.id=pp.MedicamentoID "&_
                                                               "LEFT JOIN cliniccentral.medicamentosunidades meduni ON meduni.id=pp.Apresentacao "&_
                                                               "LEFT JOIN cliniccentral.medicamentosfrequencia medfreq ON medfreq.id=pp.Frequencia "&_
                                                               "LEFT JOIN cliniccentral.medicamentosduracao meddur ON meddur.id=pp.Duracao "&_
                                                               "LEFT JOIN cliniccentral.usosmedicamentos meduso ON meduso.id=pp.Via "&_
                                                               "LEFT JOIN (select 'H' id, 'Horas' Descricao UNION select 'D', 'Dias' Descricao UNION select 'S', 'Semanas' Descricao UNION SELECT 'm', 'Mês' Descricao UNION select 'C', 'Uso contínuo' Descricao) per ON per.id=pp.TipoTempo "&_
                                                               "WHERE pp.sysActive=1 AND pp.PacienteID="&PacienteId&" AND pp.CampoID="&CampoId&" AND pp.FormID="&getDadosForm("id")&" ORDER BY pp.id DESC")
                                   while not getPrescricao.eof
                                       Medicamento = getPrescricao("NomeMedicamento")
                                       DataHora = getPrescricao("DataHora")

                                       Dose = getPrescricao("Dose")
                                       Apresentacao = getPrescricao("NomeApresentacao")
                                       Via = getPrescricao("NomeVia")
                                       Frequencia = getPrescricao("NomeFrequencia")
                                       Duracao = getPrescricao("NomeDuracao")
                                       Periodo = getPrescricao("TempoTratamento")
                                       TipoPeriodo = getPrescricao("TipoPeriodo")
                                       PosologiaMedicamento = getPrescricao("PosologiaMedicamento")

                                       ConteudoAtendimento = "<b>Medicamento: </b>" & Medicamento & "<br>"
                                       DataAtendimento = formatdatetime(DataHora, 2)&" "&formatdatetime(DataHora, 4)

                                       if Dose&""<>"" then
                                           ConteudoAtendimento = ConteudoAtendimento & "<br><b>Dose: </b>" & Dose
                                       end if
                                       if Apresentacao&""<>"" then
                                           ConteudoAtendimento = ConteudoAtendimento & "<br><b>Apresentação: </b>" & Apresentacao
                                       end if
                                       if Via&""<>"" then
                                           ConteudoAtendimento = ConteudoAtendimento & "<br><b>Via: </b>" & Via
                                       end if
                                       if Frequencia&""<>"" then
                                           ConteudoAtendimento = ConteudoAtendimento & "<br><b>Frequencia: </b>" & Frequencia
                                       end if
                                       if Duracao&""<>"" then
                                           ConteudoAtendimento = ConteudoAtendimento & "<br><b>Duração: </b>" & Duracao
                                       end if
                                       if Periodo&""<>"" or TipoPeriodo&""<>"" then
                                           ConteudoAtendimento = ConteudoAtendimento & "<br><b>Período: </b>" & Periodo & " " & TipoPeriodo
                                       end if
                                       if PosologiaMedicamento&""<>"" then
                                           ConteudoAtendimento = ConteudoAtendimento & "<br><b>Posologia: </b>" & PosologiaMedicamento
                                       end if


                                       %>
                                       <tr>
                                           <td></td>
                                           <td nowrap><%=DataAtendimento%></td>
                                           <td nowrap><%=Usuario%></td>
                                           <td><%=ConteudoAtendimento%></td>
                                       </tr>
                                       <%
                                   getPrescricao.movenext
                                   wend
                                   getPrescricao.close
                                   set getPrescricao = nothing



                               case 20'PEDIDOS

                                    set getPedido = db.execute("SELECT pp.Resultado, pp.DataHora, ps.Descricao StatusPedido, CONCAT(tc.Codigo, ' - ', tc.Descricao) DescricaoPedido FROM protocolospedidos pp "&_
                                                                "LEFT JOIN cliniccentral.tusscorrelacao tc ON tc.id=pp.PedidoID "&_
                                                                "LEFT JOIN cliniccentral.pedidosstatus ps ON ps.id=pp.StatusID "&_
                                                                "WHERE pp.sysActive=1 AND pp.PacienteID="&PacienteId&" AND pp.CampoID="&CampoId&" AND pp.FormID="&getDadosForm("id")&" ORDER BY pp.id DESC")
                                    while not getPedido.eof
                                        Resultado = getPedido("Resultado")
                                        StatusPedido = getPedido("StatusPedido")
                                        Procedimento = getPedido("DescricaoPedido")
                                        DataHora = getPedido("DataHora")

                                        ConteudoAtendimento = "<b>Procedimento: </b>" & Procedimento
                                        DataAtendimento = formatdatetime(DataHora, 2)&" "&formatdatetime(DataHora, 4)

                                        if StatusPedido&""<>"" then
                                            ConteudoAtendimento = ConteudoAtendimento & "<br><br><b>Status: </b>" & StatusPedido
                                        end if
                                        if Resultado&""<>"" then
                                            ConteudoAtendimento = ConteudoAtendimento & "<br><br><b>Resultado: </b>" & Resultado
                                        end if

                                        %>
                                        <tr>
                                            <td></td>
                                            <td nowrap><%=DataAtendimento%></td>
                                            <td nowrap><%=Usuario%></td>
                                            <td><%=ConteudoAtendimento%></td>
                                        </tr>
                                        <%
                                    getPedido.movenext
                                    wend
                                    getPedido.close
                                    set getPedido = nothing



                               case 21'ATESTADOS

                                    set getAtestado = db.execute("SELECT pa.*, pat.NomeAtestado FROM pacientesatestados pa "&_
                                                                 "LEFT JOIN pacientesatestadostextos pat ON pat.id=pa.AtestadoID "&_
                                                                 "WHERE pa.sysActive=1 AND pa.PacienteID="&PacienteID&" AND pa.CampoID="&CampoID&" AND pa.FormID="&getDadosForm("id")&" ORDER BY pa.id DESC")
                                    while not getAtestado.eof
                                        DataHora = getAtestado("Data")
                                        DataAtendimento = formatdatetime(DataHora, 2)&" "&formatdatetime(DataHora, 4)
                                        ConteudoAtendimento = getAtestado("NomeAtestado")
                                        %>
                                        <tr>
                                            <td></td>
                                            <td nowrap><%=DataAtendimento%></td>
                                            <td nowrap><%=Usuario%></td>
                                            <td><%=ConteudoAtendimento%></td>
                                        </tr>
                                        <%
                                    getAtestado.movenext
                                    wend
                                    getAtestado.close
                                    set getAtestado = nothing

                               case 23'ENCAMINHAMENTO

                                   set getEncaminhamento = db.execute("SELECT enc.*, COALESCE(esp.especialidade, esp.nomeEspecialidade) NomeEspecialidade FROM protocolosencaminhamentos enc "&_
                                                                       "LEFT JOIN cliniccentral.especialidades_correcao  esp ON esp.id=enc.EspecialidadeID "&_
                                                                       "WHERE enc.sysActive=1 AND enc.PacienteID="&PacienteId&" AND enc.CampoID="&CampoId&" AND enc.FormID="&getDadosForm("id")&" ORDER BY enc.id DESC")
                                   while not getEncaminhamento.eof
                                       Encaminhamento = getEncaminhamento("Tipo")
                                       DataHora = getEncaminhamento("DataHora")
                                       Motivo = getEncaminhamento("Motivo")
                                       Obs = getEncaminhamento("Obs")
                                       Especialidade = getEncaminhamento("NomeEspecialidade")
                                       LicencaID = getEncaminhamento("LicencaID")
                                       ProfissionalID = getEncaminhamento("ProfissionalID")
                                       Profissional = ""

                                       if LicencaID<>0 then
                                           set getProfissionalAtendimento = db.execute("SELECT NomeProfissional FROM clinic"&LicencaID&".profissionais WHERE id="&ProfissionalID)
                                           if not getProfissionalAtendimento.eof then
                                               Profissional = getProfissionalAtendimento("NomeProfissional")
                                           end if
                                       end if


                                       ConteudoAtendimento = "<b>Encaminhamento: </b>" & Encaminhamento & "<br>"
                                       DataAtendimento = formatdatetime(DataHora, 2)&" "&formatdatetime(DataHora, 4)

                                       if Especialidade&""<>"" then
                                           ConteudoAtendimento = ConteudoAtendimento & "<br><b>Especialidade: </b>" & Especialidade
                                       end if
                                       if Profissional&""<>"" then
                                           ConteudoAtendimento = ConteudoAtendimento & "<br><b>Profissional: </b>" & Profissional
                                       end if
                                       if Motivo&""<>"" then
                                           ConteudoAtendimento = ConteudoAtendimento & "<br><b>Motivo: </b>" & Motivo
                                       end if
                                       if Obs&""<>"" then
                                           ConteudoAtendimento = ConteudoAtendimento & "<br><b>Observação: </b>" & Obs
                                       end if

                                       %>
                                       <tr>
                                           <td></td>
                                           <td nowrap><%=DataAtendimento%></td>
                                           <td nowrap><%=Usuario%></td>
                                           <td><%=ConteudoAtendimento%></td>
                                       </tr>
                                       <%
                                   getEncaminhamento.movenext
                                   wend
                                   getEncaminhamento.close
                                   set getEncaminhamento = nothing

                               case 24'CARTEIRA DE VACINAÇÃO


                           end select

                        getDadosForm.movenext
                        wend
                        getDadosForm.close
                        set getDadosForm = nothing


                    end if
                    %>
                    </tbody>
                </table>
            </div>

        </div>

    <%if TipoCampoId = 8 and instr(Estruturacao, "|CID|")>0 OR instr(Estruturacao, "|Tags|")>0  then%>
        <hr>
        <div class="row mt20" style="display:''">
            <div class="col-md-12">
                <button class="btn btn-block btn-info text-left" type="button" onclick="$('#HistoricoCID').slideToggle()"><i class="far fa-chevron-right"></i> Histórico de CID</button>
            </div>
        </div>
        <div class="row pt10 col-md-12" id="HistoricoCID" style="display:''">
            <div class="col-md-12">
                <table class="table table-striped table-bordered">
                    <thead>
                        <tr>
                            <th>Data</th>
                            <th>Usuário</th>
                            <th>CID</th>
                            <th>Descrição</th>
                            <th>Status</th>
                            <th>Informações</th>
                        </tr>
                    </thead>
                    <tbody>
                    <%
                    set getIdsForm = db.execute("SELECT GROUP_CONCAT(form.id SEPARATOR ', ') idsform FROM _"&FormId&" form "&_
                                               "LEFT JOIN buiformspreenchidos bfp ON bfp.id=form.id AND bfp.PacienteID=form.PacienteID "&_
                                               "WHERE bfp.sysActive=1 AND form.PacienteID="&PacienteId&" ORDER BY form.id DESC")

                    if not getIdsForm.eof then
                        idsform = getIdsForm("idsform")
                        set getCid = db.execute("select pc.id, pc.StatusID, CONCAT(sta.TipoDescricao, ': ', sta.Descricao) Status, pc.DataEntrada, pc.DataSaida, pc.Hospital, t.Termo, t.CID10_Cd1, pc.sysDate, pc.sysUser FROM pacientesciap pc "&_
                                                "LEFT JOIN cliniccentral.tesauro t ON t.id=pc.CiapID "&_
                                                "LEFT JOIN cliniccentral.buipressets sta ON sta.id=pc.StatusID "&_
                                                "WHERE pc.FormID IN ("& idsform &") AND pc.CampoID="& CampoID &" ORDER BY pc.id DESC")
                        while not getCid.eof
                            Status = getCid("Status")
                            Cid = getCid("CID10_Cd1")
                            Descricao = getCid("Termo")
                            DataHora = getCid("sysDate")
                            DataEntrada = getCid("DataEntrada")
                            DataSaida = getCid("DataSaida")
                            Hospital = getCid("Hospital")
                            DataAtendimento = formatdatetime(DataHora, 2)&" "&formatdatetime(DataHora, 4)
                            Usuario = nameInTable(getCid("sysUser"))

                            Informacoes = ""

                            if DataEntrada&""<>"" then
                                Informacoes = Informacoes & "<br><b>Data Entrada: </b>" & DataEntrada
                            end if
                            if DataSaida&""<>"" then
                                Informacoes = Informacoes & "<br><b>Data Saída: </b>" & DataSaida
                            end if
                            if Hospital&""<>"" then
                                Informacoes = Informacoes & "<br><b>Hospital: </b>" & Hospital
                            end if

                            %>
                            <tr>
                                <td><%=DataAtendimento%></td>
                                <td><%=Usuario%></td>
                                <td><%=Cid%></td>
                                <td><%=Descricao%></td>
                                <td><%=Status%></td>
                                <td><%=Informacoes%></td>
                            </tr>
                            <%
                        getCid.movenext
                        wend
                        getCid.close
                        set getCid = nothing
                    end if
                    %>
                    </tbody>
                </table>
            </div>
        </div>
    <%end if%>

    </div>

</div>

<script>

    function aplicarConteudoLog(CampoId, FormConteudoId, CampoTipoId, OpcoesCheck){
        var ConteudoTexto = $("#conteudo-"+FormConteudoId).html();
        var ConteudoExistente = $("#Campo"+CampoId).html();
        var OpcaoCheck = [];
        if (CampoTipoId == 1 || CampoTipoId == 8){
            $("#Campo"+CampoId).val(ConteudoExistente + " " + ConteudoTexto);
        };
        if (CampoTipoId == 4 || CampoTipoId == 5){
            OpcaoCheck = OpcoesCheck.split(", ")
            OpcaoCheck.forEach((op) =>{
                $("#chk"+CampoId+"_"+op).prop("checked", true);
            });
            $("#Campo"+CampoId).prop("checked", true);
        };
        $("#modal-table").modal("hide");

    };
</script>
