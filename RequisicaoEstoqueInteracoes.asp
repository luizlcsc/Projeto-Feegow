<!--#include file="connect.asp"-->
<%
if ref("msgInteracao")<>"" then
    db_execute("insert into tarefasmsgs (RequisicaoID, data, hora, desession, para, msg) values ("&req("I")&", curdate(), curtime(), "&session("User")&", (select De from tarefas where id="&req("I")&"), '"&ref("msgInteracao")&"')")
end if

set ints = db.execute("select m.*, p.NomeProfissional, f.NomeFuncionario, u.Table, p.Foto Fotop, f.Foto Fotof from tarefasmsgs m LEFT JOIN sys_users u on u.id=m.desession LEFT JOIN profissionais p on p.id=u.idInTable LEFT JOIN funcionarios f on f.id=u.idInTable where m.RequisicaoID="&req("I")&" order by m.data, m.hora")
if ints.eof then
    response.write("<div class='alert alert-info'>Nenhuma interação neste chamado.</div><hr>")
else
    while not ints.eof
    if lcase(ints("Table")&"")="profissionais" then
        Nome = ints("NomeProfissional")
        Foto = ints("Fotop")
    elseif lcase(ints("Table")&"")="funcionarios" then
        Nome = ints("NomeFuncionario")
        Foto = ints("Fotof")
    end if
    if isnull(Foto) or Foto="" then
        Foto = "../assets/img/user.png"
    else
        Foto = "../uploads/"&Foto
    end if

    if ints("desession")=session("User") then
    %>
                        <div class="media" style="float: right;padding-right: 10px">

                          <div class="media-body" style="background-color: #6ddaf8; color: #fff;border-radius: 7px">
                            <span class="media-status"></span>
                            <h5 class="media-heading" style="color: #fff;"><%=Nome %>
                              <small> - <%=ints("data")&" "&formatdatetime(ints("hora"), 4) %></small>
                            </h5> <%=ints("msg") %>
                          </div>
                          <div class="media-right">
                              <a href="#">
                                <img class="media-object" alt="Foto" src="<%=Foto %>">
                              </a>
                            </div>
                        </div>
    <%else %>
                        <div class="media" style="float: left;">
                         <div class="media-left">
                            <a href="#">
                              <img class="media-object" alt="Foto" src="<%=Foto %>">
                            </a>
                          </div>
                          <div class="media-body">
                            <span class="media-status"></span>
                            <h5 class="media-heading"><%=Nome %>
                              <small> - <%=ints("data")&" "&formatdatetime(ints("hora"), 4) %></small>
                            </h5> <%=ints("msg") %>
                          </div>

                        </div>

	
    <%

    end if

    ints.movenext
    wend
    ints.close
    set ints=nothing
end if
%>
