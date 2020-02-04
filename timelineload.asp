
<%
'variaveis estão no arquivo timeline.asp

'ALTER TABLE `buiformspreenchidos`	ADD COLUMN `Prior` TINYINT NULL DEFAULT '0' AFTER `sysActive`
'ALTER TABLE `buiforms`	ADD COLUMN `Prior` TINYINT NULL DEFAULT '0' AFTER `Versao`

    if ProfessionalID <>"" then
        sqlProf = "left join sys_users as us on us.id = sysUser where us.idInTable = "&ProfessionalID
    end if 

    if instr(Tipo, "|AE|")>0 then
    	sqlAE = " union all (select fp.Prior, fp.id, fp.ModeloID, fp.sysUser, 'AE', f.Nome, 'bar-chart', 'info', fp.DataHora, f.Tipo from buiformspreenchidos fp LEFT JOIN buiforms f on f.id=fp.ModeloID WHERE f.Tipo IN(1, 2) AND (fp.sysActive=1 OR fp.sysActive IS NULL) AND PacienteID="&PacienteID&") "
    end if

    if instr(Tipo, "|L|")>0 then
        sqlL = 	" union all (select fp.Prior, fp.id, fp.ModeloID, fp.sysUser, 'L', f.Nome, 'align-left', 'primary', fp.DataHora, f.Tipo from buiformspreenchidos fp LEFT JOIN buiforms f on f.id=fp.ModeloID WHERE (f.Tipo IN(3, 4, 0) or isnull(f.Tipo)) AND (fp.sysActive=1 OR fp.sysActive IS NULL) AND PacienteID="&PacienteID&") "
    end if

	if instr(Tipo, "|Prescricao|")>0 then
        sqlPrescricao = " union all (select 0, id, ControleEspecial, sysUser, 'Prescricao', 'Prescrição', 'flask', 'warning', `Data`, Prescricao from pacientesprescricoes WHERE sysActive=1 AND PacienteID="&PacienteID&") "
    end if

    if instr(Tipo, "|Diagnostico|")>0 then
        sqlDiagnostico = " union all (select 0, d.id, '', d.sysUser, 'Diagnostico', 'Hipótese Diagnóstica', 'stethoscope', 'dark', d.DataHora, concat('<b>', IFNULL(cid.Codigo,''), ' - ', IFNULL(cid.Descricao,''), '</b><br>', IFNULL(d.Descricao,'')) FROM pacientesdiagnosticos d LEFT JOIN cliniccentral.cid10 cid on cid.id=d.CidID WHERE PacienteID="&PacienteID&") "
    end if

    if instr(Tipo, "|Atestado|")>0 then
        sqlAtestado = " union all (select 0, id, '', sysUser, 'Atestado', ifnull(Titulo, 'Atestado'), 'file-text-o', 'success', `Data`, Atestado from pacientesatestados  WHERE sysActive=1 AND PacienteID="&PacienteID&") "
    end if

    if instr(Tipo, "|Pedido|")>0 then
        sqlPedido = " union all (select 0, id, '', sysUser, 'Pedido', 'Pedido de Exame', 'hospital-o', 'system', `Data`, concat(PedidoExame, '<br>', IFNULL(Resultado, '')) from pacientespedidos WHERE sysActive=1 AND PacienteID="&PacienteID&" AND IDLaudoExterno IS NULL) "
        sqlPedido = sqlPedido & " union all (select 0, id, '', sysUser, 'PedidosSADT', 'Pedido SP/SADT', 'hospital-o', 'system', sysDate, IndicacaoClinica from pedidossadt WHERE sysActive=1 and PacienteID="&PacienteID&") "
    end if

    if instr(Tipo, "|Imagens|")>0 then
        sqlImagens = " union all (select 0, '0', Tipo, '0', 'Imagens', 'Imagens', 'camera', 'alert', DataHora, '' from arquivos WHERE Tipo='I' AND PacienteID="&PacienteID&" GROUP BY date(DataHora) ) "
    end if

    if instr(Tipo, "|Arquivos|")>0 then
        sqlArquivos = " union all (select 0, '0', Tipo, '0', 'Arquivos', 'Arquivos', 'file', 'danger', DataHora, '' from arquivos WHERE provider <> 'S3' AND Tipo='A' AND PacienteID="&PacienteID&" GROUP BY date(DataHora) ) "
    end if
                 c=0

    sql = "select t.* from ( (select 0 Prior, '' id, '' Modelo, '' sysUser, '' Tipo, '' Titulo, '' Icone, '' cor, '' DataHora, '' Conteudo limit 0) "&_
                sqlAE & sqlL & sqlPrescricao & sqlDiagnostico & sqlAtestado & sqlPedido & sqlImagens & sqlArquivos &_
                ") t "&sqlProf&" ORDER BY Prior DESC, DataHora DESC limit "&loadMore&","&MaximoLimit
             'response.write(sql)
             set ti = db.execute( sql )
             while not ti.eof
                 Ano = year(ti("DataHora"))
                 if UltimoAno<>Ano then
                    abreAno = "          <div class=""timeline-divider mtn hidden-xs"">            <div class=""divider-label"">"&Ano&"</div>          </div>          <div class=""row"">          <div class=""col-sm-6 right-column"">"
                    if c>0 then
                        abreAno = "</div></div>" & abreAno
                    end if
                 else
                    abreAno = ""
                 end if
                 UltimoAno = Ano

                'response.write( abreAno )

                c = c + 1
                exibe = 1
                if ti("Tipo")="AE" or ti("Tipo")="L" then
                	if ti("Tipo")="L" then
		                sqlTipo = " and (buiforms.Tipo=3 or buiforms.Tipo=4 or buiforms.Tipo=0 or isnull(buiforms.Tipo))"
	                else
		                sqlTipo = " and (buiforms.Tipo=1 or buiforms.Tipo=2)"
	                end if

                    set preen = db.execute("select buiformspreenchidos.id idpreen, buiforms.Nome, buiformspreenchidos.ModeloID, buiformspreenchidos.Autorizados, buiformspreenchidos.sysUser preenchedor, buiformspreenchidos.PacienteID, buiformspreenchidos.DataHora, buiforms.* from buiformspreenchidos left join buiforms on buiformspreenchidos.ModeloID=buiforms.id where buiformspreenchidos.id="& ti("id") &" order by buiformspreenchidos.DataHora desc, id desc")
                    if not preen.eof then
	                    if preen("preenchedor")=session("User") or preen("Autorizados")="|ALL|" or isnull(preen("Autorizados")) then
		                    if preen("Autorizados")="|ALL|" or isnull(preen("Autorizados")) then
			                    icone = "unlock"
		                    else
			                    icone = "lock"
		                    end if

                            if autForm(preen("ModeloID"), "VO", "")=true or autForm(preen("ModeloID"), "AO", "")=true or preen("preenchedor")=session("User") then
                                exibe = 1
                            else
                                exibe = 0
                            end if
                        end if
                    end if
                end if
                if exibe=1 then
             %>
            <%
            PermissaoArquivo = true

            if ti("Tipo")<>"AE" and ti("Tipo")<>"L" then
                'logica de compartilhamento de prontuario, e arquivos
                'verifica permissão para acesso dos arquivos
                set idProfissional = db.execute("select idintable from sys_users where id="&ti("sysUser"))
                idInTable=0
                if not idProfissional.eof then
                    idInTable = session("idInTable")
                end if

                set Compart = db.execute("select * from prontuariocompartilhamento where ProfissionalID="&idInTable&" and CategoriaID=(select id from cliniccentral.tipoprontuario t where sysActive=1 and t.Tipo='"&ti("Tipo")&"')")
                set ArquivoCompart = db.execute("select * from arquivocompartilhamento where ProfissionalID="&idInTable&" and CategoriaID=(select id from cliniccentral.tipoprontuario t where sysActive=1 and t.Tipo='"&ti("Tipo")&"') and DocumentoID="&ti("id"))
                tipocompartilhamento = 1

                if not Compart.EOF then
                    tipocompartilhamento = Compart("TipoCompartilhamentoID")
                    if tipocompartilhamento = 1 then
                        PermissaoArquivo = true
                        elseif tipocompartilhamento = 2 then
                            PermissaoArquivo = false
                        elseif tipocompartilhamento = 3 then
                            if instr(Compart("Compartilhados"), "|"&idUsuario&"|")>0 then
                                PermissaoArquivo = true
                                else
                                PermissaoArquivo = false
                            end if
                    end if
                end if
                if not ArquivoCompart.EOF then
                        if ArquivoCompart("TipoCompartilhamentoID") <> 0 then
                            tipocompartilhamento = ArquivoCompart("TipoCompartilhamentoID")
                        end if

                        if tipocompartilhamento = 1 then
                            PermissaoArquivo = true
                        elseif tipocompartilhamento = 2 then
                            PermissaoArquivo = false
                        elseif tipocompartilhamento = 3 then
                            if instr(ArquivoCompart("Compartilhados"), "|"&idUsuario&"|")>0 then
                                PermissaoArquivo = true
                                else
                                PermissaoArquivo = false
                            end if
                    end if
                end if
            end if

            if cstr(session("User"))=ti("sysUser")&"" then
            PermissaoArquivo = true
            end if

            if PermissaoArquivo then
            'response.write tipoCompartilhamento
            %>
            <div class="timeline-item">
                <div class="timeline-icon hidden-xs">
                    <span class="fa fa-<%=ti("icone") %> text-<%=ti("cor") %>"></span>
                </div>
                <div class="panel">
                    <div class="panel-heading">
                        <span class="panel-title panel-warning">
                            <%
                            if ti("Tipo")="AE" or ti("Tipo")="L" then
                                if ccur(ti("Prior"))="1" then
                                    %>
                                    <i style="cursor:default" title="Desmarcar como favorito" class="fa fa-star text-warning"></i>
                                    <%
                                else

                                end if
                            end if
                            %>
                            <span class="fa fa-align-justify"></span>
                            <% if ti("sysUser")<>0 then response.write( nameInTable(ti("sysUser")) ) end if %>
                            <code><%=ti("Titulo") %></code>
                        </span>
                        <%
                        if OcultarBtn<>"1" then
                        %>
                        <span class="panel-controls hidden-xs">
                            <%
                            if cstr(session("User"))=ti("sysUser")&"" and aut("prescricoesX")>0 and (ti("Tipo")<>"AE" and ti("Tipo")<>"L")  then
                            %>
                            <div class=" dropdown panel-controls" >
                                <a data-toggle="dropdown"  aria-haspopup="true" aria-expanded="false">
                                    <i class="fa fa-share-alt "></i>
                                </a>
                                <ul class="dropdown-menu pull-right" role="menu" >
                                    <li>
                                        <a <% if tipoCompartilhamento = 1  then %> class="compartilhamentoSelect" <% end if %> href="javascript:saveCompartilhamento(1,'<%=ti("Tipo") %>',<%=ti("id") %>,<%=session("idInTable") %>)" > <i class="fa fa-users"></i> Publico </a>
                                    </li>
                                    <li>
                                        <a <% if tipoCompartilhamento = 2  then %> class="compartilhamentoSelect" <% end if %> href="javascript:saveCompartilhamento(2,'<%=ti("Tipo") %>',<%=ti("id") %>,<%=session("idInTable") %>)" ><i class="fa fa-lock"></i> Privado</a>
                                    </li>
                                    <li>
                                        <a <% if tipoCompartilhamento = 3  then %> class="compartilhamentoSelect" <% end if %> href="javascript:compartilhamentoRestrito('<%=ti("Tipo") %>',<%=ti("id") %>,<%=session("idInTable") %>)" ><i class="fa fa-eye-slash"></i> Restrito</a>
                                    </li>
                                        <li class="divider"></li>
                                    <li>
                                        <a href="javascript:saveCompartilhamento(0,'<%=ti("Tipo") %>',<%=ti("id") %>,<%=session("idInTable") %>)" > <i class="fa fa-asterisk"></i> Padrão </a>
                                    </li>
                                </ul>
                            </div>
                            <%
                            end if
                            recursoUnimed = recursoAdicional(12)
                            if (ti("sysUser")<2 or cstr(session("User"))=ti("sysUser")&"" or lcase(session("Table"))="funcionarios") and recursoUnimed=4 then
                            %>
                            <a href="javascript:iPront('<%=ti("Tipo") %>', <%=PacienteID%>, '<%=ti("Modelo")%>', <%=ti("id") %>, '');">
                                <i class="fa fa-search-plus"></i>
                            </a>
                            <%
                            elseif recursoUnimed<>4 then
                            %>
                            <a href="javascript:iPront('<%=ti("Tipo") %>', <%=PacienteID%>, '<%=ti("Modelo")%>', <%=ti("id") %>, '');">
                                <i class="fa fa-search-plus"></i>
                            </a>
                            <%
                            end if
                            if cstr(session("User"))=ti("sysUser")&"" and aut("prescricoesX")>0 then %>
                                <a href="javascript:if(confirm('Tem certeza de que deseja apagar esta prescrição?'))pront('timeline.asp?PacienteID=<%= PacienteID %>&Tipo=|<%= ti("Tipo") %>|&X=<%= ti("id") %>');">
                                    <i class="fa fa-remove"></i>
                                </a>
                            <% end if %>
                            <% if ti("Tipo") = "PedidosSADT" or ti("Tipo") = "Pedido" then %>
                                <a class='' href="javascript:modalInsuranceAttachments(<%=PacienteID%>, <%=ti("id")%>);" title='Anexar um arquivo'><i class="fa fa-paperclip"></i></a>
                            <% end if %>
                        </span>
                        <%
                        end if
                        %>

                        <div class="panel-header-menu pull-right mr10 text-muted fs12"><%
                            if not isnull(ti("DataHora")) then
                                response.write( formatdatetime( ti("DataHora"), 2) &" - "& ft( ti("DataHora")) )
                            end if
                            %> </div>
                    </div>
                    <div class="panel-body timelineApp" <% if device()<>"" then %> style="overflow-x:scroll!important" <% end if %> >
                <%
'                response.Write( Rotulo & Valor  &"<br>{{"& ti("Tipo") &"}}" )
                select case ti("Tipo")
                    case "AE", "L"

                        set l = db.execute("select l.StatusID, l.id from laudos l where not isnull(l.StatusID) and l.FormPID="& ti("id"))
                        if not l.eof then
                            LaudoID = l("id")
                            if l("StatusID")=3 then
                                ExibeLaudo = 1
                            else
                                ExibeLaudo = 0
                            end if
                        else
                            ExibeLaudo = 1
                        end if

                        if ExibeLaudo=1 then
                            if session("Banco")="clinic5856" and (ti("Modelo")=14 or ti("Modelo")=17) then
                                set paltura = db.execute("select Altura from buiforms where id="& ti("Modelo"))
                                if not paltura.eof then
                                    Altura = paltura("Altura")
                                end if
                                %>
                                <iframe width="100%" scrolling="no" height="<%= Altura %>" id="ifr<%= ti("id") %>" frameborder="0" src="callIPront.asp?t=<%= ti("Tipo") %>&p=<%= PacienteID %>&m=<%= ti("Modelo") %>&i=<%= ti("id") %>&a=&IFR=S"></iframe>
                                <%
                            else
                                response.Write("<small>")
                                set checktable = db.execute("SHOW TABLES LIKE '_"& ti("Modelo")&"'")
                                if not checktable.eof then
                                    set reg = db.execute("select * from `_"& ti("Modelo") &"` where id="& ti("id"))
                                    if not reg.eof then

                                        set pcampos = db.execute("select * from buicamposforms where FormID="&ti("Modelo")&" and TipoCampoID NOT IN(7,10,11,12,15) ORDER BY Ordem")
                                        while not pcampos.eof
                                            Rotulo = trim(pcampos("RotuloCampo")&"")
                                            if Rotulo<>"" then
                                                Rotulo = "<b>"&Rotulo&" </b> "
                                            end if
                                            if pcampos("TipoCampoID")=9 then
                                                Valor = ""
                                            else
                                                Valor = trim(reg(""&pcampos("id")&"")&"")
                                            end if
                                            select case pcampos("TipoCampoID")
                                                case 3
                                                    if Valor<>"" and Valor<>"uploads/" then
                                                    %>
                                                    <div class="media-body">
                                                        <b><%=Rotulo %></b><br />
                                                        <img src="uploads/<%=Valor %>" class="mw140 mr25 mb20">
                                                    </div><br />
                                                    <%
                                                    end if
                                                case 4, 5, 6
                                                    if instr(Valor, "|")>0 or (Valor<>"" and isnumeric(Valor)) then
                                                        set vals = db.execute("select group_concat(Nome SEPARATOR '; ') Valor from buiopcoescampos where id IN("& replace(Valor, "|", "") &")")
                                                        if not vals.eof then
                                                            Valor = vals("Valor")
                                                            response.Write( "<p>"&Rotulo &"<br>"& Valor  &"</p>" )
                                                        end if
                                                    end if
                                                case 9
                                                    set regTab = db.execute("select * from buitabelasvalores where CampoID="& pCampos("id")&" and FormPreenchidoID="& ti("id"))
                                                    if not regTab.eof then
                                                    %>
                                                    <table class="table table-condensed table-bordered mb10">
                                                        <thead>
                                                            <tr class="info">
                                                                <%
                                                                Largura = ccur(pcampos("Largura"))
                                                                cLarg = 0
                                                                set pTit = db.execute("select * from buitabelastitulos where CampoID="& pcampos("id"))
                                                                while cLarg<Largura
                                                                    cLarg = cLarg + 1
                                                                    %>
                                                                    <th><%= pTit("c"& cLarg) %></th>
                                                                    <%
                                                                wend
                                                                %>
                                                            </tr>
                                                        </thead>
                                                        <tbody>
                                                            <%
                                                            while not regTab.eof
                                                            %>
                                                            <tr>
                                                                <%
                                                                cLarg = 0
                                                                while cLarg<Largura
                                                                    cLarg = cLarg + 1
                                                                    %>
                                                                    <td><%= regTab("c"& cLarg) %></td>
                                                                    <%
                                                                wend
                                                                %>
                                                            </tr>
                                                            <%
                                                            regTab.movenext
                                                            wend
                                                            regTab.close
                                                            set regTab = nothing
                                                            %>
                                                        </tbody>
                                                    </table>
                                                    <%
                                                    end if
                                                case 14
                                                    %>
                                                    <iframe width="100%" scrolling="no" height="460" id="ifrCurva<%= ti("id") %>" frameborder="0" src="Curva.asp?CampoID=<%= pcampos("id") %>&FormPID=<%= reg("id") %>"></iframe>
                                                    <%
                                                case 16
                                                    set pcid = db.execute("select * from cliniccentral.cid10 where id = '"&Valor&"'")
                                                    if not pcid.eof then
                                                        NomeCid = pcid("Codigo") &" - "& pcid("Descricao")
                                                    end if
                                                    response.Write( Rotulo &"<br>"& NomeCid &"<br>" )
                                                case else
                                                    if Valor<>"" and Valor<>"<p><br></p>" then
                                                    if left(Valor, 5)="{\rtf" then
                                                            call limpa("_"&ti("Modelo"), pcampos("id"), reg("id"))

                                                    end if
                                                    response.Write( Rotulo &"<br>"& Valor  &"<br>" )
                                                    end if
                                            end select
                                            'response.Write( Rotulo & Valor  &"<br>[["& pcampos("TipoCampoID") &"]]" )
                                        pcampos.movenext
                                        wend
                                        pcampos.close
                                        set pcampos=nothing
                                    end if
                                end if
                                    response.Write("</small>")

                            end if
                        else
                            if aut("|laudosA|")>0 then
                                iniLau = "<a href='./?P=Laudo&Pers=1&I="& LaudoID &"'>"
                                fimLau = "</a>"
                            end if
                            response.Write(iniLau &"<em>Laudo em confecção.</em>"& fimLau)
                        end if
                        case "Pedido"
                        set ProcedimentosPedidoSQL = db.execute("SELECT pe.*,proc.NomeProcedimento FROM pedidoexameprocedimentos pe INNER JOIN procedimentos proc ON proc.id=pe.ProcedimentoID WHERE pe.PedidoExameID="&ti("id"))
                        %>
                        <ul>
                          <%
                                              while not ProcedimentosPedidoSQL.eof
                          Obs = ProcedimentosPedidoSQL("Observacoes")

                          if Obs<>""  then
                          Obs = " - "& Obs
                          end if
                          %>
                          <li>
                            <%=ProcedimentosPedidoSQL("NomeProcedimento")%><%=Obs%>
                          </li>
                          <%
                                              ProcedimentosPedidoSQL.movenext
                          wend
                          ProcedimentosPedidoSQL.close
                          set ProcedimentosPedidoSQL = nothing
                          %>
                        </ul>
                        <%
                        response.Write("<small>" & ti("Conteudo") & "</small>")
                          case "Diagnostico", "Prescricao", "Atestado"
                          response.Write("<small>" & ti("Conteudo") & "</small>")
                    case "PedidosSADT"
                        set psadt = db.execute("select tproc.descricao from pedidossadtprocedimentos pps LEFT JOIN cliniccentral.procedimentos tproc ON tproc.tipoTabela=pps.TabelaID AND pps.CodigoProcedimento=tproc.Codigo where pps.PedidoID="& ti("id"))
                        while not psadt.eof
                            %>
                            <%= psadt("Descricao") %><br />
                            <%
                        psadt.movenext
                        wend
                        psadt.close
                        set psadt = nothing
                        %>
                        <br />
                        <em><%= ti("Conteudo") %></em>
                        <%
                    case "Imagens"
                        %>
                    <div class="row">
                        <%
                            set im = db.execute("select * from arquivos where date(DataHora)="&mydatenull(ti("DataHora"))&" AND Tipo='I' AND PacienteID="&PacienteID)
                            while not im.eof
                                permissao = VerificaProntuarioCompartilhamento(im("sysUser"), ti("Tipo"), im("id"))
                                podever = true

                                if permissao <> "" then
                                    permissaoSplit = split(permissao,"|")
                                    podever = permissaoSplit(0)
                                end if

                                if podever then
                                %>
                                    <span>
                                    <% if ComEstilo = "S" then %>
                                            <img style="height:150px; width:150px" src="<%=arqEx(im("NomeArquivo"), "Imagens")%>" class="img-thumbnail" title="<%=im("Descricao") %>" alt="<%=im("Descricao") %>">
                                    <% else %>
                                        <a class="gallery-item" href="<%=arqEx(im("NomeArquivo"), "Imagens")%>" target="_blank">
                                            <img style="height:150px; width:150px" src="<%=arqEx(im("NomeArquivo"), "Imagens")%>" class="img-thumbnail" title="<%=im("Descricao") %>" alt="<%=im("Descricao") %>">
                                        </a>
                                    <% end if %>
                                    </span>
                                <%
                                end if
                                im.movenext
                            wend
                            im.close
                            set im=nothing
                             %>
                    </div>
                        <%
                    case "Arquivos"
                            %>
                       <div class="row">
                         <%
                            set im = db.execute("select * from arquivos where date(DataHora)="&mydatenull(ti("DataHora"))&" AND Tipo='A' AND PacienteID="&PacienteID)
                            while not im.eof
                                permissao = VerificaProntuarioCompartilhamento(im("sysUser"), ti("Tipo"), im("id"))
                                podever = true

                                if permissao <> "" then
                                    permissaoSplit = split(permissao,"|")
                                    podever = permissaoSplit(0)
                                end if

                                if podever then
                                %>
                                    <div class="col-xs-2 mb10" style="min-width:150px;">
                                        <div class="panel-tile text-center br-a br-light" >
                                            <div class="panel-body bg-light dark">
                                            <% if ComEstilo = "S" then %>
                                                    <h1 class="fs35 mbn"><i class="fa fa-file-text"></i></h1>
                                            <% else %>
                                                <a href="<%=arqEx(im("NomeArquivo"), "Arquivos")%>" target="_blank">
                                                    <h1 class="fs35 mbn"><i class="fa fa-file-text"></i></h1>
                                                </a>
                                            <% end if %>

                                            </div>
                                            <div class="panel-footer bg-white br-t br-light p12">
                                                <span class="fs11">
                                                    <%=im("Descricao") %>
                                                </span>
                                            </div>
                                        </div>
                                    </div>
                                <%
                                end if
                                im.movenext
                            wend
                            im.close
                            set im=nothing
                             %>
                        </div>
                        <%
                end select
                %>
                    </div>
                </div>
            </div>
            <%
                end if
            end if

              ti.movenext
              wend
              ti.close
              set ti=nothing

                  if c>0 then
                   ' response.Write("</div></div>             <div class=""timeline-divider"">            <div class=""divider-label"">"&Ano&"</div>          </div>")
                  end if
              %>