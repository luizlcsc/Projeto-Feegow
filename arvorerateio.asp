		<link rel="stylesheet" href="assets/css/ace.css" />


<!--#include file="connect.asp"-->
<!--inicio treeview
                    <a href="" class="pull-right"> &nbsp;<i class="far fa-stethoscope green"></i> </a>
                    <a href="" class="pull-right"> &nbsp;<i class="far fa-money green"></i> </a>
                    <a href="" class="pull-right"> &nbsp;<i class="far fa-user-md green"></i> </a>

<div id="tree2" class="tree tree-selectable">
    <div class="tree-folder">
        <div class="tree-folder-header"><i class="far fa-circle"></i><div class="tree-folder-name">Rateio Geral</div></div>
        <div class="tree-folder-content">
            <div class="tree-folder">
                <div class="tree-folder-header"><i class="far fa-user-md"></i><div class="tree-folder-name">Profissional - Gra&ccedil;a Tavares</div></div>
                <div class="tree-folder-content">
                    <div class="tree-item"><div class="tree-item-name"><i class="far fa-money"></i>Forma - Particular</div></div>
                    <div class="tree-item"><div class="tree-item-name"><i class="far fa-money"></i> Forma - Unimed</div></div>
                </div>
            </div>
        </div>
	</div>
    <div class="tree-item">
        <div class="tree-item-name"><i class="far fa-stethoscope"></i> Procedimento - Consulta</div>
    </div>

    <div class="tree-item">
        <div class="tree-item-name"><i class="far fa-stethoscope"></i> Procedimento - Cirurgia</div>
    </div>
</div>
-->
<!--fim treeview-->
<%
function btnsRateio(DominioID, Procedimentos, Profissionais, Formas)
	btnsRateio = ""
	if DominioID<>0 then
	    btnsRateio = btnsRateio&" <button type=""button"" onclick=""removeDominio("&DominioID&");"" class=""pull-right btn btn-xs btn-danger""> &nbsp;<i class=""far fa-remove""></i> </button> "
	end if
    if isnull(Procedimentos) or Procedimentos="" then
        btnsRateio = btnsRateio&" <button type=""button"" onclick=""fRateio('Procedimento', '', "&DominioID&");"" class=""pull-right btn btn-xs btn-primary""> &nbsp;+ <i class=""far fa-stethoscope""></i> </button>"
	end if
    if isnull(Profissionais) or Profissionais="" then
        btnsRateio = btnsRateio&" <button type=""button"" onclick=""fRateio('Profissional', '', "&DominioID&");"" class=""pull-right btn btn-xs btn-primary""> &nbsp;+ <i class=""far fa-user-md""></i> </button> "
	end if
    if isnull(Formas) or Formas="" then
        btnsRateio = btnsRateio&" <button type=""button"" onclick=""fRateio('Forma', '', "&DominioID&");"" class=""pull-right btn btn-xs btn-primary""> &nbsp;+ <i class=""far fa-money""></i> </button> "
    end if
end function

function DetRat(DominioID)
	set dom = db.execute("select * from rateiodominios where sysActive=1 and id="&DominioID)
	if not dom.eof then
		if dom("Tipo")="Profissional" then
			spl = split(dom("Profissionais"), ", ")
			for i=0 to ubound(spl)
				set prof = db.execute("select * from Profissionais where id = '"&replace(spl(i), "|", "")&"'")
				if not prof.eof then
					DetRat = DetRat&", "&prof("NomeProfissional")
				end if
			next
		elseif dom("Tipo")="Forma" then
			spl = split(dom("Formas"), ", ")
			for i=0 to ubound(spl)
				if spl(i)="|P|" then
					DetRat = DetRat&", Particular"
				elseif spl(i)="|C|" then
					DetRat = DetRat&", Todos os Conv&ecirc;nios"
				else
					set conv = db.execute("select * from convenios where id = '"&replace(spl(i), "|", "")&"'")
					if not conv.eof then
						DetRat = DetRat&", "&conv("NomeConvenio")
					end if
				end if
			next
		elseif dom("Tipo")="Procedimento" then
			spl = split(dom("Procedimentos"), ", ")
			for i=0 to ubound(spl)
				set proc = db.execute("select * from procedimentos where id = '"&replace(spl(i), "|", "")&"'")
				if not proc.eof then
					DetRat = DetRat&", "&proc("NomeProcedimento")
				end if
			next
		end if
	end if

	if len(DetRat)>2 then
		DetRat = right(DetRat, len(DetRat)-2)
	end if
	'DetRat = left(DetRat, 45)
	maxWidth = 450
	if session("Banco")="clinic5445" then
        maxWidth=650
	end if
	DetRat = "<small title="""&DetRat&""" class=""user-info"" style=""max-width:"&maxWidth&"px!important"">"&DetRat&"</small>"
end function







set d0 = db.execute("select 1, (select id from rateiofuncoes where DominioID=0 and FM='K' limit 1) Kit, (select id from rateiofuncoes where DominioID=0 and FM='E' limit 1) Equipe")
Kit = d0("Kit")
Equipe = d0("Equipe")
if not isnull(Kit) then Kit=" <i class='far fa-medkit'></i>" end if
if not isnull(Equipe) then Equipe=" <i class='far fa-users'></i>" end if
%>
<div id="tree2" class="tree tree-selectable">
    <div class="tree-folder">
        <div class="tree-folder-header"><i class="far fa-circle"></i><div class="tree-folder-name btn-group"><a href="javascript:fRateio('', 0, 'E');">0. Regra Geral de Repasse  <%=kit & equipe %></script></a><%= btnsRateio(0, "", "", "") %></div></div>
        <div class="tree-folder-content">
			<%
			iProfissional = "<i class=""far fa-user-md""></i>"
			iProcedimento = "<i class=""far fa-stethoscope""></i>"
			iForma = "<i class=""far fa-money""></i>"
			
			set d1 = db.execute("select d.*, (select id from rateiofuncoes where DominioID=d.id and FM='K' limit 1) Kit, (select id from rateiofuncoes where DominioID=d.id and FM='E' limit 1) Equipe from rateiodominios d where d.sysActive=1 and d.dominioSuperior=0")
			while not d1.eof
                Kit = d1("Kit")
                Equipe = d1("Equipe")
                if not isnull(Kit) then Kit=" <i class='far fa-medkit'></i>" end if
                if not isnull(Equipe) then Equipe=" <i class='far fa-users'></i>" end if

                Dominios = Dominios & d1("id") &", "
			%>
            <div class="tree-folder">
                <div class="tree-folder-header"><%=eval("i"&d1("Tipo"))%><div class="tree-folder-name btn-group"><a href="javascript:fRateio('<%=d1("Tipo")%>', <%=d1("id")%>, 'E');"><%= d1("id")&". "& d1("Tipo")%> <%=kit & equipe %></script></a> &raquo; <%=detRat(d1("id"))%><%= btnsRateio(d1("id"), d1("Procedimentos"), d1("Profissionais"), d1("Formas")) %></div></div>
                <div class="tree-folder-content">
                <%
                    set d2 = db.execute("select d.*, (select id from rateiofuncoes where DominioID=d.id and FM='K' limit 1) Kit, (select id from rateiofuncoes where DominioID=d.id and FM='E' limit 1) Equipe from rateiodominios d where d.sysActive=1 and d.dominioSuperior="&d1("id"))
                    while not d2.eof
                        Kit = d2("Kit")
                        Equipe = d2("Equipe")
                        if not isnull(Kit) then Kit=" <i class='far fa-medkit'></i>" end if
                        if not isnull(Equipe) then Equipe=" <i class='far fa-users'></i>" end if

                        Dominios = Dominios & d2("id") &", "
						%>
                        <div class="tree-folder">
                            <div class="tree-folder-header"><%=eval("i"&d2("Tipo"))%><div class="tree-folder-name btn-group"><a href="javascript:fRateio('<%=d2("Tipo")%>', <%=d2("id")%>, 'E');"><%= d2("id")&". "& d2("Tipo")%>  <%=kit & equipe %> </a> &raquo; <%=detRat(d2("id"))%><%= btnsRateio(d2("id"), d2("Procedimentos"), d2("Profissionais"), d2("Formas")) %></div></div>
                            <div class="tree-folder-content">
                            <%
                                set d3 = db.execute("select d.*, (select id from rateiofuncoes where DominioID=d.id and FM='K' limit 1) Kit, (select id from rateiofuncoes where DominioID=d.id and FM='E' limit 1) Equipe from rateiodominios d where d.sysActive=1 and d.dominioSuperior="&d2("id"))
                                while not d3.eof
                                    Kit = d3("Kit")
                                    Equipe = d3("Equipe")
                                    if not isnull(Kit) then Kit=" <i class='far fa-medkit'></i>" end if
                                    if not isnull(Equipe) then Equipe=" <i class='far fa-users'></i>" end if

                                    Dominios = Dominios & d3("id") &", "
                                    %>
                                    <div class="tree-folder">
                                        <div class="tree-folder-header"><%=eval("i"&d3("Tipo"))%><div class="tree-folder-name btn-group"><a href="javascript:fRateio('<%=d3("Tipo")%>', <%=d3("id")%>, 'E');"><%= d3("id")&". "& d3("Tipo")%> <%=kit & equipe %></a> &raquo; <%=DetRat(d3("id"))%><%= btnsRateio(d3("id"), d3("Procedimentos"), d3("Profissionais"), d3("Formas")) %></div></div>
                                        <div class="tree-folder-content">
                                        </div>
                                    </div>
                                    <%
                                d3.movenext
                                wend
                                d3.close
                                set d3=nothing
                            %>
                            </div>
                        </div>
						<%
					d2.movenext
					wend
					d2.close
					set d2=nothing
				%>
                </div>
            </div>
            <%
			d1.movenext
			wend
			d1.close
			set d1=nothing
			%>
        </div>
	</div>
</div>
<%
if session("Banco")="clinic5351" and session("Banco")<>"clinic2221" and session("Banco")<>"clinic3882" and session("Banco")<>"clinic5760" then
    db_execute("delete from rateiofuncoes where DominioID NOT IN("&Dominios & 0&")")
    db_execute("delete from rateiodominios where id NOT IN("&Dominios & 0&")")
end if
%>
<%'=Dominios %>