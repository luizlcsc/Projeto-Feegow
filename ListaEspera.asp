<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->

<br />
        <%
        if session("Atendimentos")&""="" then
            session("Atendimentos")=""
        end if

                if aut("|esperaoutrosprofissionaisV|")=1 then
                    %>
<div class="panel">

    <div class="panel-body">

        <div class="row">
            <div class="col-md-4">
            <label for="ProfissionalID">Filtrar por profissional</label>
            <select name="ProfissionalID" id="ProfissionalID" class="form-control select2-single">
                <option value="">Selecione</option>
                <%

            sqlunidades  = "select Unidades from " & session("table") &" where id = " & session("idInTable")
            set UnidadesUser  = db.execute(sqlunidades)
            UnidadesUser = replace(UnidadesUser("Unidades"), "|", "")
            lista = split(UnidadesUser, ",")
            sqlOR = ""
            for z=0 to ubound(lista)
                sqlOR = sqlOR & " or prof.unidades like '%|"& replace(lista(z), " ","") &"|%' "
                'response.write ("<script> console.log('"&lista(z)&"');</script>")
            next
            sqlOR = " AND (false " & sqlOR & ") "
            sql = " SELECT und.NomeFantasia, prof.id, prof.unidades, LEFT(prof.NomeProfissional, 20)NomeProfissional, prof.NomeSocial, prof.Cor, prof.Ativo " &_
                  " FROM Profissionais prof " &_
                  " INNER JOIN agendamentos age ON age.ProfissionalID=prof.id " &_
                  " LEFT JOIN locais l ON l.id=age.LocalID " &_
                  " LEFT JOIN (select un.id, un.NomeFantasia from sys_financialcompanyunits un where un.sysActive=1 UNION ALL select '0', e.NomeFantasia from empresa e) und ON und.id=l.UnidadeID" &_
                  " WHERE (prof.NaoExibirAgenda != 'S' OR prof.NaoExibirAgenda is null OR prof.NaoExibirAgenda='') " &_
                  " AND prof.sysActive=1 and age.Data=curdate() " &_
                  " " &  sqlOR &_
                  " GROUP BY prof.id order by und.NomeFantasia ASC, prof.NomeProfissional "

            set Prof = db.execute(sql)


            UnidadeAtual = ""
            UltimaUnidade = "0"
            TemOptgroup = False
            while not Prof.EOF
                UnidadeAtual = Prof("NomeFantasia")
                if lcase(session("table"))="profissionais" and session("idInTable")=Prof("id") then
                    selected = " selected=""selected"""
                else
                    if session("UltimaAgenda")=cstr(Prof("id")) then
                        selected = " selected=""selected"""
                    else
                        selected = ""
                    end if
                end if

                NomeProfissional = Prof("NomeProfissional")
                unidadesprof = Prof("unidades")
                if Prof("NomeSocial")&"" <> "" then
                     NomeProfissional=Prof("NomeSocial")
                end if
                if UnidadeAtual&""<>UltimaUnidade&"" then
                    if TemOptgroup then
                        %>
                        </optgroup>
                        <%
                    end if
                    TemOptgroup=True
                    %>
                    <optgroup label="<%=UnidadeAtual%>">
                    <%
                end if


                %>
                <option <%=selected%> style="border-left: <%=Prof("Cor")%> 10px solid; background-color: #fff;" value="<%=Prof("id")%>"><%=ucase(NomeProfissional)%></option>
                <%
                UltimaUnidade=UnidadeAtual
            Prof.movenext
            wend
            Prof.close
            set Prof = nothing


                %>
            </select>

            </div>
        </div>
    </div>
</div>
                    <%
                end if
                %>

<div class="panel">

    <div class="panel-body" id="listaespera">
        <% server.Execute("ListaEsperaCont.asp") %>
    </div>
</div>
<script type="text/javascript">

<%
if lcase(session("table"))="profissionais" then
    getEspera(session("idInTable") &", ")
end if

OrdensNome="Hor&aacute;rio Agendado, Hor&aacute;rio de Chegada, Idade do paciente"
Ordens="Hora, HoraSta, pac.Nascimento"
splOrdensNome=split(OrdensNome, ", ")
splOrdens=split(Ordens, ", ")
	if req("Ordem")<>"" then
		db_execute("update sys_users set OrdemListaEspera='"&req("Ordem")&"' where id="&session("User"))
	end if
	set pUsu=db.execute("select * from sys_users where id="&session("User"))
	if isNull(pUsu("OrdemListaEspera")) then
		if session("Table")<>"profissionais" then
			Ordem="HoraSta"
		else
			Ordem="Hora"
		end if
	else
	    on error resume next
		Ordem=pUsu("OrdemListaEspera")
		On Error GoTo 0

	end if
%>

$(".crumb-active a").html("Sala de Espera");
$(".crumb-icon a span").attr("class", "fa fa-clock-o");
$(".crumb-link").html("pacientes aguardando");
$(".crumb-link").removeClass("hidden");
var selectsTop = '<select name="StatusExibir" class="mr10" onChange="location.href=\'./?P=ListaEspera&Pers=1&StatusExibir=\'+this.value;"> <option <%if req("StatusExibir")="4" then%> selected="selected" <%end if%> value="4">Aguardando</option><option <%if req("StatusExibir")="3" then%> selected="selected" <%end if%> value="3">Atendido</option></select>';
selectsTop += 'Ordenar por              <select name="Ordem" onChange="location.href=\'./?P=ListaEspera&Pers=1&Ordem=\'+this.value;">              <%
                               for i=0 to ubound(splOrdensNome)
                               %>                <option value="<%=splOrdens(i)%>"<%if Ordem=splOrdens(i) then%> selected="selected"<%end if%>><%=splOrdensNome(i)%></option>              <%
                               next
                               %>              </select>';


$("#rbtns").html(selectsTop)

              setInterval(function(){
                  atualizaLista();
              }, 17000);

$("#ProfissionalID").change(function() {
    atualizaLista();
});

function atualizaLista(){
      var ProfissionalID = $("#ProfissionalID").val();
      if(!ProfissionalID){
          ProfissionalID="";
      }

      $.get("ListaEsperaCont.asp?Ordem=<%=req("Ordem")%>&StatusExibir=<%=req("StatusExibir")%>&ProfissionalID="+ProfissionalID, function(data){
          $("#listaespera").html(data);
      });
}
//recurso para clinica do SHopping
    $("#listaespera").on("click",".btn-enviar-sms-espera", function() {
        var $btn = $(this),
            phone = $btn.attr("data-phone"),
            name = $btn.attr("data-name"),
            id = $btn.attr("data-id"),
            $text = $btn.find(".btn-text");

        $btn.attr("disabled",true);
        $text.text("ENVIADO");

        var path = "../";
        $.get(path+"feegow_components/api/SalaEspera/enviaSMS", {id:id,b:'<%=session("Banco")%>',recipientNumber:phone,name:name},  function(data){
            console.log('Enviado...');
        });
    });

    $(".AlterarLocalAtual").click(function() {
        $.get("AlteraLocalAtendimentoAtual.asp", function(data) {
            $("#modal").html(data);
            $("#modal-table").modal('show');
        });
    });
</script>