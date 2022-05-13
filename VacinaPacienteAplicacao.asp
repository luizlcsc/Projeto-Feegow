<!--#include file="connect.asp"-->
<%
if ref("opt") = "AtualizaLote" then
%>
        <select id="SelectPosicao" name="SelectPosicao" class="select-lote">
            
<%

            set produtos = db.execute(" SELECT p.NomeProduto AS descricao, "&_
                                        " e.Lote, "&_
                                        " e.id AS PosicaoID "&_
                                        " FROM vacina_aplicacao va "&_
                                        " JOIN vacina_serie_dosagem vsd ON vsd.id = va.VacinaSerieDosagemID "&_
                                        " JOIN produtos p ON p.id = vsd.ProdutoID "&_
                                        " JOIN estoqueposicao e ON e.ProdutoID = p.id "&_
                                        " LEFT JOIN produtoslocalizacoes pl ON pl.id = e.LocalizacaoID "&_
                                        " WHERE va.id = "&ref("AplicacaoID")&_
                                        " AND (pl.UnidadeID = "&ref("UnidadeID")&" or pl.UnidadeID IS NULL)"&_
                                        " AND (CASE WHEN Responsavel IS NOT NULL AND TRIM(Responsavel) <> '' AND TRIM(Responsavel) <> '0' THEN (CASE WHEN Responsavel REGEXP '^3_' THEN Responsavel END) = CONCAT('3_',"&ref("PacienteID")&") ELSE 1 = 1 END)")
            if not produtos.EOF then
                %> <option value="0">Selecione <%
            else 
                optionValue = "<option value='0'>Nenhum lote encontrado"
            end if

            while not produtos.EOF
                optionValue = optionValue&"<option value='"&produtos("PosicaoID")&"'>"&produtos("Lote")&" - "&produtos("descricao")
                
                produtos.movenext
            wend

            produtos.close
            set produtos = nothing

            response.Write(optionValue)
%>
        </select>

    <script type="text/javascript">
        $('.select-lote').select2();
    </script>
<%
else
StatusID = "0"
if req("StatusID")&"" <> "" then
    StatusID = req("StatusID")
end if
%>
<div class="modal-header ">
    <div class="row">
        <div class="col-md-8">
            <h3 class="lighter blue">Aplicar vacina</h3>
        </div>

        <div class="col-md-4" style="margin-top: 15px;">
            <button class="bootbox-close-button close" type="button" data-dismiss="modal">×</button>
        </div>
    </div>
</div>
<div class="panel-body p25" id="iProntCont">
    <div class="tab-content">
        <div class="tab-pane in active">
            <div class="row">
                <div class="col-xs-12">
                    <div class="row">
                        <%if StatusID = "3" then%>
                            <%=quickField("text", "InputDataAplicacao", "Data de aplicação", 4, req("DataAplicacao"), "", "", " readOnly")%>
                        <%else%>
                            <div class="col-md-4">
                                <label for="InputDataAplicacao">Data de aplicação</label>
                                <div class="input-group">
                                    <input id="InputDataAplicacao" autocomplete="off" class="form-control input-mask-date date-picker" type="text" data-date-format="dd/mm/yyyy" value="<%=Right("00"&Day(date),2)&"/"&Right("00"&Month(date),2)&"/"&Year(date)%>" <%=readOnly%>>
                                    <span class="input-group-addon">
                                    <i class="far fa-calendar bigger-110"></i>
                                    </span>
                                </div>	
                            </div>
                        <%end if%>
                        <%if StatusID = "3" then%>
                            <%=quickField("text", "SelectViaAplicacao", "Via", 4, req("NomeViaAplicacao"), "", "", " readOnly")%>
                        <%else%>
                            <div class="col-md-4">
                                <label for="SelectViaAplicacao">Via</label>
                                    <select id="SelectViaAplicacao" name="SelectViaAplicacao" class="select-via">
                                        <option value="0">Selecione
        <%
                                        set vias = db.execute(" SELECT id, "&_
                                                            " CONCAT(NomeViaAplicacao, ' (',SiglaViaAplicacao,')') AS SiglaViaAplicacao"&_
                                                            " FROM cliniccentral.vacina_via_aplicacao ORDER BY 2 ")
                                        while not vias.EOF
                                            response.Write("<option value='"&vias("id")&"'>"&vias("SiglaViaAplicacao"))
                                            vias.movenext
                                        wend

                                        vias.close
                                        set vias = nothing
        %>
                                    </select>
                            </div>
                        <%end if%>
                        <%if StatusID = "3" then%>
                            <%=quickField("text", "SelectLadoAplicacao", "Lado", 4, req("LadoAplicacao"), "", "", " readOnly")%>
                        <%else%>
                            <div class="col-md-4">
                                <label for="SelectLadoAplicacao">Lado</label>
                                <select id="SelectLadoAplicacao" name="SelectLadoAplicacao" class="select-lado">
                                    <option value="0">Selecione
                                    <option value="1">Direito
                                    <option value="2">Esquerdo
                                </select>	
                            </div>
                        <%end if%>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-xs-12">
                    <div class="row">
                        <%if StatusID = "3" then%>
                            <%=quickField("text", "SelectUnidade", "Unidade", 6, req("Unidade"), "", "", " readOnly")%>
                        <%else%>
                            <div class="col-md-6">
                                <label for="SelectUnidade">Unidade</label>
                                <select id="SelectUnidade" name="SelectUnidade" class="select-unidade">
                                    <option value="-1">Selecione
    <%
                                    set produtos = db.execute(" SELECT '0' id, "&_
                                                                " NomeFantasia "&_
                                                                " FROM empresa UNION ALL SELECT CAST(id AS CHAR), NomeFantasia FROM sys_financialcompanyunits WHERE sysActive=1 ")

                                    while not produtos.EOF
                                
                                        if "'"&produtos("id")&"'" = "'"&session("UnidadeID")&"'" then
                                            selecionado = "selected"
                                        end if
                                            
                                        response.Write("<option value='"&produtos("id")&"' "&selecionado&">"&produtos("NomeFantasia"))
                                        
                                        selecionado = ""

                                        produtos.movenext
                                    wend

                                    produtos.close
                                    set produtos = nothing

    %>
                                </select>
                            </div>
                        <%end if%>
                        <%if StatusID = "3" then%>
                            <%=quickField("text", "SelectPosicao", "Dose", 6, req("Dose"), "", "", " readOnly")%>
                        <%else%>
                            <div class="col-md-6">
                                <label for="SelectPosicao">Lote</label>
                                <div id="DivSelectPosicao">
                                    <select id="SelectPosicao" name="SelectPosicao" class="select-lote">
    <%
                                        sqlLote = " SELECT p.NomeProduto AS descricao, "&_
                                                                                                                " e.Lote, "&_
                                                                                                                " e.id AS PosicaoID "&_
                                                                                                                " FROM vacina_aplicacao va "&_
                                                                                                                " JOIN vacina_serie_dosagem vsd ON vsd.id = va.VacinaSerieDosagemID "&_
                                                                                                                " JOIN produtos p ON p.id = vsd.ProdutoID "&_
                                                                                                                " JOIN estoqueposicao e ON e.ProdutoID = p.id "&_
                                                                                                                " LEFT JOIN produtoslocalizacoes pl ON pl.id = e.LocalizacaoID "&_
                                                                                                                " WHERE va.id = "&ref("valor2")&_
                                                                                                                " AND (pl.UnidadeID = "&session("UnidadeID")&" or pl.UnidadeID IS NULL)"&_
                                                                                                                " AND e.Quantidade >= 1"&_
                                                                                        " AND (CASE WHEN Responsavel IS NOT NULL AND TRIM(Responsavel) <> '' AND TRIM(Responsavel) <> '0' AND Responsavel REGEXP '^3_' THEN (CASE WHEN Responsavel REGEXP '^3_' THEN Responsavel END) = CONCAT('3_',"&ref("valor1")&") ELSE 1 = 1 END)"

                                        set produtos = db.execute(sqlLote)

                                        if not produtos.EOF then
                                            %> <option value="-1">Selecione <%
                                        else
                                            response.write("<option value='0'>Nenhum lote encontrado")
                                        end if
                                        
                                        while not produtos.EOF
                                            response.Write("<option value='"&produtos("PosicaoID")&"'>"&produtos("Lote")&" - "&produtos("descricao")&"")
                                            produtos.movenext
                                        wend

                                        produtos.close
                                        set produtos = nothing
    %>
                                    </select>
                                </div>
                            </div>
                        <%end if%>
                    </div>
                </div>
            </div>
            <div class="row" id="DivQuantidade" style="display:none">
                <%=quickField("text", "Quantidade", "Quantidade", 2, "", " text-right ", "", " min='0' ")%>
                <div class="col-md-8 d-none"><br>
                    <label><input class="ace" type="radio" id="TipoUnidadeC" name="TipoUnidade" required="required" value="C"><span class="lbl" id="TipoUnidadeCTexto"> </span></label>
                    <br>
                    <label><input class="ace" type="radio" id="TipoUnidadeU" name="TipoUnidade" required="required" value="U"><span class="lbl" id="TipoUnidadeUTexto"> </span></label>
                </div>
            </div>
            <div class="row">
                <div class="col-xs-12">
                    <div class="row">
                        <div class="col-md-12">
                            <label for="InputObservacao">Observação</label>
                            <textarea class="form-control" id="InputObservacao"><%=req("Observacao")%></textarea>
                        </div>
                    </div>
                </div>
            </div>
            <%
            if StatusID = "3" then%>
                <div class="row" id="DivHistoricoAplicacaoVacina" style="display:none;">
                    <h3 class="lighter blue">Histórico de Aplicação</h3>
                    <table class="table table-striped table-bordered">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Data</th>
                                <th>Usuário</th>
                                <th>Obs Anterior</th>
                                <th>Obs Alterada</th>
                            </tr>
                        </thead>
                        <%
                            'Criar select para buscar dados
                            set HistoricoVacinaAplicacao = db.execute("SELECT va.id AS VacinaAplicacaoID, va.DataAplicacao, su.`Table`, p.NomeProfissional, f.NomeFuncionario, l.ValorAnterior as ObsAnterior, l.valorAtual as ObsAtual  FROM vacina_aplicacao va "&_
                                                                        " LEFT JOIN log l ON l.I = va.id "&_
                                                                        " LEFT JOIN sys_users su ON su.id = l.sysUser "&_
                                                                        " LEFT JOIN profissionais p ON p.id = su.idInTable "&_
                                                                        " LEFT JOIN funcionarios f ON f.id = su.idInTable "&_
                                                                        " WHERE (va.id = "&ref("valor2")&" AND l.I="&ref("valor2")&") AND l.recurso='vacina_aplicacao'")
                        %>
                        <tbody>
                            <%
                                while not HistoricoVacinaAplicacao.eof
                                    UsuarioAlteracao = HistoricoVacinaAplicacao("NomeProfissional")
                                    if LCase(HistoricoVacinaAplicacao("Table")) <> "profissionais" then
                                        UsuarioAlteracao = HistoricoVacinaAplicacao("NomeFuncionario")
                                    end if
                            %>
                                    <tr>
                                        <th><code>#<%=HistoricoVacinaAplicacao("VacinaAplicacaoID")%></code></th>
                                        <th><%=HistoricoVacinaAplicacao("DataAplicacao")%></th>
                                        <th><%=UsuarioAlteracao%></th>
                                        <td><%=replace(replace(HistoricoVacinaAplicacao("ObsAnterior"),"|^",""),"^|","")%></td>
                                        <td><%=replace(replace(HistoricoVacinaAplicacao("ObsAtual"),"|^",""),"^|","")%></td>
                                    </tr>
                            <%
                                HistoricoVacinaAplicacao.movenext
                                wend
                                HistoricoVacinaAplicacao.close
                                set HistoricoVacinaAplicacao = nothing
                            %>       
                        </tbody>
                    </table>
                </div>
            <%end if%>
        </div>
    </div>
</div> 

<div class="modal-footer no-margin-top">
    <button class="btn btn-sm btn-primary pull-right" id="saveVacinaPacienteAplicacao"><i class="far fa-save"></i> Salvar</button>
    <%if StatusID = "3" then%>
        <button title="Histórico de Aplicação" class="btn btn-sm btn-default hidden-xs mr10 pull-right" id="historicoAplicacaoVacina"><i class="far fa-history"></i> </button>
    <%end if%>
</div>

<script type="text/javascript">

    $('.select-via').select2();
    $('.select-lado').select2();
    $('.select-unidade').select2();
    $('.select-lote').select2();

    $('.date-picker').datepicker({autoclose:true}).next().on(ace.click_event, function(){
        $(this).prev().focus();
    });

    $("#SelectUnidade").on('change',function(){
        var UnidadeID = $(this).val();

        $.post("VacinaPacienteAplicacao.asp",{
            opt: 'AtualizaLote',
            PacienteID: '<%=ref("valor1")%>',
            UnidadeID: UnidadeID,
            AplicacaoID: <%=ref("valor2")%>,
        },function(data){
            $("#DivSelectPosicao").html(data);

        });
    });

    $("#saveVacinaPacienteAplicacao").click(function(){
        
        strDataAplicacao = $("#InputDataAplicacao").val();
        arrDataAplicacao = strDataAplicacao.split("/");
        novaDataAplicacao = arrDataAplicacao[2]+"-"+arrDataAplicacao[1]+"-"+arrDataAplicacao[0];

        $.post("saveVacinaPaciente.asp",{
            Tipo:"Aplicacao",
            StatusID:'<%=StatusID%>',
            PacienteID:'<%=ref("valor1")%>',
            AplicacaoID: <%=ref("valor2")%>,
            DataAplicacao: novaDataAplicacao,
            PosicaoID: $("#SelectPosicao").val(),
            Quantidade:$("#Quantidade").val(),
            TipoUnidade:$('#DivQuantidade').find('input:radio:checked').val(),
            ViaAplicacaoID: $("#SelectViaAplicacao").val(),
            LadoAplicacao: $("#SelectLadoAplicacao").val(),
            UnidadeID: $("#SelectUnidade").val(),
            Observacao: $('#InputObservacao').val(),
        },function(data,status){
            pront('timeline.asp?PacienteID=<%=ref("valor1")%>&Tipo=|VacinaPaciente|');
            eval(data);
        });
    });

    $("#SelectPosicao").on('change',function(){
        let EstoquePosicaoID = $("#SelectPosicao").val();

        if(EstoquePosicaoID > 0){
            $.post("QuantidadeProduto.asp",{
                EstoquePosicaoID:EstoquePosicaoID,
            },function(data){
                if(data.length > 0){
                    let TipoUnidade = data[0].TipoUnidade
                    let ApresentacaoNome = data[0].ApresentacaoNome
                    let ApresentacaoQuantidade = data[0].ApresentacaoQuantidade
                    let NomeUnidade = data[0].Descricao
                    if(TipoUnidade == 'C'){
                        $('#TipoUnidadeC').prop('checked',true);
                    }else{
                        $('#TipoUnidadeU').prop('checked',true);
                    }
                    $('#TipoUnidadeCTexto').text(` ${ApresentacaoNome} com ${ApresentacaoQuantidade} ${NomeUnidade}(s)`);
                    $('#TipoUnidadeUTexto').text(` ${NomeUnidade.charAt(0).toUpperCase() + NomeUnidade.slice(1)}(s)`);
                    $('#Quantidade').val('1,00');
                    $('#DivQuantidade').show();
                }
            });
        }else{
            $('#DivQuantidade').hide();
        }
    });

    $("#Quantidade").on('change',function(){
        let valor = $("#Quantidade").val();
        let valorLimpo = valor.replace(',','').replace('.','')
        let tamanhoCampo = valorLimpo.length;
        if(tamanhoCampo == 1){
            valorLimpo = valorLimpo+'00';
            tamanhoCampo = 3;
        }else if(tamanhoCampo == 2){
            valorLimpo = valorLimpo+'0';
            tamanhoCampo = 3;
        }
        let valorInteiro = valorLimpo.substr(0,(tamanhoCampo-2));
        let valorPosVirgula = valorLimpo.substr((tamanhoCampo-2), 2);
        $("#Quantidade").val(valorInteiro+','+valorPosVirgula);
    });
    $('#historicoAplicacaoVacina').click(function(){
        $('#DivHistoricoAplicacaoVacina').toggle();

    });
</script>
<%end if%>