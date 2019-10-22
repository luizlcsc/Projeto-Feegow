<!--#include file="connect.asp"-->
<%
De = mydatenull(req("DataDe"))
Ate = mydatenull(req("DataAte"))
BETWEEN = " BETWEEN "& De &" AND "& Ate &" "
%>

					<label><input class="ace" onClick="$('.profissional').prop('checked', $(this).prop('checked'))" type="checkbox" name="Checkall" value=""><span class="lbl"> Todos os profissionais</span></label><br>
                <%
                set profissionaisQtdSQL = db.execute("select count(id)n from profissionais where sysActive=1 and Ativo='on' order by NomeProfissional")

                qtdProfissionais = 0
                if not profissionaisQtdSQL.eof then
                    qtdProfissionais = ccur(profissionaisQtdSQL("n"))
                end if

                if qtdProfissionais < 40 then
                    set punits = db.execute("select id, NomeProfissional from profissionais where sysActive=1 and Ativo='on' order by NomeProfissional")
                else
                    set punits = db.execute("select distinct t.ProfissionalID id, prof.NomeProfissional from ("&_
    "	select distinct ProfissionalID from itensinvoice where Executado='S' and Associacao=5 and DataExecucao "& BETWEEN &_
    "	UNION ALL "&_
    "	select distinct ProfissionalID from tissprocedimentossadt where Data "& BETWEEN &_
    "	UNION ALL"&_
    "	select distinct ProfissionalID from tissprocedimentoshonorarios where Data "& BETWEEN &_
    "	UNION ALL"&_
    "	select distinct ifnull(ProfissionalEfetivoID, ProfissionalID) from tissguiaconsulta WHERE DataAtendimento "& BETWEEN &_
    "   ) t LEFT JOIN profissionais prof ON prof.id=t.ProfissionalID WHERE NOT ISNULL(prof.NomeProfissional) ORDER BY NomeProfissional")
                end if
                while not punits.eof
					if aut("|agendaV|")=1 or (lcase(session("Table"))="profissionais" and session("idInTable")=punits("id")) then
                    %>
					<label for="Profissional<%=punits("id")%>"><input class="profissional" type="checkbox" name="ProfissionalID" id="Profissional<%=punits("id")%>" value="<%=punits("id")%>"><span class="lbl"> <%=punits("NomeProfissional")%></span></label><br>
                    <%
					end if
                punits.movenext
                wend
                punits.close
                set punits=nothing
                %>
