<%
if req("Agenda")="1" then
    %>
    <div class="row">
        <div class="col-md-12">
            <a href="./?P=Pacientes&I=<%=req("I")%>&Pers=1" class="btn btn-sm btn-dark pull-right"><i class="far fa-external-link"></i> Ir para ficha completa</a>
        </div>
    </div>
    <%
end if

response.Charset="utf-8"


if request.ServerVariables("REMOTE_ADDR")<>"::1" and req("Debug")="" then
	on error resume next
end if

if lcase(session("Table"))="profissionais" and device()="" and req("I")<>"N" then
	db_execute("update sys_users set UltPac="&req("I")&" where id="&session("User"))
end if

'por causa dos formularios do roberto diniz (1124) -> paciente camila pontes soares rocha

function badge(val)
	if val<>"0" then
		badge = " <span class=""badge badge-warning pull-right"">"&val&"</span>"
	else
		badge = ""
	end if
end function

PacienteID = req("I")
call insertRedir(req("P"), PacienteID)
if req("Agenda")="1" then
    set reg = db.execute("select p.*, '0' totalprescricoes, '0' totalatestados, '0' totalpedidos, '0' totaldiagnosticos, '0' totalarquivos, '0' totalimagens, '0' qtepedidos,'0' totalrecibos, '0' totalae, '0' totallf from Pacientes as p where id="&PacienteID)
else
    set reg = db.execute("select p.*, "&_
    "(select count(id) from pacientesprescricoes where sysActive=1 AND PacienteID="&PacienteID&" ) as totalprescricoes, "&_
    "(select count(id) from pacientesatestados where sysActive=1 AND PacienteID="&PacienteID&" ) as totalatestados, "&_
    "(select count(id) from pacientespedidos where sysActive=1 AND PacienteID="&PacienteID&" ) as qtepedidos, "&_
    "(select count(id) from pedidossadt where sysActive=1 AND PacienteID="&PacienteID&" ) as qtepedidossadt, "&_
    "(select count(id) from pacientesdiagnosticos where sysActive=1 AND PacienteID="&PacienteID&" ) as totaldiagnosticos, "&_
    "(select count(id) from arquivos where PacienteID="&PacienteID&" and Tipo='A' ) as totalarquivos, "&_
    "(select count(id) from arquivos where PacienteID="&PacienteID&" and Tipo='I' ) as totalimagens, "&_
    "(select count(id) from recibos where (Texto is not null and Texto<>'' ) and PacienteID="&PacienteID&" AND sysActive=1 ) as totalrecibos, "&_
    "(select count(fpae.id) from buiformspreenchidos as fpae left join buiforms as mae on fpae.ModeloID=mae.id where fpae.PacienteID="&PacienteID&" and (fpae.sysActive=1 or fpae.sysActive is null) and (mae.Tipo=1 or mae.Tipo=2 or isnull(mae.Tipo))) as totalae, "&_
    "(select count(fplf.id) from buiformspreenchidos as fplf left join buiforms as mlf on fplf.ModeloID=mlf.id where fplf.PacienteID="&PacienteID&" and (fplf.sysActive=1 or fplf.sysActive is null) and (mlf.Tipo=3 or mlf.Tipo=4)) as totallf "&_
    "from Pacientes as p where id="&PacienteID)
end if
    splBdgs = split("totalprescricoes, totalatestados, qtepedidos, totaldiagnosticos, totalarquivos, totalimagens, totalrecibos, totalae, totallf", ", ")


if not isnull(reg("Nascimento")) and not isnull(reg("NomePaciente")) then
	sqlNascimento = " and (Nascimento="&mydatenull(reg("Nascimento"))&" or isnull(Nascimento))"
end if
%>
<br>

<input type="hidden" name="DadosAlterados" id="DadosAlterados" value="" />
<form method="post" id="frm" name="frm" action="save.asp" autocomplete="off">


	<input type="hidden" name="I" value="<%=PacienteID%>" />
	<input type="hidden" name="cmd" value="<%=req("cmd")%>" />
	<input type="hidden" name="P" value="<%=req("P")%>" />


<%=header(req("P"), "Paciente", reg("sysActive"), req("I"), req("Pers"), "Follow")%>
    <script type="text/javascript">
        <%
        if reg("sysActive")=0 then
        %>
            $('#lMenu .checkStatus > a').css('pointer-events','none');
            $('li.checkStatus').css('cursor','no-drop');
        <%
        end if
        %>
       

        $(document).ready(function(){
            <%
            for i=0 to ubound(splBdgs)
                response.write(bdg(splBdgs(i), reg(""&splBdgs(i)&"")) )
            next

            %>

            $(".crumb-active a").html("<%=reg("NomePaciente")%>");
            $(".crumb-link").removeClass("hidden");
            $(".crumb-link").html("<%=idade(reg("Nascimento"))%>");

            <%
            if reg("ConvenioID1") <> "" and reg("ConvenioID1") <> "0" and not isnull(reg("ConvenioID1")) then
                set NomeConvenioObj = db.execute("SELECT NomeConvenio FROM convenios WHERE id = "&reg("ConvenioID1"))

                if not NomeConvenioObj.eof then
                    %>
                    $(".crumb-link").append("  (<strong><%=NomeConvenioObj("NomeConvenio")%></strong>)");
                    <%
                end if
            end if
            if not isnull(reg("Tabela")) and reg("Tabela")<>0 then
                set NomeTabelaObj = db.execute("SELECT NomeTabela FROM tabelaparticular WHERE id = "&reg("Tabela"))

                if not NomeTabelaObj.eof then
                    %>
                    $(".crumb-link").append("  (<strong><%=NomeTabelaObj("NomeTabela")%></strong>)");
                    <%
                end if
            end if
            if reg("NomeSocial") & "" <>"" then
                    %>
                    $(".crumb-link").append("  <code>NOME SOCIAL: <%=reg("NomeSocial")%></code>");
                    <%
            end if
            %>
        });
    </script>

<%
if reg("Foto")="" or isnull(reg("Foto")) then
	divDisplayUploadFoto = "block"
	divDisplayFoto = "none"
else
	divDisplayUploadFoto = "none"
	divDisplayFoto = "block"
end if
%>




<div class="panel" id="DadosComplementares">
  <div class="panel-body">
	<div class="col-md-2" id="divAvatar">
            <div id="camera" class="camera"></div>
            <div id="divDisplayUploadFoto" style="display:<%=divDisplayUploadFoto%>">
                <input type="file" name="Foto" id="Foto" />
                <button type="button" id="clicar" class="btn btn-block btn-xs btn-info hidden-xs"><i class="far fa-camera"></i></button>
            </div>
            <div id="divDisplayFoto" style="display:<%= divDisplayFoto %>">
	            <img id="avatarFoto" src="<%= arqEx(reg("Foto"), "Perfil") %>" class="img-thumbnail" width="100%" />
                <button type="button" class="btn btn-xs btn-danger" onclick="removeFoto();" style="position:absolute; left:18px; bottom:6px;"><i class="far fa-trash"></i></button>
            </div>
            <div class="row"><div class="col-xs-6">
	            <button type="button" class="btn btn-xs btn-success btn-block" style="display:none" id="take-photo"><i class="far fa-check"></i></button>
            </div><div class="col-xs-6">
	            <button type="button" style="display:none" id="cancelar" onclick="return cancelar();" class="btn btn-block btn-xs btn-danger"><i class="far fa-remove"></i></button>
            </div></div>
    </div>
      <script type="text/javascript">

          function sipac(Ipac){
            if(Ipac>1000000000){
                $.get("baseExt.asp?I="+Ipac, function(data){ eval(data) });
            }else{
                location.href="?P=Pacientes&Pers=1&I="+Ipac;
            }
          }

          function changeRequiredCPF(that) {
               let val = $(that).is(':checked');

               var data = $('#Pais').select2('data');
               var nomePais = data[0].full_name;
               let outroPais = nomePais && nomePais != "" && nomePais != "Brasil";

              if(val || outroPais){
                  $("#CPF").removeAttr("required").attr("readonly", true).val("");
              }
              if(!(val || outroPais))
              {
                  $("#CPF").attr("required", "required").attr("readonly", false);
                  var a = $("#CPF");

              }
          }
      </script>

    <div class="col-md-10">
        <div class="row">

            <div class="col-md-4">
                <%=selectList("Nome &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<small class=""label label-xs label-light hidden"" id=""resumoConvenios""></small>", "NomePaciente", reg("NomePaciente"), "pacientes", "NomePaciente", "sipac($(this).val());", " required", "")%>
            </div>
            <%
            if reg("sysActive")=1 then
            %>
            <script >
                $("#NomePaciente").attr("readonly", true);
                $("#NomePaciente").parent("div").parent("div").find("label").after("<button title='Editar nome do paciente' onclick='$(\"#NomePaciente\").attr(\"readonly\", false); $(this).fadeOut(); $(\"#NomePaciente\").focus();' type='button' class='btn btn-link btn-xs'><i class='far fa-edit'></i></button>");
            </script>
            <%
            end if
            %>
            <%=quickField("datepicker", "Nascimento", "Nascimento", 2, reg("Nascimento"), "input-mask-date", "", "")%>
            <div class="col-md-1">
                <label for="Estrangeiro">Estrangeiro</label>
                   <div class="checkbox-custom checkbox-primary">
                                            <input type="checkbox" class="ace" onchange="changeRequiredCPF(this)"
                                             <% IF reg("Estrangeiro") = "1" THEN %>
                                               checked
                                             <% END IF %>
                                             name="Estrangeiro" id="Estrangeiro" value="1" />
                                            <label class="checkbox" for="Estrangeiro"> </label>
                                        </div>
            </div>
            <%
                mask = " input-mask-cpf "
                IF  getConfig("ExibirMascaraCPFPaciente") = 0  THEN
                  mask = ""
                END IF

                CorIdentificacao = reg("CorIdentificacao")
            %>
            <%=quickField("CPF", "CPF", "CPF", 3, reg("CPF"), " "&mask&" ", "", " ") %>

            <% if reg("SemCPF") = "on" then %>
                <script>$("#SemCPF-CPF").prop("checked", true).change();</script>
            <% else %>
                <script>$("#SemCPF-CPF").prop("checked", false).change();</script>
            <% end if %>

            <%=quickField("simpleColor", "CorIdentificacao", "Cor de Identificação", 2, CorIdentificacao, "select * from Cores", "Cor", "")%>

        </div><br />
        <div class="row">
            <%= quickField("simpleSelect", "Sexo", "Sexo", 2, reg("Sexo"), "select * from Sexo where sysActive=1", "NomeSexo", " empty")%>
            <%= quickField("text", "NomeSocial", "Nome Social", 2, reg("NomeSocial"), "", "", " autocomplete='nome-social' ") %>
			<%= quickField("text", "Altura", "Altura", 2, reg("Altura"), " input-mask-brl text-right", "", "") %>
            <%= quickField("text", "Peso", "Peso", 2, reg("Peso"), "input-mask-brl text-right", "", "") %>
            <%= quickField("text", "IMC", "IMC", 2, reg("IMC"), "text-right", "", " readonly") %>
            <div class="col-md-2">
            	<label>Prontu&aacute;rio

                <%
                AlterarNumeroProntuario= getConfig("AlterarNumeroProntuario")
                if reg("idImportado")&"" <> "" and AlterarNumeroProntuario&""="0" then
                %>
            	<i data-toggle="tooltip"
                  title="Prontuário antigo: <%=reg("idImportado")%>"
                  class="far fa-info-circle"
                  aria-hidden="true"></i>
                <%
                end if
                %>
                  <br /></label>
			<%
                if AlterarNumeroProntuario = 1 then
                'if session("banco")="clinic1612" or session("banco")="clinic5868" or session("banco")="clinic3610" or session("banco")="clinic105" or session("banco")="clinic3859" or session("banco")="clinic5491" then
				Prontuario = reg("idImportado")
				if isnull(Prontuario) then
					set pultPront = db.execute("select idImportado Prontuario from pacientes where not isnull(idImportado) order by idImportado desc limit 1")
					if pultPront.eof then
						Prontuario = 1
					else
						Prontuario = clng(pultPront("Prontuario"))+1
					end if
				end if
				%>
	            <input type="text" name="Prontuario" id="Prontuario" class="form-control text-right" value="<%=Prontuario%>" />
			<% Else %>
    	        <input type="text" class="form-control text-right" value="<%=reg("id")%>" disabled='disabled' />
			<% End If%>
            </div>
        </div>

        <%
        if session("Banco")="clinic5459" then
            if req("I")&""<>"" then
                set ClienteStatus = db.execute("SELECT Status, TipoCobranca FROM cliniccentral.licencas WHERE Cliente="&req("I")&" ORDER BY id LIMIT 1")
                if not ClienteStatus.eof then
                    Status = ClienteStatus("Status")
                    TipoCobranca = ClienteStatus("TipoCobranca")
                    if Status="C" then
                        %><span class="label bg-success">Efetivado</span><%
                    end if
                    if Status="T" then
                        %><span class="label bg-warning">Testando</span><%
                    end if
                    if Status="B" then
                        %><span class="label bg-danger">Bloqueado</span><%
                    end if
                    if Status="I" then
                        %><span class="label bg-primary">Implementação</span><%
                    end if
                    if TipoCobranca="1" then
                        %><span class="label bg-info">Usuário</span><%
                    end if
                    if TipoCobranca="0" then
                        %><span class="label bg-dark">Profissional</span><%
                    end if

                end if
            end if
        end if
        %>
	</div>
    	<script type="text/javascript">
		$(document).ready(function(e) {
            $("#resumoConvenios").html( $('#searchConvenioID1').val() );
		});
		</script>
  </div>
</div>


<div class="alert alert-danger hidden" id="divComparaPacientes">
    <button class="close" data-dismiss="alert" type="button"><i class="far fa-remove"></i></button>
    <span></span>
</div>
    <script>
        var loadResumoClinico = () => {

            $("#pront").html(`<div style="text-align: center"><img src="assets/img/gif_cubo_alpha.gif"></div>`);
            fetch(domain+"/api/api-livia?tk="+localStorage.getItem("tk"),{
              "Content-Type": "application/json",
              "method": "POST",
              "body":JSON.stringify({
                                    	"federalTaxId": "<%=reg("CPF")%>",
                                    	"userFederalTaxId": "11111111111",
                                    	"userIdentifierType": "CRM",
                                    	"userIdentifierValue": "73.737",
                                    	"userPhone": "+5511999999999",
                                    	"userEmail": "mucapacheco@hotmail.com",
                                    	"userName": "<%=session("nameUser") %>",
                                    	"userId": '<%=session("User") %>'
                                    })
          }).then((response) => {
              return response.json()
          }).then(json => {
              $("#pront").html(`<iframe width="100%" src="${json.body}" frameborder="0" height="1200"></iframe>`);
          })
        }
        </script>
        <div id="Servicos">
            <%
        'if session("banco")="clinic811" or session("banco")="clinic100002" then

            set busca = db.execute("select distinct ii.InvoiceID, i.sysDate, (select count(id) from itensinvoice where InvoiceID=i.id and Executado='S' and Tipo='S') Executados, (select count(id) from itensinvoice where InvoiceID=i.id and Tipo='S') Total from itensinvoice ii LEFT JOIN sys_financialinvoices i on i.id=ii.InvoiceID where (isnull(ii.Executado) OR ii.Executado='' OR ii.Executado='N') and i.AccountID="&PacienteID&" AND i.CD='C' AND Tipo='S' and i.AssociationAccountID=3")
            if not busca.EOF then
                %>
                <div class="alert alert-block alert-default">
                    <button class="close" data-dismiss="alert" type="button"><i class="far fa-remove"></i></button>
                    <p><strong><i class="far fa-exclamation-circle"></i> Atenção! </strong>Existem serviços em aberto para este paciente.</p>
                    <br>

                    <%
                    while not busca.EOF
                        %>
                         <div class="btn-group">
                             <button data-toggle="dropdown" class="btn btn-default btn-xs dropdown-toggle" data-rel="tooltip" data-placement="top" title="Data: <%=busca("sysDate")%>">
                                    <%=busca("Executados")%> executados de <%=busca("Total")%> contratados.
                             </button>
                             <div class="dropdown-menu dropdown-persist w350 animated animated-shorter fadeIn" role="menu">
                               <div class="panel mbn">
                                    <div class="panel-menu">
                                        <%if aut("areceberpacienteV")>0 then%>
                                        <span class="panel-icon" title="Ir para conta"><a href="./?P=invoice&I=<%=busca("InvoiceID")%>&A=&Pers=1&T=C&Ent=" target="_blank"><i class="far fa-external-link text-primary"></i></a></span>
                                        <%end if%>
                                        <span class="panel-title fw600" style="color: #484D61;"> Data: <%=busca("sysDate")%></span>
                                     </div>
                                   <div class="panel-body panel-scroller scroller-navbar pn" style="max-height: 150px !important;">
                                     <div class="tab-content br-n pn">
                                       <div class="tab-pane alerts-widget active" role="tabpanel">
                                           <%
                                           set itens = db.execute("select ii.Executado, ii.DataExecucao, ii.HoraExecucao, ii.ProfissionalID, p.NomeProcedimento, prof.NomeProfissional from itensinvoice ii LEFT JOIN profissionais prof on prof.id=ii.ProfissionalID LEFT JOIN procedimentos p on p.id=ii.ItemID where ii.InvoiceID="&busca("InvoiceID")&" and ii.Tipo='S' order by ii.DataExecucao")
                                           while not itens.eof
                                               if itens("Executado")="S" then
                                                   %>
                                                   <div class="col-xs-12" style="padding-top: 10px; padding-left: 20px; color: #484D61;"><i class="far fa-check text-success"></i> <%=itens("NomeProcedimento")%> - Execução em <%=itens("DataExecucao")%><%if not isnull(itens("HoraExecucao")) then%> às <%=formatdatetime(itens("HoraExecucao"), 4)%><%end if%><%if not isnull(itens("NomeProfissional")) then%> por <%=itens("NomeProfissional")%><%end if%>.</div>
                                                   <%
                                               else
                                                   %>
                                                   <div class="col-xs-12" style="padding-top: 10px; padding-left: 20px; color: #484D61;"><i class="far fa-exclamation-circle text-danger"></i> <%=itens("NomeProcedimento")%> - Não executado.</div>
                                                   <%
                                               end if
                                           itens.movenext
                                           wend
                                           itens.close
                                           set itens=nothing
                                           %>
                                       </div>
                                     </div>
                                   </div>
                               </div>
                             </div>
                           </div>
                        <%
                    busca.movenext
                    wend
                    busca.close
                    set busca=nothing
                    %>
                </div>
                <%
            end if
        'end if
        if req("Debug")="1" then
            response.Write( Omitir )
        end if


            %>
        </div>

        <div id="Dados" class="panel">
        	<div class="panel-body">
            	<div class="col-md-8">
                    <div class="row">
                        <span style="font-size: 9px; width: 8px; position: absolute; left: 50px; min-width: 80px; z-index: 5;top: 5px" ><a href="http://www.buscacep.correios.com.br/sistemas/buscacep/buscaCepEndereco.cfm" target="_blank">Não sei o CEP</a></span>
                        <%= quickField("text", "Cep", "Cep", 3, reg("cep"), "input-mask-cep", "", " autocomplete='cep' ") %>
                        <%= quickField("text", "Endereco", "Endere&ccedil;o", 5, reg("endereco"), "", "", " autocomplete='endereco' ") %>
                        <%= quickField("text", "Numero", "N&uacute;mero", 2, reg("numero"), "", "", "") %>
                        <%= quickField("text", "Complemento", "Compl.", 2, reg("complemento"), "", "", " autocomplete='complemento' ") %>
                    </div>
                    <div class="row">
                        <%= quickField("text", "Bairro", "Bairro", 4, reg("bairro"), "", "", " autocomplete='bairro' ") %>
                        <%= quickField("text", "Cidade", "Cidade", 4, reg("cidade"), "", "", " autocomplete='cidade' ") %>
                        <%= quickField("text", "Estado", "Estado", 2, reg("estado"), "", "", " autocomplete='estado-uf' ") %>
                        <div class="col-md-2<%if instr(Omitir, "|pais|") then%> hidden<%end if%>">
	                        <%= selectInsert("Pa&iacute;s", "Pais", reg("Pais"), "paises", "NomePais", "", "", "") %>
                        </div>
                    </div>
                    <div class="row">
						<%= quickField("phone", "Tel1", "Telefone", 4, reg("tel1"), "", "", " autocomplete='tel1' ") %>
                        <%= quickField("mobile", "Cel1", "Celular", 4, reg("cel1"), "", "", " autocomplete='cel1'  ") %>
                        <%= quickField("email", "Email1", "E-mail", 4, reg("email1"), "", "", " autocomplete='email1' ") %>
                        <%= quickField("phone", "Tel2", "&nbsp;", 4, reg("tel2"), "", "", " autocomplete='tel2'") %>
                        <%= quickField("mobile", "Cel2", "&nbsp;", 4, reg("cel2"), "", "", " autocomplete='cel2' ") %>
                        <%= quickField("email", "Email2", "&nbsp;", 4, reg("email2"), "", "", " autocomplete='email2' ") %>
                    </div><br />
                    <div class="row">
                        <%= quickField("memo", "Observacoes", "Observa&ccedil;&otilde;es", 6, reg("Observacoes"), "", "", "") %>
                        <div class="col-md-6 <%if instr(Omitir, "|pendencias|") then%> hidden<%end if%>">
                        	<div class="checkbox-custom checkbox-warning"><input data-rel="tooltip" title="" data-original-title="Marque para acionar lembrete" type="checkbox" class="tooltip-danger" name="lembrarPendencias" id="lembrarPendencias" value="S"<%if reg("lembrarPendencias")="S" then%> checked="checked"<%end if%> /><label for="lembrarPendencias"> Avisos e Pend&ecirc;ncias</label> <i class="far fa-flag red pull-right"></i></div>
                        	<textarea class="form-control" name="Pendencias" id="Pendencias"><%=reg("Pendencias")%></textarea>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="row">
                        <%= quickField("text", "Profissao", "Profiss&atilde;o", 6, reg("profissao"), "", "", " style='max-height:37px' autocomplete='on' ") %>
                        <%= quickField("simpleSelect", "GrauInstrucao", "Escolaridade", 6, reg("grauinstrucao"), "select * from GrauInstrucao where sysActive=1 order by GrauInstrucao", "GrauInstrucao", "") %>
                        <%= quickField("text", "Documento", "RG", 6, reg("Documento"), "", "", "") %>
                        <%= quickField("text", "Naturalidade", "Naturalidade", 6, reg("Naturalidade"), "", "", " autocomplete='on' ") %>
						<%= quickField("simpleSelect", "EstadoCivil", "Estado Civil", 6, reg("estadocivil"), "select * from EstadoCivil where sysActive=1 order by EstadoCivil", "EstadoCivil", "") %>
                        <%= quickField("simpleSelect", "Origem", "Origem", 6, reg("Origem"), "select * from Origens where sysActive=1 order by Origem", "Origem", " empty") %>
                        <%= quickField("text", "IndicadoPor", "Indica&ccedil;&atilde;o", 6, reg("IndicadoPor"), "", "", " autocomplete='on' ") %>
                        <%= quickField("text", "Religiao", "Religi&atilde;o", 6, reg("Religiao"), "", "", " autocomplete='on' ") %>
                        <%= quickField("text", "CNS", "CNS", 6, reg("CNS"), "", "", "") %>
                        <%= quickField("simpleSelect", "CorPele", "Cor da Pele", 6, reg("CorPele"), "select * from CorPele where sysActive=1", "NomeCorPele", "")%>
                        <%
						set tab = db.execute("select * from TabelaParticular where ativo = 'on' and sysActive=1")
						if tab.EOF then
							%><input type="hidden" name="Tabela" value="0" id="Tabela" /><%
						else
							response.Write(quickField("simpleSelect", "Tabela", "Tabela", 6, reg("Tabela"), "select * from TabelaParticular where ativo = 'on' and sysActive=1", "NomeTabela", ""))
						end if
						%>
                    </div>
                </div>
                <div class="col-md-8 hidden">
                    <div class="row">
                        <%= quickField("text", "Endereco2", "Endereço 2", 4, reg("Endereco2"), "", "", "  ") %>
                        <%= quickField("text", "Numero2", "Número 2", 2, reg("Numero2"), "", "", "") %>
                        <%= quickField("text", "Complemento2", "Complemento 2", 3, reg("Complemento2"), "", "", " ") %>
                        <%= quickField("text", "Bairro2", "Bairro 2", 3, reg("Bairro2"), "", "", " ") %>

                    </div>
                </div>
            </div>
          </div>
          <div id="pacientesDadosComplementares">
            <% server.execute("pacientesDadosComplementares.asp")%>
          </div>
          <div class="row">
                <div class="col-xs-12">
            	    <!--#include file="PacientesConvenio.asp"-->
                </div>
            </div>
            <div class="row">
            	<div class="col-md-6<%if instr(Omitir, "|programação de agendamentos (retornos)|") then%> hidden<%end if%>">
					<%call Subform("PacientesRetornos", "PacienteID", PacienteID,"frm")%>
                </div>
            	<div class="col-md-6<%if instr(Omitir, "|pessoas relacionadas e parentes|") then%> hidden<%end if%>">
					<%call Subform("PacientesRelativos", "PacienteID", PacienteID, "frm")%>
                </div>
            </div>
            <div class="row">
                <div id="block-programas-saude" class="col-md-6"></div>
                <div id="block-care-team" class="col-md-6"></div>
            </div>

            <div class="panel" id="dCad">
                <div class="panel-body">
                    <div class="row col-xs-6">
                        Cadastrado
                        <%
                        set usuario = db.execute("select pac.id, u.*, p.NomeProfissional, f.NomeFuncionario from pacientes as pac left join sys_users as u on u.id=pac.sysUser left join profissionais as p on p.id=u.idInTable left join funcionarios as f on f.id=u.idInTable where pac.id="&reg("id"))
                        if not usuario.eof then
	                        if lcase(usuario("Table"))="profissionais" then
		                        NomeUsuario = usuario("NomeProfissional")
	                        else
		                        NomeUsuario = usuario("NomeFuncionario")
	                        end if
	                        if not isnull(NomeUsuario) then
		                        %>
		                         por <%=NomeUsuario%>
		                        <%
	                        end if
                        end if
                        %>
                        em <%=reg("sysDate")%>
                        <%
                        if reg("UnidadeID")<>"" or not isnull(reg("UnidadeID")) then
                            set units = db.execute("SELECT id,NomeFantasia FROM (SELECT 0 id, NomeFantasia FROM empresa UNION ALL SELECT id, NomeFantasia FROM sys_financialcompanyunits WHERE sysActive=1)t WHERE id ="&reg("UnidadeID"))
                            if not units.eof then
                                NomeUnidade = units("NomeFantasia")
                                response.write(" na "&NomeUnidade&".")
                            end if
                        end if

                        %>



                    </div>

                    <div class="col-md-3">
                        <%
                        if session("Banco")="clinic5968" then
                            call quickfield("simpleSelect", "PFPJ", "PF/PJ", 12, reg("PFPJ"), "select '1' id, 'PF' Tipo UNION ALL select '2', 'PJ'", "Tipo", " no-select2 semVazio ")
                        end if
                        %>
                    </div>


                    <%
                    if session("SepararPacientes") and aut("delacpacsA") then
                        Profissionais = reg("Profissionais")
                        %>
                        <%= quickfield("multiple", "Profissionais", "Profissionais", 3, Profissionais, "select 'ALL' id, '    TODOS' NomeProfissional UNION ALL select id, NomeProfissional from profissionais where ativo='on' order by NomeProfissional", "NomeProfissional", "") %>
                        <%
                    end if

                    if isnull(reg("UnidadeID")) or reg("UnidadeID")="" then
                        UnidadeID=session("UnidadeID")
                    else
                        UnidadeID=reg("UnidadeID")
                    end if

                    if UnidadeID&""="" then
                        UnidadeID=0
                    end if
                    %>
                        <input type="hidden" id="UnidadeID" name="UnidadeID" value="<%= UnidadeID %>" />

                </div>
            </div>
</form>


<div id="permissaoTabela" class="modal fade" role="dialog">
  <div class="modal-dialog">

    <!-- Modal content-->
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal">&times;</button>
        <h4 class="modal-title">Permissão para uso de Tabela</h4>
      </div>
      <div class="modal-body">
        <div class="col-md-4">
            <p>Selecione um usuário abaixo que tenha  permissão:</p>      
              
        </div>        
            <div class="col-md-6">
                <label style="" class="error_msg"></label><br>
                <label>Senha do Usuário</label>
                <input type="hidden" id="tabela-password" name="tabela-password" class="form-control">
            </div>

        <div class="col-md-12 tabelaParticular" style="color:#000;">
        
             
        </div>
        </div>
       
        <div class="modal-footer" style="margin-top:13em;">
                <button type="button" class="btn btn-default fechar" data-dismiss="modal" >Fechar</button>
                <button type="button" class="btn btn-info confirmar"    >Confirmar</button>
       
         </div>

  </div>
</div>
</div>
<script type="text/javascript">
    function modalPaciente(ID) {
        $("#modal-table").modal("show");
        $("#modal").html(`<div class="p10"><button type="button" class="close" data-dismiss="modal">×</button><center><i class="far fa-2x fa-circle-o-notch fa-spin"></i></center></div>`)
        $.post("modalPacientes.asp?I="+ID, "", function (data) { $("#modal").html(data) });
        $("#modal").addClass("modal-lg");
     }

     function modalPacienteRelativo(ID, Nome) {
         $("#modal-table").modal("show");
         $("#modal").html(`<div class="p10"><button type="button" class="close" data-dismiss="modal">×</button><center><i class="far fa-2x fa-circle-o-notch fa-spin"></i></center></div>`)
         $.post("modalPacientesRelativo.asp?I="+ID+"&Nome="+Nome, "", function (data) { $("#modal").html(data) });
         $("#modal").addClass("modal-lg");
      }


    $("#Profissionais").change(function () {
        $.post("delegaPaciente.asp?PacienteID=<%= PacienteID %>", $(this).serialize(), function (data) { eval(data); });
    });


    <%
    if req("Ct")="1" then
    %>
    $(document).ready(function(){
        $("#tabExtrato").click();
    })
    <%
    end if
    %>

$("#Ativo").click(function(){
    var Ativo = $(this).prop("checked");
    if(Ativo==false){
        $("#modal-table").modal("show");
        $.post("pacienteInativa.asp", {sysActive:-1, I:<%=PacienteID %>}, function(data){ $("#modal").html(data) });
    }else{
        $.post("pacienteInativa.asp", {sysActive:1, I:<%=PacienteID %>}, function(data){ $("#modal").html(data) });
    }
});

<%
if reg("sysActive") = 1 and lcase(session("Table"))="profissionais" and getConfig("FormularioNaTimeline") then
        %>
        $(document).ready(function () {
            $("#abaTimeline").click();
        });
    <%
end if
%>


<!--#include file="JQueryFunctions.asp"-->


<%
if reg("sysActive")<0 then
    %>
    $("#Ativo").prop("checked", false);
    <%
        end if
%>


<%
if reg("sysActive")=1 then
    %>
	comparaPaciente('Conta');
	<%
end if
%>
function comparaPaciente(T) {
		$.post("ComparaPacientes.asp?T=" + T, { I: <%= PacienteID %>, No: $("#NomePaciente").val(), Email: $("#Email1").val(), Documento: $("#Documento").val(), Na: $("#Nascimento").val(), C: $("#CPF").val(), S: $("#Sexo").val() }, function (data) {
			if (T == 'Conta') {
				eval(data);
			} else {
				$("#modal").html(`<div class="p10"><button type="button" class="close" data-dismiss="modal">×</button><center><i class="far fa-2x fa-circle-o-notch fa-spin"></i></center></div>`)
				$("#modal-table").modal("show");
				$("#modal").html(data);
			}

		});
	}

$("#NomePaciente, #Nascimento, #CPF").change(function () {
    comparaPaciente('Conta');
});




function mesclar(p1, p2){
	if(confirm('ATENÇÃO: Esta ação unirá as informações das duas fichas em uma só. \n Confirme apenas se os dois cadastros forem de um mesmo paciente.')){
		//window.open("mesclar.asp?p1="+p1+"&p2="+p2);
		location.href="mesclar.asp?p1="+p1+"&p2="+p2;
	}
}

<% if PacienteID <> "" and (getConfig("ExibirProgramasDeSaude") = 1 or getConfig("ExibirCareTeam") = 1) then %>
// Chamada Ajax Programa Saúde e Care Team
$(document).ready(function () {

    <% if getConfig("ExibirProgramasDeSaude") = 1 then %>
        $("#block-programas-saude").show().html('<div style="width: 100%; text-align: center"><i style="margin: 30px 0" class="far fa-spin fa-spinner"></i></div>');
        function loadProgramasSaude() {
            getUrl("health-programs/patient-view/<%=PacienteID %>", {}, function(data) {
                $("#block-programas-saude").html(data);
            });
        }
        loadProgramasSaude();

        // recarrega o box de programas de saúde ao clicar no salvar
        // para atualizar a regra de programa atrelado ao convênio do paciente
        $('#Salvar').on('click', function() {
            if ($("#block-programas-saude").length) {
                loadProgramasSaude();
            }
        });
    <% else %>
        $("#block-programas-saude").hide();
    <% end if %>

    <% if getConfig("ExibirCareTeam") = 1 and aut("timedecuidadoV") then %>
        $("#block-care-team").show().html('<div style="width: 100%; text-align: center"><i style="margin: 30px 0" class="far fa-spin fa-spinner"></i></div>');
        getUrl("care-team/view/<%=PacienteID %>", {}, function(data) {
            $("#block-care-team").html(data);
        });
    <% else %>
        $("#block-care-team").hide();
    <% end if %>

});
<% end if %>

</script>
<%
if getConfig("LembreteFormulario")=1 then
    set lembrarme = db.execute("select * from buiformslembrarme where PacienteID="&PacienteID)
    if not lembrarme.EOF then
        %>
        <script type="text/javascript">
        $( document ).ready(function() {
        <%
        while not lembrarme.EOF
            Valor = ""
            set Campo = db.execute("select * from buicamposforms where id="&lembrarme("CampoID"))
            if not Campo.EOF then
                set Registro = db.execute("select * from `_"&lembrarme("ModeloID")&"` where id="&lembrarme("FormID"))
                if not Registro.EOF then
                    if Campo("TipoCampoID")=4 then
                        ValoresChecados = Registro(""&Campo("id")&"")
                        splValoresChecados = split(trim(ValoresChecados&" "), ".")
                        for i=0 to ubound(splValoresChecados)
                            if isnumeric(splValoresChecados(i)) and splValoresChecados(i)<>"" then
                                set pVal = db.execute("select * from buiopcoescampos where id = '"&splValoresChecados(i)&"'")
                                if not pVal.EOF then
                                    Valor = Valor&pVal("Nome")&"<br />"
                                end if
                            end if
                        next
                    elseif Campo("TipoCampoID")=5 or Campo("TipoCampoID")=6 then
                        RegistroValor = Registro(""&Campo("id")&"")
                        set ValOp = db.execute("select * from buiopcoescampos where id = '"&replace(valor , "|", "")&"'")
                        if not ValOp.eof then
                            Valor = ValOp("Nome")
                        end if
                    elseif Campo("TipoCampoID")=1 or Campo("TipoCampoID")=8 then
                        Valor = Registro(""&Campo("id")&"")
                    end if
                    %>
                    new PNotify({
                            title: "<%=Campo("RotuloCampo")%>",
                            text: `<%=Valor%>`,
                            sticky: true,
                            type: 'alert',
                            delay: 5000
                        });
                    <%
                end if
            end if
        lembrarme.movenext
        wend
        lembrarme.close
        set lembrarme = nothing
        %>
            });
        </script>
        <%
    end if
end if
if getConfig("AvisosPendenciasProntuario")=1 and instr(Omitir, "|pendencias|")=0 then
    if reg("lembrarPendencias")="S" then
    %>
    <script type="text/javascript">
    $( document ).ready(function() {
        new PNotify({
                title: 'AVISOS E PEND&Ecirc;NCIAS',
                text: $("#Pendencias").val(),
                sticky: true,
                type: 'warning',
                delay: 5000
            });

    });
    </script>
    <%
    end if
end if




if not isnull(reg("Validade1")) then
    if reg("Validade1")<date() then
        %>
<script type="text/javascript">
$( document ).ready(function() {
new PNotify({
	    title: 'CORRIJA OS PROBLEMAS',
	    text: 'A data da carteirinha do convênio está vencida.',
	    type: 'danger',
        delay: 5000
	});
    return false;
});
</script>
    <%
    end if
end if


if not isnull(reg("Nascimento")) and isdate(reg("Nascimento")) then
    if month(reg("Nascimento"))=month(date()) and day(reg("Nascimento"))=day(date()) and idade(reg("Nascimento"))<> "Nascido hoje" then
        txt = "Hoje o paciente completa "&idade(reg("Nascimento"))&"."
        %>
<script type="text/javascript">
$( document ).ready(function() {
new PNotify({
	    icon: 'far fa-birthday-cake',
	    title: 'ANIVERS&Aacute;RIO DO PACIENTE',
	    text: '<%=txt%>',
	    type: 'info',
        delay: 5000
	});
    return false;
});
</script>
    <%
    end if
end if
%>
<input type="hidden" id="PacienteID" value="<%=PacienteID %>" />

<br />
<div class="table-layout" id="pront"></div>
<script>
$(function(){
    $("#Pais").on('change', function(){
        var data = $('#Pais').select2('data');
        var nomePais = data[0].full_name;

        //changeEstrangeiro()
        if(nomePais != "" && nomePais != "Brasil"){
            //$("#CPF").prop("required", false);
        }else{
            toRequired()
        }
    });
});


$(function () {
  $('[data-toggle="tooltip"]').tooltip();
  setTimeout(() => {
    if(!$("#Foto").is(':focusable')){
      $("#Foto").prop("required", false);
    }
  }, 650);
})




var idStr = "#Tabela";
$('.modal').click(function(){
    $('#select2-Tabela-container').text("Selecione");
    $('#Tabela').val(0);
    $('.error_msg').empty();
});


$(idStr).change(function(){    
        var id          = $('#Tabela').val();
        var sysUser     = "<%=session("user") %>";
        var Nometable   = $('#Tabela :selected').text();
        var regra       =  "|tabelaParticular12V|";
        $.ajax({
        method: "POST",
        url: "TabelaAutorization.asp",
        data: {autorization:"buscartabela",id:id,sysUser:sysUser},
        success:function(result){
            if(result == "Tem regra"){
                $("#permissao-password").attr("type","password");
                $('#permissaoTabela').modal('show');
                buscarNome(id,sysUser,regra);
                }
        }
});
    $('.confirmar').click(function(){
            var Usuario =  $('input[name="nome"]:checked').val();
            var senha   =  $('#permissao-password').val();
            liberar(Usuario , senha , id , Nometable);
            $('.error_msg').empty(); 
        });
});



function buscarNome(id , user,regra){
    $.ajax({
        method: "POST",
        ContentType:"text/html",
        url: "TabelaAutorization.asp",
        data: {autorization:"pegarUsuariosQueTempermissoes",id:id,LicencaID:user,regra:regra},
        success:function(result){
            res = result.split('|');     
                $('.tabelaParticular').html(result);
        }
    });
}

function liberar(Usuario , senha , id, Nometable){
    $.ajax({
    method: "POST",
    url: "SenhaDeAdministradorValida.asp",
    data: {autorization:"liberar",id:id ,U:Usuario , S:senha},
    success:function(result){      
            if( result == "1" ){
                    $('.error_msg').text("Logado Com Sucesso!").fadeIn().css({color:"green" });;
                setTimeout(() => {
                    $('#permissaoTabela').modal('hide');
                    $('#Tabela').val(id);                   
                    $('#select2-Tabela-container').text(Nometable);
                }, 2000);
                }else{
                    $('.error_msg').text("Senha incorreta!").css({color:"red" }).fadeIn();
                    $('#select2-Tabela-container').text("Selecione");
                    $('#Tabela').val(0);
                }
            }
        });
    }



</script>