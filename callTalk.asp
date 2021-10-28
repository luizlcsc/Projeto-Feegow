<%
MeuNome = "Eu"
MinhaFoto = session("Photo")

if ccur(De)<>session("User") then
	NomeChat = nameInTable(De)
	FotoChat = fotoInTable(De)
else
	NomeChat = nameInTable(Para)
	FotoChat = fotoInTable(Para)
end if
NomeChat = trim(NomeChat)
if instr(NomeChat, " ")>0 then
	splNome = split(NomeChat, " ")
	NomeChat = splNome(0)
end if

set msgs = db.execute("select * from chatmensagens where ((De="&De&" and Para="&Para&") or (De="&Para&" and Para="&De&")) and date(DataHora)>date_add(date(now()) , interval -15 day) order by id")
if msgs.eof then
    %>
    <p style="color: #909090" class="text-center mt50">Nenhuma conversa ainda.</p>
    <%
end if
while not msgs.eof
	if cdate(formatdatetime(msgs("DataHora"),2))=date() then
		DataMSG = "Hoje"
	else
		DataMSG = day(msgs("DataHora"))&"/"&left(monthname(month(msgs("DataHora"))),3)
	end if
    if msgs("De")=session("User") then
        ShowNome = MeuNome
        ShowFoto = FotoChat
        %>
        <div style=" width: 300px; display:inline-block;">
        <div class="media media-own-message">
            <div class="media-body">
            <h5 class="media-heading" style="color: #fff;"><%'=ShowNome %>
                <small class="chat-time-sent"> <%=DataMSG &" - "& formatdatetime(msgs("DataHora"), 4)%></small>
            </h5>
            <p style="width: 100%" class="mt10"><%= msgs("Mensagem") %></p>
            </div>
            <div class="media-right">
            <!--<a href="#">
                <img class="media-object" src="<%'if msgs("De")=session("User") then response.Write(MinhaFoto) else response.Write(FotoChat) end if%>" width="40" height="40">
            </a>-->
            </div>
        </div>
        </div>
        <%
    else
        ShowNome = NomeChat
        ShowFoto =   MinhaFoto
        %>
        <div style="width: 300px; display: inline-block ;">

        <div class="media" style="float: left;">
            <div class="media-left">
            <!--<a href="#">
                <img class="media-object" src="<%'if msgs("De")=session("User") then response.Write(MinhaFoto) else response.Write(FotoChat) end if%>" width="40" height="40">
            </a>-->
            </div>
            <div class="media-body">
            <h5 class="media-heading"><%'=ShowNome %>
                <small class="chat-time-sent"> <%=DataMSG &" - "& formatdatetime(msgs("DataHora"), 4)%></small>
            </h5> <%= msgs("Mensagem") %>
            </div>
        </div>
        </div>
        <%

    end if
msgs.movenext
wend
msgs.close

set msgs=nothing
%>
<br />
