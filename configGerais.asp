<!--#include file="connect.asp"-->
<!--#include file="Classes/StringFormat.asp"-->
<%if session("admin")=1 then

    if ref("E")="E" then

        set confOLD = db.execute("select * from sys_config")
        db_execute("update sys_config set FormatoDeNome='"&ref("FormatoDeNome")&"', BaixaAuto='"&ref("BaixaAuto")&"', OmitirValorGuia='"& ref("OmitirValorGuia") &"', ObrigarPreenchimentoDeFormulario='"& ref("ObrigarPreenchimentoDeFormulario") &"', SenhaStatusAgenda='"& ref("SenhaStatusAgenda") &"', BloquearValorInvoice='"& ref("BloquearValorInvoice") &"', AutoConsolidar='"&ref("AutoConsolidar")&"', SepararPacientes="& treatvalzero(ref("SepararPacientes")) &", NomeEmpresa='"&ref("NomeEmpresa")&"',BloquearEncaixeEmHorarioBloqueado='"&ref("BloquearEncaixeEmHorarioBloqueado")&"', ValidarCPFCNPJ='"&ref("ValidarCPFCNPJ")&"', BloquearCPFCNPJDuplicado='"&ref("BloquearCPFCNPJDuplicado")&"', SplitNF="& treatvalzero(ref("SplitNF")) &", MaximoDescontoProposta="& treatvalzero(ref("MaximoDescontoProposta")) &", DiasVencimentoProduto="& treatvalzero(ref("DiasVencimentoProduto")) &", Logo='"&ref("Logo")&"'")

        IF confOLD("FormatoDeNome") <> ref("FormatoDeNome") THEN

                IF ref("FormatoDeNome") = "Maiúscula" THEN
                   db.execute("UPDATE pacientes SET NomePaciente = UPPER(NomePaciente) WHERE sysactive = 1")
                   db.execute("UPDATE funcionarios SET NomeFuncionario = UPPER(NomeFuncionario) WHERE sysactive = 1")
                END IF

                IF ref("FormatoDeNome") = "Título" THEN
                    set objRec = db.execute("SELECT id, replace(NomePaciente,'''','`') as Nome FROM pacientes")
                    While Not objRec.EOF
                        nome = Trim(TratarNome("Título",objRec("Nome")))
                        db.execute("UPDATE pacientes SET NomePaciente ='"&nome&"' WHERE id="&objRec("id"))
                        objRec.MoveNext
                    Wend

                    set objRec = db.execute("SELECT id, replace(NomeFuncionario,'''','`') as Nome FROM funcionarios")
                    While Not objRec.EOF
                        nome = Trim(TratarNome("Título",objRec("Nome")))
                        db.execute("UPDATE funcionarios SET NomeFuncionario ='"&nome&"' WHERE id="&objRec("id"))
                        objRec.MoveNext
                    Wend

                END IF
        END IF

        %>
        <script type="text/javascript">
            new PNotify({
                title: 'Salvo com sucesso!',
                text: '',
                type: 'success',
                delay: 3000
            });
        </script>
        <%

    end if
    set conf = db.execute("select * from sys_config")
    BaixaAuto = conf("BaixaAuto")&""
    OmitirValorGuia = conf("OmitirValorGuia")
    SenhaStatusAgenda = conf("SenhaStatusAgenda")
    ObrigarPreenchimentoDeFormulario = conf("ObrigarPreenchimentoDeFormulario")
    BloquearValorInvoice = conf("BloquearValorInvoice")
    AutoConsolidar = conf("AutoConsolidar")
    FormatoDeNome = conf("FormatoDeNome")
    SepararPacientes = conf("SepararPacientes")
    NomeEmpresa = conf("NomeEmpresa")
    BloquearEncaixeEmHorarioBloqueado = conf("BloquearEncaixeEmHorarioBloqueado")
    SplitNF = conf("SplitNF")
    'ConfirmarTransferencia = conf("ConfirmarTransferencia")
    BloquearCPFCNPJDuplicado = conf("BloquearCPFCNPJDuplicado")
    ValidarCPFCNPJ = conf("ValidarCPFCNPJ")

    MaximoDescontoProposta = conf("MaximoDescontoProposta")
    DiasVencimentoProduto = conf("DiasVencimentoProduto")

    Logo = conf("Logo")

    %>
    <form id="frmOC">
        <input type="hidden" name="E" value="E" />

        <h2 class="mb20 mt30">Empresa</h2>
        <div class="row">
            <div class="col-md-3">
                <label for="NomeEmpresa">Nome da empresa</label>
                <input type="text" class="form-control" name="NomeEmpresa" id="NomeEmpresa" value="<%=NomeEmpresa%>">
            </div>
            <div class="col-md-9">
                <label for="Logo">URL da logo</label>
                <input type="text" class="form-control" name="Logo" id="Logo" value="<%=Logo%>">
            </div>
        </div>
        <br>
        <div class="checkbox-custom checkbox-primary">
            <input type="checkbox" name="ValidarCPFCNPJ" id="ValidarCPFCNPJ" value="S"<%if ValidarCPFCNPJ="S" then response.write(" checked ") end if %> />
            <label for="ValidarCPFCNPJ">Validar CPF/CNPJ ao salvar</label>
        </div>
        <div class="checkbox-custom checkbox-primary">
            <input type="checkbox" name="BloquearCPFCNPJDuplicado" id="BloquearCPFCNPJDuplicado" value="S"<%if BloquearCPFCNPJDuplicado="S" then response.write(" checked ") end if %> />
            <label for="BloquearCPFCNPJDuplicado">Não salvar CPF/CNPJ duplicados</label>
        </div>
        <h2 class="mb20">Financeiro</h2>
        <div class="checkbox-custom checkbox-primary">
            <input type="checkbox" name="BaixaAuto" id="BaixaAuto" value="S"<%if BaixaAuto="S" then response.write(" checked ") end if %> /> <label for="BaixaAuto">Baixar itens ou lançar pagamento automaticamente mediante finalização de atendimento.</label>
        </div>
        <div class="checkbox-custom checkbox-primary">
            <input type="checkbox" name="BloquearValorInvoice" id="BloquearValorInvoice" value="S"<%if BloquearValorInvoice="S" then response.write(" checked ") end if %> /> <label for="BloquearValorInvoice">Bloquear alteração manual de valor da conta a receber para usuário sem permissão de alteração de contas a receber.</label>
        </div>
        <div class="checkbox-custom checkbox-primary">
            <input type="checkbox" name="AutoConsolidar" id="chkAutoConsolidar" value="S"<%if AutoConsolidar="S" then response.write(" checked ") end if %> /> <label for="chkAutoConsolidar">Consolidar repasses pagos automaticamente.</label>
        </div>
        <div class="checkbox-custom checkbox-primary">
            <input type="checkbox" name="SplitNF" id="SplitNF" value="1"<%if SplitNF=1 then response.write(" checked ") end if %> /> <label for="SplitNF">Separar notas fiscais (split) de acordo com as regras pré-estabelecidas.</label>
        </div>



        <h2 class="mb20 mt30">Guias TISS</h2>
        <div class="row">
            
            <%= quickfield("multiple", "OmitirValorGuia", "Não exibir o valor do procedimento na impressão da guia para os seguintes usuários:", 12, OmitirValorGuia, "select id, Nome from cliniccentral.licencasusuarios where LicencaID="& replace(session("Banco"), "clinic", "") &" and Email <> '' and Nome <> '' order by Nome", "Nome", "") %>
        </div>


        <h2 class="mb20 mt30">Atendimento</h2>
        <div class="checkbox-custom checkbox-primary">
            <input type="checkbox" name="ObrigarPreenchimentoDeFormulario" id="ObrigarPreenchimentoDeFormulario" value="S"<%if ObrigarPreenchimentoDeFormulario="S" then response.write(" checked ") end if %> /> <label for="ObrigarPreenchimentoDeFormulario">
            Obrigar o preenchimento de formulário.</label>
        </div>

        <h2 class="mb20 mt30">Agenda</h2>
        <div class="checkbox-custom checkbox-primary">
            <input type="checkbox" name="SenhaStatusAgenda" id="SenhaStatusAgenda" value="S"<%if SenhaStatusAgenda="S" then response.write(" checked ") end if %> /> <label for="SenhaStatusAgenda">Bloquear alteração de dados de agendamento de paciente que já chegou, liberando somente mediante digitação de senha de usuário com permissão para isso.</label>
        </div>

        <div class="checkbox-custom checkbox-primary">
            <input type="checkbox" name="BloquearEncaixeEmHorarioBloqueado" id="BloquearEncaixeEmHorarioBloqueado" value="S"<%if BloquearEncaixeEmHorarioBloqueado="S" then response.write(" checked ") end if %> />
            <label for="BloquearEncaixeEmHorarioBloqueado">Bloquear encaixes em horario bloqueado</label>
        </div>

        <div class="checkbox-custom checkbox-primary">
            <input type="checkbox" name="ExibirProntuarioAgendamento" id="ExibirProntuarioAgendamento" value="S"<%if ExibirProntuarioAgendamento="S" then response.write(" checked ") end if %> />
            <label for="ExibirProntuarioAgendamento">Exibir prontuário nos agendamentos</label>
        </div>


        <h2 class="mb20 mt30">Pacientes</h2>
        <div class="checkbox-custom checkbox-primary">
            <input type="checkbox" name="SepararPacientes" id="SepararPacientes" value="1"<%if SepararPacientes then response.write(" checked ") end if %> /> <label for="SepararPacientes">Separar pacientes por profissionais.</label>
        </div>

        <h2 class="mb20 mt30">Produtos</h2>
        <div class="row">
            <div class="col-md-6">
                <label for="DiasVencimentoProduto">Número dias para notificação de vencimento dos produtos</label>
                <input type="text" class="form-control" name="DiasVencimentoProduto" id="DiasVencimentoProduto"  value="<%=DiasVencimentoProduto%>">
            </div>
        </div>

        <h2 class="mb20 mt30">Formato padrão para Nome de Paciente, Funcionário e Profissionais</h2>
        <div class="radio-custom radio-primary">
            <input type="radio" name="FormatoDeNome" id="FormatoDeNomeN" value="Normal"<%if FormatoDeNome="Normal"  or IsNull(FormatoDeNome) OR FormatoDeNome ="" then response.write(" checked ") end if %> />
            <label for="FormatoDeNomeN">Texto normal</label>
        </div>
        <div class="radio-custom radio-primary">
            <input type="radio" name="FormatoDeNome" id="FormatoDeNomeM" value="Maiúscula"<%if FormatoDeNome="Maiúscula" then response.write(" checked ") end if %> />
            <label for="FormatoDeNomeM">TEXTO MAIÚSCULO</label>
        </div>
        <div class="radio-custom radio-primary">
            <input type="radio" name="FormatoDeNome" id="FormatoDeNomeT" value="Título"<%if FormatoDeNome="Título" then response.write(" checked ") end if %> />
            <label for="FormatoDeNomeT">Texto Título</label>
        </div>

        <hr class="short alt" />
        <div class="panel-footer">
            <button id="btnSalvarConfig" class="btn btn-sm btn-primary">Salvar</button>
        </div>
        
    </form>
<script type="text/javascript">
$("#frmOC").submit(function(){
    $("#btnSalvarConfig").attr("disabled", true);

    $.post("configGerais.asp", $(this).serialize(), function(data){
       $("#divIntegracoes").html(data);
    });
    return false;
    });

<!--#include file="JQueryFunctions.asp"-->
</script>
<%end if %>