<!--#include file="connect.asp"-->
<%
CallID = req("CallID")
Telefone = req("T")'E-mail ou telefone da interação
Contato = req("C")
RE = req("RE")


if CallID="0" then
    db_execute("insert into chamadas ( StaID, sysUserAtend, DataHoraAtend, RE, Telefone, Contato ) values ( 1, "& session("User") &", now(), "& RE &", '"& Telefone &"', '"& Contato &"' )")
    set pult = db.execute("select id from chamadas where sysUserAtend="&session("User")&" order by id desc LIMIT 1")
    CallID = pult("id")
end if

if req("Vincula")<>"" then
    db_execute("update chamadas set Contato='"&replace(req("Vincula"), "select-ContatoID", "")&"' where id="&CallID)
end if

if CallID<>"V" then
    set detCall = db.execute("select ch.*, ca.NomeCanal from chamadas ch left join chamadascanais ca on ca.id=ch.RE where ch.id="&CallID)
    Contato = detCall("Contato")
    sysUser = session("User")
    ConstatusID = 1
    Telefone = detCall("Telefone")
    RE = detCall("RE")
end if
if instr(Contato, "_") then
	spl = split(Contato, "_")
	set ass = db.execute("select `table`, `column` from cliniccentral.sys_financialaccountsassociation WHERE id="&spl(0))
	set reg = db.execute("select * FROM "&ass("table")&" where id="&spl(1))
	if not reg.eof then
        PacienteID = reg("id")
		Tel1 = reg("Tel1")
		Tel2 = reg("Tel2")
		Cel1 = reg("Cel1")
		Cel2 = reg("Cel2")
		Email1 = reg("Email1")
		Email2 = reg("Email2")
        if spl(0)="3" then
    		Origem = reg("Origem")
        end if
        Interesses = reg("Interesses")
        sysUser = reg("sysUser")
        sysActive = reg("sysActive")
        ConstatusID = reg("ConstatusID")
		if spl(0)=3 then
			Observacoes = reg("Observacoes")
		else
			Observacoes = reg("Obs")
		end if
	end if
end if
%>


<div class="panel">
    <div class="panel-heading">
        <span class="panel-title"><span class="glyphicon glyphicon-hand-down"></span>
            <% if CallID="V" then %>
                Detalhes do Contato <small>&raquo; <%=Telefone%></small>
            <% else %>
                Protocolo: <%=detCall("id") %>
            <% end if %>
        </span>
    </div>
    <div class="panel-body ligacao">
        <ul class="nav nav-pills mb20" id="myTab<%=CallID %>">
            <li class="active">
                <a data-toggle="tab" class="mainTab" href="#Chamada<%=CallID%>">
                    <i class="blue far fa-user bigger-110"></i>
                    <span class="hidden-480">Principal </span>
                </a>
            </li>
            <li><a data-toggle="tab" id="tabHistorico<%=CallID%>" href="#Historico<%=CallID%>">Histórico de Contatos</a></li>
            <li><a data-toggle="tab" id="tabProposta<%=CallID%>" href="#divPropostas<%=CallID%>" onclick="ajxContent('ListaPropostas&CallID=<%=CallID%>&PacienteID='+$('#ContatoID<%=CallID %>').val().replace('3_', ''), '', '1', 'divPropostas<%=CallID%>')">Propostas</a></li>
            <li><a data-toggle="tab" id="tabConta<%=CallID%>" href="#divConta<%=CallID%>" onclick="ajxContent('Conta', $('#ContatoID<%=CallID %>').val().replace('3_', ''), '1', 'divConta<%=CallID%>')">Itens Contratados</a></li>
	    </ul>
        <%
        function aplicaTel(campo, val)
    '        if val="" or isnull(val) then
                aptel = Telefone
                if len(aptel)=10 then
                    aptel = "("& left(aptel, 2) &") "& mid(aptel, 3, 4) &"-"& right(aptel,4)
                elseif len(aptel)=11 then
                    aptel = "("& left(aptel, 2) &") "& mid(aptel, 3, 4) &"-"& right(aptel,5)
                end if
                aplicatel = " &nbsp;&nbsp;<button type='button' class='btn btn-xs btn-default aplicaTel' style='position:absolute' onclick=""$('#"& campo &"').val('"& aptel &"'); $('.aplicaTel').fadeOut(); salvaDados();""><i class='far fa-hand-o-down'></i></button>"
        '       end if
        end function
        %>

        <div class="tab-content">
            <div id="Chamada<%=CallID%>" class="tab-pane in active">
                        <div class="row">
                            <div class="col-sm-4" id="dadosContato">
                                <div class="col-md-8">
                                    <label>Contato</label><br />
                                    <%=selectInsertCA("", "ContatoID"&CallID, Contato, "3", " onchange=""contatoParametros( $(this).attr(`data-valor`) );""", " required", "")%>
                                </div>
                                <%= quickField("simpleSelect", "ConstatusID_"&CallID, "<i class='far fa-exclamation-triangle orange'></i> Status", 4, ConstatusID, "select * from chamadasconstatus", "NomeStatus", " no-select2 ") %>
                                <div class="col-md-12">
                                    <%=fSysActive("sysActive_"&CallID, sysActive, "$('#ContatoID"&CallID&"').val()") %>
                                </div>
                                <%= quickField("simpleSelect", "Origem_"&CallID, "Origem", 6, Origem, "select * from origens where sysActive=1 order by Origem", "Origem", " no-select2 ") %>
                                <%= quickField("users", "sysUser_"&CallID, "Responsável", 6, sysUser, "", "", "") %>


                                <%= quickField("phone", "Tel1_"&CallID, "Telefone 1" & aplicaTel("Tel1_"&CallID, tel1), 6, tel1, " dadosContato", "", "") %>
                                
                                <%= quickField("phone", "Tel2_"&CallID, "Telefone 2" & aplicaTel("Tel2_"&CallID, tel2), 6, tel2, " dadosContato", "", "") %>
                                <%= quickField("mobile", "Cel1_"&CallID, "Celular 1" & aplicaTel("Cel1_"&CallID, cel1), 6, cel1, " dadosContato", "", "") %>
                                <%= quickField("mobile", "Cel2_"&CallID, "Celular 2" & aplicaTel("Cel2_"&CallID, cel2), 6, cel2, " dadosContato", "", "") %>
                                <%= quickField("email", "Email1_"&CallID, "E-mail 1", 12, email1, " dadosContato", "", "") %>
                                <%= quickField("email", "Email2_"&CallID, "E-mail 2", 12, email2, " dadosContato", "", "") %>
                                <%= quickField("memo", "Observacoes_"&CallID, "Observações da pessoa", 12, observacoes, " dadosContato", "", "") %>
                                <%= quickField("multiple", "Interesses_"&CallID, "Interesses", 12, interesses, "select id, NomeProcedimento from procedimentos where TipoProcedimentoID in(1, 3, 4) and sysActive=1 order by NomeProcedimento", "NomeProcedimento", "") %>
                            </div>
                            <% if CallID<>"V" then %>
                            <div class="col-sm-4" id="divresult<%=CallID%>">
                                <h4><%=ucase(detCall("NomeCanal")) %></h4>
                                <div class="row">
                                <%
                                set result = db.execute("select * from chamadasresultados where RE like '%|"&detCall("RE")&"|%' AND Pai=0")
                                while not result.eof
                                    %>
                                    <label><input class="ace campores" name="result" value="<%=result("id")%>" required value="<%=result("id")%>" type="radio" onClick="$('.sub').slideUp('fast'); $('#sub<%=result("id")%>').slideDown('slow'); $('.scriptRE').fadeOut(); $('#script<%=result("id")%>').fadeIn();"<%
                                    if detCall("Resultado")=result("id") then
                                        %> checked<%
                                    end if
                                    %>> <span class="lbl"> <%=result("Descricao")%></span></label><br>
                                    <div class="sub" id="sub<%=result("id")%>" style="padding-left:25px;<%if detCall("Resultado")<>result("id") or isnull(detCall("Resultado")) then%> display:none<%end if%>">
                                        <select class="form-control campores" name="subresult<%=result("id")%>" id="result<%=detcall("id")%>" onchange="$('.scriptRE').fadeOut(); $('#script'+$(this).val()).fadeIn();">
                                            <option value="0">Selecione</option>
                                    <%
                                    set subresult = db.execute("select * from chamadasresultados where Pai="&result("id")&" and RE like '%|"&detCall("RE")&"|%'")
                                    while not subresult.eof
                                        %>
                                        <option value="<%=subresult("id")%>" <%
                                        if detCall("Subresultado")=subresult("id") then
                                            %> selected<%
                                        end if
                                        %>> <%=subresult("Descricao")%></option>
                                        <%
                                    subresult.movenext
                                    wend
                                    subresult.close
                                    set subresult=nothing
                                    %>
                                            </select>
                                    </div>
                                    <%
                                result.movenext
                                wend
                                result.close
                                set result=nothing
                                %>
                                <%= quickField("memo", "Notas"&CallID, "Notas desta chamada", 12, detCall("Notas"), " campores", "", "") %>
                        </div>
                                <hr>
                                <div class="row">
                                    <div class="col-md-12">
                                        <label><input type="checkbox" id="Religar<%=CallID %>" data-religar="<%=CallID %>" class="ace Religar" value="1" /><span class="lbl"> Follow Up</span></label>
                                    </div>
                                </div>
                                <div class="row" style="display:none" id="divReligar<%=CallID %>">
                                    <%=quickfield("datepicker", "DataReligar"&CallID, "Data", 6, date(), "input-mask-date", "", "") %>
                                    <%=quickfield("timepicker", "HoraReligar"&CallID, "Hora", 6, dateadd("n", 30, time()), "", "", "") %>
                                </div>

                    
                                    <hr>
                                <div class="row">
                                    <div class="col-xs-6">
                                        <button type="button" onClick="location.href='./?P=Agenda-1&Pers=1';" class="btn btn-info btn-block" title="Agendar"><i class="far fa-calendar"></i> Agendar</button>
                                    </div>
                                    <div class="col-xs-6">
                                        <button type="button" class="btn btn-primary btn-block" title="Finalizar" onClick="finaliza(<%=CallID%>)"><i class="far fa-stop"></i> Finalizar</button>
                                    </div>
                                </div>
                                <br />
                                <div class="row">
                                    <div class="col-xs-6">
                                        <button type="button" class="btn btn-info btn-block" title="Abrir Tíquete" onclick="location.href='./?P=Tarefas&Pers=1&I=N&Solicitantes='+$('#ContatoID<%=CallID %>').val();"><i class="far fa-ticket"></i> Tíquete</button>
                                    </div>
                                    <div class="col-xs-6">
                                        <button type="button" class="btn btn-info btn-block hidden" title="Transferir"><i class="far fa-exchange"></i> Transferir</button>
                                    </div>
                                </div>
                            </div>
                            <% end if %>
                            <div class="col-sm-4" id="textoscript">
                                <%
                                set scripts = db.execute("select * from chamadasresultados where RE like '%|"& RE &"|%'")
                                while not scripts.eof
                                    %>
                                    <div id="script<%=scripts("id") %>" class="scriptRE" style="display:none">
                                        <%= scripts("Script") %>
                                    </div>
                                    <%
                                scripts.movenext
                                wend
                                scripts.close
                                set scripts = nothing
                                %>
                            </div>
                        
                        </div>
		    </div>
            <div id="Historico<%=CallID%>" class="tab-pane">Carregando histórico...</div>
            <div id="divPropostas<%=CallID%>" style="overflow-y:scroll; overflow-x:hidden; height:500px" class="tab-pane">Carregando propostas...</div>
            <div id="divConta<%=CallID%>" class="tab-pane"></div>
        </div>
    </div>
</div>
<script>
$(".dadosContato, select[name^=Origem], select[name^=ConstatusID], select[name^=Interesses], select[name^=sysUser]").change(function(){
	salvaDados();
});

function salvaDados(){
    $.post("chaSalvaDadosContato.asp?CallID=<%=CallID%>", $(".dadosContato, #ContatoID<%=CallID %>, select[name^=Origem], select[name^=ConstatusID], select[name^=Interesses], select[name^=sysUser]").serialize(), function(data){ eval(data) });
}

$("#divresult<%=CallID%> .campores").change(function(){
	$.post("chaSalvaResultadoContato.asp?CallID=<%=CallID%>", $("#divresult<%=CallID%> .campores").serialize(), function(data){ eval(data) });
});
function finaliza(CallID){
	callSta(CallID, 2);
	$("#detalheLigacao"+CallID+", #linhaLigacao"+CallID).css("display", "none");
    if( $("#Religar"+CallID).prop("checked")==true && $("#DataReligar"+CallID).val()!="" && $("#HoraReligar"+CallID).val()!=""){
        $.post("saveReligar.asp?ContatoID="+$("#ContatoID<%=CallID %>").val(), {
            DataReligar:$("#DataReligar"+CallID).val(),
            HoraReligar:$("#HoraReligar"+CallID).val(),
            CallID:<%=CallID %>
        }, function(data){ eval(data) });
    }
}
$("#tabHistorico<%=CallID%>").click(function(){
	$.get("chamadasHistorico.asp?Contato="+$("#ContatoID<%=CallID %>").val(), function(data){ $("#Historico<%=CallID%>").html(data) });
});

$(".Religar").click(function(){
    if( $(this).prop("checked")==true ){
        $("#divReligar<%=CallID %>").fadeIn();
    }else{
        $("#divReligar<%=CallID %>").fadeOut();
    }
});

function contatoParametros(ContatoID){
    $.get("detalheLigacao.asp?CallID=<%=CallID %>&Vincula="+ContatoID, function(data){$("#detalheLigacao<%=CallID %>").html(data)});
}

<!--#include file="JQueryFunctions.asp"-->
</script>