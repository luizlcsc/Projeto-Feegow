<!--#include file="connect.asp"-->
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" href="//code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css">
  <style>
  .connectedSortable {
 #   border: 1px solid #999;
    width: 222px;
    min-height: 20px;
    list-style-type: none;
    margin: 0;
    padding: 5px 0 0 0;
    float: left;
    margin-right: 10px;
  }
  .connectedSortable li {
    margin: 0 5px 5px 5px;
    padding: 5px;
    font-size: 11px;
    width: 211px;
    border-radius: 8px;
    border: 1px solid #ddd;
  }








.ui-draggable, .ui-droppable {
	background-position: top;
}  </style>
  <script type="text/javascript">
  $( function() {
    $( ".connectedSortable" ).sortable({
      connectWith: ".connectedSortable"
    });
  } );



/*
$(".connectedSortable li").mousedown(function(){
      console.log( $(this).attr("id") );
      });

$(".connectedSortable li").mouseup(function(){
      console.log( $(this).closest("ul").attr("id") );
      });
      */
$(".connectedSortable").bind('sortreceive', function(event, ui) {
      Destino = this.id; // Where the item is dropped
      Origem = ui.sender[0].id; // Where it came from
      Elemento = ui.item[0].id; // Which item
    $.post("funilMove.asp", {Destino: Destino, Origem: Origem, Elemento: Elemento}, function(data){
        eval(data);
    });
});
  </script>

<%
splEtapa = split(ref("Etapa"), ", ")
c = 0
for i=0 to ubound(splEtapa)
    c = c+1
next
if c>0 then
    larg = cint(100/c)
end if

AccountAssociation = ref("AccountAssociation")

set fun = db.execute("select * from chamadasconstatus order by Ordem")
while not fun.eof
    if instr(ref("Etapa"), "|"&fun("id")&"|") then
        %> 
        <ul id="f<%=fun("id") %>" class="connectedSortable bs-component panel panel-<%'=fun("Cor") %>">
        <li class="panel-heading">
            <div class="widget-header">
                <h5><%=ucase(fun("NomeStatus")) %></h5>
            </div>
        </li>
                <%
                    if instr(ref("Origem"), "|ALL|")=0 and ref("Origem")<>"" then
                        sqlOrigem = " AND p.Origem="&replace(ref("Origem"), "|", "")
                    end if
                    if ref("Responsavel")<>"" then
                        sqlResp = " AND p.sysUser in("&replace(ref("Responsavel"), "|", "")&") "
                    end if
                    if ref("DataDe")<>"" then
                        sqlDataDe = " AND date(p.sysDate)>="&mydatenull(ref("DataDe"))&" "
                    end if
                    if ref("DataAte")<>"" then
                        sqlDataAte = " AND date(p.sysDate)<="&mydatenull(ref("DataAte"))&" "
                    end if
                    if ref("De")<>"" and ref("De")<>"0,00" then
                        sqlDe = " AND p.ValorInteresses>="&treatvalzero(ref("De"))&" "
                    end if
                    if ref("Ate")<>"" and ref("Ate")<>"0,00" then
                        sqlAte = " AND p.ValorInteresses<="&treatvalzero(ref("Ate"))&" "
                    end if
                    if ref("FollowUp")="Nenhum" then
                        sqlFup = " and isnull(r.Data)"
                    elseif ref("FollowUp")="Vencidos" then
                        sqlFup = " and (r.Data<date(now()) or (r.Data=date(now()) and r.Hora<time(now())) )"
                    elseif ref("FollowUp")="Futuros" then
                        sqlFup = " and (r.Data>date(now()) or (r.Data=date(now()) and r.Hora>time(now())) )"
                    else
                        sqlFup = ""
                    end if

                    response.Buffer
                    
                    if AccountAssociation="3" then
                        set pac = db.execute("select 'Pacientes' link, '3' Associacao, p.id, p.NomePaciente, p.Tel1, p.Tel2, p.Cel1, p.Cel2, p.Email1, p.Email2, p.Interesses, p.ValorInteresses, r.Data, r.Hora from pacientes p LEFT JOIN chamadasrecontatar r on replace(r.Contato, '3_', '')=p.id where p.ConstatusID="&fun("id") & sqlOrigem & sqlResp & sqlDataDe & sqlDataAte & sqlDe & sqlAte & sqlFup &" GROUP BY p.id ORDER BY p.sysDate desc LIMIT 200")
                    elseif AccountAssociation="8" then
                        set pac = db.execute("select 'ProfissionalExterno' link, '8' Associacao, p.id, p.NomeProfissional NomePaciente, p.Tel1, p.Tel2, p.Cel1, p.Cel2, p.Email1, p.Email2, p.Interesses, p.ValorInteresses, r.Data, r.Hora from profissionalexterno p LEFT JOIN chamadasrecontatar r on replace(r.Contato, '8_', '')=p.id where sysActive=1 AND p.ConstatusID="&fun("id") & sqlResp & sqlDataDe & sqlDataAte & sqlDe & sqlAte & sqlFup &" GROUP BY p.id ORDER BY p.sysDate desc LIMIT 200")
                    end if
                    while not pac.eof
                        response.flush()
                        %>
                        <li class="ui-state-default" id="<%=pac("id") %>">
                            

<button type="button" onclick="interacao('V', '', '<%=pac("Associacao") &"_"& pac("id") %>')" class="btn btn-gradient btn-xs btn-default"><i class="far fa-search"></i></button>


<div class="btn-group">
    <button type="button" class="btn btn-xs btn-gradient btn-default dropdown-toggle" data-toggle="dropdown" aria-expanded="false"><i class="far fa-plus"></i></button>
    <ul class="dropdown-menu" role="menu">
        <li>
            <a href="#">NOVA INTERAÇÃO</a>
        </li>
        <li class="divider"></li>
        <%
        set cc = db.execute("select * from chamadascanais")
        while not cc.eof
			
            %>
            <li>
                <a href="#" onclick="btb(<%=cc("id") %>, '', '<%= pac("Associacao") &"_"& pac("id") %>')"><i class="far fa-<%=cc("Icone") %>"></i> <%=cc("NomeCanal") %></a>
            </li>
            <%
        cc.movenext
        wend
        cc.close
        set cc=nothing
        %>
    </ul>
</div>
<b><a target="_blank" href="./?P=<%= pac("Link") %>&Pers=1&I=<%=pac("id") %>"><%=ucase(pac("NomePaciente")&"") %></a></b>



                            <br />
                            <%= prebtb(pac("Associacao")&"_"&pac("id"), pac("Tel1"), "Tel1") %>
                            <%= prebtb(pac("Associacao")&"_"&pac("id"), pac("Tel2"), "Tel2") %>
                            <%= prebtb(pac("Associacao")&"_"&pac("id"), pac("Cel1"), "Cel1") %>
                            <%= prebtb(pac("Associacao")&"_"&pac("id"), pac("Cel2"), "Cel2") %>
                            <%= prebtb(pac("Associacao")&"_"&pac("id"), pac("Email1"), "Email1") %>
                            <%= prebtb(pac("Associacao")&"_"&pac("id"), pac("Email2"), "Email2") %>
                            <%'=callAction(pac("Tel1"), 2, "3_"&pac("id")) %>
                            <%'=callAction(pac("Tel2"), 2, "3_"&pac("id")) %>
                            <%'=callAction(pac("Cel1"), 2, "3_"&pac("id")) %>
                            <%'=callAction(pac("Cel2"), 2, "3_"&pac("id")) %>
                            <br />
                            <small>
                            <%
                            if not isnull(pac("Interesses")) and pac("Interesses")<>"" then
                                set procs = db.execute("select group_concat(NomeProcedimento) NomesProcedimentos from procedimentos where id in("&replace(pac("Interesses")&"", "|", "")&")")
                                if not procs.eof then
                                    response.Write( procs("NomesProcedimentos") )
                                end if
                            end if

                            strFup = pac("Data") &" - "& ft(pac("Hora"))
                            if not isnull(pac("Data")) and isdate(pac("Data")) then
                                if pac("Data")<date() or (pac("Data")=date() and pac("Hora")<time()) then
                                    strFup = "<span class='badge badge-sm arrowed badge-danger'>" & strFup & "</span>"
                                end if
                            end if
                            %>
                            <br />
                            R$ <%=fn(pac("ValorInteresses")) %> &nbsp; &nbsp; &nbsp; Follow Up: <%=strFup %></small>
                        </li>
                        <%
                    pac.movenext
                    wend
                    pac.close
                    set pac=nothing
                %>
        </ul>
        <%
    end if
fun.movenext
wend
fun.close
set fun=nothing
%>
