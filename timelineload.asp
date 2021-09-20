<!--#include file="./Classes/imagens.asp"-->
<%
'variaveis estão no arquivo timeline.asp

'ALTER TABLE `buiformspreenchidos`	ADD COLUMN `Prior` TINYINT NULL DEFAULT '0' AFTER `sysActive`
'ALTER TABLE `buiforms`	ADD COLUMN `Prior` TINYINT NULL DEFAULT '0' AFTER `Versao`
recursoUnimed = recursoAdicional(12)
urlbmj = getConfig("urlbmj")

SinalizarFormulariosSemPermissao = getConfig("SinalizarFormulariosSemPermissao")

    SqlLimit = "limit "&loadMore&","&MaximoLimit

    if req("SemLimit") = "S" then
        SqlLimit = ""
    end if

    if ProfessionalID <>"" then
        sqlProf = "left join sys_users as us on us.id = sysUser where us.idInTable = "&ProfessionalID
    end if 

    if instr(Tipo, "|AE|")>0 then
    	sqlAE = " union all (select fp.Prior, fp.id, fp.ModeloID, fp.sysUser, 'AE', f.Nome, 'bar-chart', 'info', fp.DataHora, f.Tipo,'', fp.sysActive, '' from buiformspreenchidos fp LEFT JOIN buiforms f on f.id=fp.ModeloID WHERE f.Tipo IN(1, 2) AND (fp.sysActive IN(1,-1) OR fp.sysActive IS NULL) AND PacienteID="&PacienteID&") "
    end if

    if instr(Tipo, "|L|")>0 then
        sqlL = 	" union all (select fp.Prior, fp.id, fp.ModeloID, fp.sysUser, 'L', f.Nome, 'align-left', 'primary', fp.DataHora, f.Tipo,'', fp.sysActive, '' from buiformspreenchidos fp LEFT JOIN buiforms f on f.id=fp.ModeloID WHERE (f.Tipo IN(3, 4, 0) or isnull(f.Tipo)) AND (fp.sysActive IN(1,-1) OR fp.sysActive IS NULL) AND PacienteID="&PacienteID&") "
    end if

    if aut("prescricoesV")>0 or session("Admin") = 1 then
        if instr(Tipo, "|Prescricao|")>0 then
            sqlPrescricao = " union all (select 0, pp.id, ControleEspecial, sysUser, 'Prescricao', IF(pp.MemedID IS NULL, 'Prescrição', 'Prescrição Memed'), 'flask', 'warning', `Data`, Prescricao,s.id, pp.sysActive, pp.MemedID from pacientesprescricoes AS pp LEFT JOIN dc_pdf_assinados AS s ON s.DocumentoID = pp.id AND s.tipo = 'PRESCRICAO' WHERE sysActive in (1,-1) AND PacienteID="&PacienteID&") "
        end if
    end if


    if instr(Tipo, "|Diagnostico|")>0 then

        sqlBmj = " IFNULL((SELECT GROUP_CONCAT(DISTINCT CONCAT('<BR><strong>BMJ:</strong> <a href=""[linkbmj]/',bmj.codbmj,'""  target=""_blank""  class=""badge badge-primary"">',if(bmj.PortugueseTopicTitle='0',bmj.TopicTitle,bmj.PortugueseTopicTitle),'</a>') SEPARATOR ' ') " &_
                 " FROM cliniccentral.cid10_bmj bmj" &_
                 " WHERE bmj.cid10ID = cid.id),'') "

        sqlTnm = "CONCAT(IFNULL(d.Descricao, ''), '<br>', IFNULL(tnm.Descricao, ''))"

        sqlDiagnostico = " union all (SELECT 0, d.id, '', d.sysUser, 'Diagnostico', 'Hipótese Diagnóstica', 'stethoscope', 'dark', d.DataHora, "&_
                         "   CONCAT('<b>', IFNULL(cid.Codigo,''), ' - ', IFNULL(cid.Descricao,''), '</b><br>', "&sqlBmj&",'<br>',"&sqlTnm&",''),'', d.sysActive, '' "&_
                         "   FROM pacientesdiagnosticos d "&_
                         "   LEFT JOIN cliniccentral.cid10 cid ON cid.id=d.CidID "&_
                         "   LEFT JOIN pacientesdiagnosticos_tnm tnm ON d.id = tnm.PacienteDiagnosticosID "&_
                         "   WHERE PacienteID="&PacienteID&" and d.sysActive in (1,-1)) "

    end if

    if instr(Tipo, "|Atestado|")>0 then
        sqlAtestado = " union all (select 0, pa.id, '', sysUser, 'Atestado', ifnull(Titulo, 'Atestado'), 'file-text', 'success', `Data`, Atestado,s.id, pa.sysActive, '' from pacientesatestados pa LEFT JOIN dc_pdf_assinados AS s ON s.DocumentoID = pa.id AND s.tipo = 'ATESTADO' WHERE sysActive in (1,-1) AND PacienteID="&PacienteID&") "
    end if

     if instr(Tipo, "|Tarefas|")>0 then
        sqlTarefa = " union all (SELECT 0, ta.id, '', ta.sysuser, 'Tarefas' , ta.Titulo, 'check-square-o' , 'success' , ta.dtabertura  , tm.msg ,'' assinatura, ta.sysActive, '' FROM tarefas ta "&_
                    " INNER JOIN tarefasmsgs tm ON tm.TarefaID = ta.id "&_
                    " WHERE ta.solicitantes LIKE ',3_"&PacienteID&"%') "
    end if

    if instr(Tipo, "|Pedido|")>0 then
        sqlPedido = " union all (select 0, ppd.id, '', sysUser, 'Pedido', IF(ppd.MemedID IS NULL, 'Pedido de Exame', 'Pedido de Exame Memed'), 'hospital-o', 'system', `Data`, concat(PedidoExame, '<br>', IFNULL(Resultado, '')),s.id, ppd.sysActive, ppd.MemedID from pacientespedidos ppd LEFT JOIN dc_pdf_assinados AS s ON s.DocumentoID = ppd.id AND s.tipo = 'PEDIDO_EXAME' WHERE sysActive in (1,-1) AND PacienteID="&PacienteID&" AND IDLaudoExterno IS NULL) "
        sqlPedido = sqlPedido & " union all (select 0, id, '', sysUser, 'PedidosSADT', 'Pedido SP/SADT', 'hospital-o', 'system', sysDate, IndicacaoClinica,'', sysActive, '' from pedidossadt WHERE sysActive in (1,-1) and PacienteID="&PacienteID&") "
    end if

    if instr(Tipo, "|Protocolos|")>0 then
        sqlProtocolos = " union all (select 0, po.id, '', sysUser, 'Protocolos', 'Protocolos', 'file-text', 'success', `Data`, '', '', po.sysActive, '' from pacientesprotocolos po WHERE po.sysActive in (1,-1) AND po.PacienteID="&PacienteID&") "
    end if

    if instr(Tipo, "|Imagens|")>0 then
        sqlImagens = " union all (select 0, '0', Tipo, '0', 'Imagens', 'Imagens', 'camera', 'alert', DataHora,'','', arquivos.sysActive, '' from arquivos WHERE Tipo='I' AND PacienteID="&PacienteID&" GROUP BY date(DataHora) ) "
    end if

    if instr(Tipo, "|Arquivos|")>0 then
        sqlArquivos = " union all (select 0, '0', Tipo, '0', 'Arquivos', 'Arquivos', 'file', 'danger', DataHora,'','', arquivos.sysActive, '' from arquivos WHERE provider <> 'S3' AND Tipo='A' AND PacienteID="&PacienteID&" GROUP BY date(DataHora) ) "
    end if
                 cont=0

    sql = "select t.* from ( (select 0 Prior, '' id, '' Modelo, '' sysUser, '' Tipo, '' Titulo, '' Icone, '' cor, '' DataHora, '' Conteudo,'' Assinado, '' sysActive, '' MemedID limit 0) "&_
                sqlAE & sqlL & sqlPrescricao & sqlDiagnostico & sqlAtestado & sqlTarefa & sqlPedido & sqlProtocolos & sqlImagens & sqlArquivos &_
                ") t "&sqlProf&" ORDER BY Prior DESC, DataHora DESC "&SqlLimit
    'response.write(sql)
             set ti = db.execute( sql )
             while not ti.eof
                 Ano = year(ti("DataHora"))
                 if UltimoAno<>Ano then
                    abreAno = "          <div class=""timeline-divider mtn hidden-xs"">            <div class=""divider-label"">"&Ano&"</div>          </div>          <div class=""row"">          <div class=""col-sm-6 right-column"">"
                    if cont>0 then
                        abreAno = "</div></div>" & abreAno
                    end if
                 else
                    abreAno = ""
                 end if
                 UltimoAno = Ano

                'response.write( abreAno )

                cont = cont + 1
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
                if true then
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
                tipocompartilhamento = 0

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

            if exibe=0 then
                PermissaoArquivo=false
            end if

            ' Verifica se o registro foi feito por um profissional
            ' que pertence ao Care Team do paciente, permitindo a exibição
            if (autCareTeam(ti("sysUser"), PacienteID)) then
                PermissaoArquivo=true
            end if

            if not PermissaoArquivo then
    
                hiddenRegistro = ""

                if SinalizarFormulariosSemPermissao&""<>"1" then
                    hiddenRegistro = " hidden "
                end if
            
                %>
            <div class="timeline-item <%=hiddenRegistro%>">
                <div class="timeline-icon hidden-xs">
                    <span class="far fa-lock text-danger"></span>
                </div>
                <div class="panel">
                    <div class="panel-heading">
                        <span class="panel-title panel-warning">
                            <span class="far fa-align-justify"></span>
                            <% if ti("sysUser")<>0 then response.write( nameInTable(ti("sysUser")) ) end if %>
                            <code><%=ti("Titulo") %></code>
                        </span>

                        <div class="panel-header-menu pull-right mr10 text-muted fs12">
<%
                        if not isnull(ti("DataHora")) then
                            response.write( formatdatetime( ti("DataHora"), 2) &" - "& ft( ti("DataHora")) )
                        end if
%>  
                        </div>
                    </div>
                </div>
            </div>
            <%
            end if

            ItemInativo = ""
            CheckInativo = "checked="""""
            TextoInativo = ""
            if ti("sysActive")="-1" then
                ItemInativo="timeline-item-inativo"
                TextoInativo="<div class=""inativo-marca"">INATIVO!</div>"
                CheckInativo=""
            end if

            if PermissaoArquivo then
            'response.write tipoCompartilhamento
            %>
            <div class="timeline-item <%=ItemInativo%>">
                <div class="timeline-icon hidden-xs">
                    <span class="far fa-<%=ti("icone") %> text-<%=ti("cor") %>"></span>
                </div>
                <div class="panel">
                    <div class="panel-heading">
                        <span class="panel-title panel-warning">
                            <%
                            if ti("Tipo")="AE" or ti("Tipo")="L" then
                                if ccur(ti("Prior"))="1" then
                                    %>
                                    <i style="cursor:default" title="Desmarcar como favorito" class="far fa-star text-warning"></i>
                                    <%
                                else

                                end if
                            end if
                            %>
                            <span class="far fa-align-justify"></span>
                            <%
                            if ti("sysUser")<>0 then
                                response.write( nameInTable(ti("sysUser")) )
                            end if
                            titulo = ti("Titulo")
                            if len(titulo)>30 then
                                titulo = left(titulo, 40)&"..."
                            end if

                            response.write("<code>"&titulo&"</code>")
                            %>
                        </span>
                        <%
                        if OcultarBtn<>"1" then
                        %>
                        <span class="panel-controls hidden-xs">
                            <%
                            'and aut("prescricoesX")>0 and (ti("Tipo")<>"AE" and ti("Tipo")<>"L")
                            if cstr(session("User"))=ti("sysUser")&""  then
                            %>
                                <a title="Compartilhamento" data-toggle="dropdown"  aria-haspopup="true" aria-expanded="false">
                                    <i class="far fa-share-alt "></i>
                                </a>
                                <ul class="dropdown-menu pull-right" role="menu" >
                                    <li>
                                        <a <% if tipoCompartilhamento = 1  then %> class="dropdown-item-selected compartilhamentoSelect" <% end if %> href="javascript:saveCompartilhamento(1,'<%=ti("Tipo") %>',<%=ti("id") %>,<%=session("idInTable") %>)" > <i class="far fa-users"></i> Publico </a>
                                    </li>
                                    <li>
                                        <a <% if tipoCompartilhamento = 2  then %> class="dropdown-item-selected compartilhamentoSelect" <% end if %> href="javascript:saveCompartilhamento(2,'<%=ti("Tipo") %>',<%=ti("id") %>,<%=session("idInTable") %>)" ><i class="far fa-lock"></i> Privado</a>
                                    </li>
                                    <li>
                                        <a <% if tipoCompartilhamento = 3  then %> class="dropdown-item-selected compartilhamentoSelect" <% end if %> href="javascript:compartilhamentoRestrito('<%=ti("Tipo") %>',<%=ti("id") %>,<%=session("idInTable") %>)" ><i class="far fa-eye-slash"></i> Restrito</a>
                                    </li>
                                        <li class="divider"></li>
                                    <li>
                                        <a <% if tipoCompartilhamento = 0  then %> class="dropdown-item-selected compartilhamentoSelect" <% end if %> href="javascript:saveCompartilhamento(0,'<%=ti("Tipo") %>',<%=ti("id") %>,<%=session("idInTable") %>)" > <i class="far fa-asterisk"></i> Padrão </a>
                                    </li>
                                </ul>
                            <%
                            end if

                            Assinado=""
                            if ti("Assinado")&"" <> "" then
                                Assinado = "assinado"
                            end if

                            ' Botões Prescrição Memed
                            if ti("MemedID")<>"" and (ti("Tipo")="Prescricao" or ti("Tipo")="Pedido") then
                                sqlMemed = "SELECT * FROM memedv2_prescricoes WHERE memed_id = '" & ti("MemedID") & "'"
                                set rsMemed = db.execute(sqlMemed)
                            %>
                                <% if cstr(session("User"))=ti("sysUser")&"" then %>
                                    <a href="javascript:viewPrescricaoMemed(<%=ti("MemedID")%>, '<%=rsMemed("tipo")%>')">
                                        <i class="far fa-search-plus"></i>
                                    </a>
                                <% end if %>
                                <%
                                if not rsMemed.eof then
                                    if rsMemed("link_pdf_completo") <> "" then
                                %>
                                    <a href="<%=rsMemed("link_pdf_completo")%>" target="_blank">
                                        <i class="far fa-print"></i>
                                    </a>
                                    <%
                                    end if
                                    if cstr(session("User"))=ti("sysUser")&"" and aut("prescricoesX")>0  then %>
                                        <a href="javascript:deletePrescricaoMemed(<%=ti("id") %>, '<%=rsMemed("tipo")%>')">
                                            <i class="far fa-remove"></i>
                                        </a>
                                <%
                                    end if
                                end if
                                rsMemed.close
                                set rsMemed = nothing
                                %>
                            <%
                            else

                                if ti("Tipo") = "PedidosSADT" or ti("Tipo") = "Pedido" then %>
                                    <a class='' href="javascript:modalInsuranceAttachments(<%=PacienteID%>, <%=ti("id")%>);" title='Anexar um arquivo'><i class="far fa-paperclip"></i></a>
                                <% end if

                                if (ti("sysUser")<2 or cstr(session("User"))=ti("sysUser")&"" or lcase(session("Table"))="funcionarios") and recursoUnimed=4 then
                                %>
                                <a title="Ver mais" href="javascript:iPront('<%=ti("Tipo") %>', <%=PacienteID%>, '<%=ti("Modelo")%>', <%=ti("id") %>, '<%=Assinado%>');">
                                    <i class="far fa-search-plus"></i>
                                </a>

                                <%
                                elseif recursoUnimed<>4 then

                                    if ti("Tipo")<>"Imagens" then
                                    %>
                                    <a href="javascript:iPront('<%=ti("Tipo") %>', <%=PacienteID%>, '<%=ti("Modelo")%>', <%=ti("id") %>, '<%=Assinado%>');">
                                        <i class="far fa-search-plus"></i>
                                    </a>
                                        <%
                                    end if
                                    if ti("Tipo")<>"AE" and ti("Tipo")<>"L" and ti("Tipo")<>"Imagens" then
                                    %>
                                        <a title="Imprimit" href="javascript:prontPrint('<%=ti("Tipo") %>', <%=ti("id") %>);">
                                            <i class="far fa-print"></i>
                                        </a>
                                    <%
                                    elseif ti("Tipo")="Imagens" then

                                        set ArquivosSQL = db.execute("select GROUP_CONCAT(id) AS IDs from arquivos where date(DataHora)='"&left(ti("DataHora"),10)&"' AND Tipo='I' AND PacienteID="&PacienteID)
                                            arquivosID = ArquivosSQL("IDs")
                                        ArquivosSQL.close
                                        set ArquivosSQL = nothing
                                        %>
                                            <a title="Imprimir" href="./timelinePrint.asp?Tipo=I&IDs=<%=arquivosID%>" target="_blank">
                                                <i class="far fa-print"></i>
                                            </a>
                                    <%
                                    end if
                                end if
                            end if

                            set perm = db.execute("select Permissoes from buipermissoes where FormID='"&ti("Modelo")&"'")
                            if not perm.eof then
                                var_permissoes  = perm("Permissoes")
                            else
                                var_permissoes = ""
                            end if

                            if (ti("Tipo") = "AE" or ti("Tipo") = "L") or (ti("Tipo") = "Atestado" and aut("|atestadoX|")) or (ti("Tipo") = "Prescricao" and aut("|prescricaoX|"))  or (ti("Tipo") = "Pedido" and aut("|pedidosexamesX|")) or (ti("Tipo") = "Diagnostico" and aut("|diagnosticosX|"))  then
                                if True then
                            %>
                                <div title="Inativar" class="switch switch-sm switch-system switch-inline" style="position:relative;top: 6px;">
                                    <input <%=CheckInativo%>  name="TimelineRegistroAtivo" class="InativarRegistroTimeline" onchange="toogleInativarRegistroTimeline(this)" data-recurso="<%=ti("Tipo")%>" data-recurso-id="<%=ti("id")%>" id="TimelineRegistroAtivo<%=ti("id")%>" type="checkbox">
                                    <label style="height:22px" class="mn" for="TimelineRegistroAtivo<%=ti("id")%>"></label>
                                </div>
                            <%
                                end if
                            elseif cstr(session("User"))=ti("sysUser")&"" and ( aut("prescricoesX")>0 or instr(var_permissoes, "XP")>0 ) and ti("MemedID") = "" then %>
                                <a href="javascript:if(confirm('Tem certeza de que deseja apagar esta prescrição?'))pront('timeline.asp?PacienteID=<%= PacienteID %>&Tipo=|<%= ti("Tipo") %>|&X=<%= ti("id") %>');">

                                    <i class="far fa-trash"></i>
                                </a>
                            <% end if %>
                        </span>
                        <%
                        end if
                        %>

                        <div class="panel-header-menu pull-right mr10 text-muted fs12">
                        <% if Assinado <> "" then %>
                            <i class="far fa-shield" style=" color:orange;"></i>
                        <%end if%>
                        <%
                            if not isnull(ti("DataHora")) then
                                response.write( formatdatetime( ti("DataHora"), 2) &" - "& ft( ti("DataHora")) )
                            end if
                            %> </div>
                    </div>
                    <%=TextoInativo%>
                    <div class="panel-body timelineApp sensitive-data" style="text-align:justify; <% if device()<>"" then %> overflow-x:scroll!important; <% end if %>" >
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
                                        sqlCampos="select * from buicamposforms where FormID="&ti("Modelo")&" and TipoCampoID NOT IN(7,10,11,12,15) ORDER BY IF(Ordem=0, 999, Ordem), pTop, pLeft"

                                        set pcampos = db.execute(sqlCampos)
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
                                                    imgHTML=""
                                                    if Valor<>"" then
                                                    set ImagemSQL = db.execute("SELECT a.NomeArquivo,a.NomePasta FROM arquivos a WHERE a.NomeArquivo LIKE '"&Valor&"'")
                                                        if not ImagemSQL.eof then
                                                            imgHTML = "<img src='"&imgSRC(ImagemSQL("NomePasta"),ImagemSQL("NomeArquivo"))&"&dimension=full' class='mw140 mr25 mb20'>"
                                                        end if
                                                    ImagemSQL.close
                                                    set ImagemSQL = nothing
                                                    %>
                                                    <div class="media-body">
                                                        <b><%=Rotulo %></b><br />
                                                        <%=imgHTML%>
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

                                                    IF urlbmj <> "" and pcampos("enviardadoscid") = 1 THEN
                                                        sqlBmj = " (SELECT GROUP_CONCAT(DISTINCT CONCAT('<BR><strong>BMJ:</strong> <a href=""[linkbmj]/',bmj.codbmj,'"" target=""_blank"" class=""badge badge-primary"">',if(bmj.PortugueseTopicTitle='0',bmj.TopicTitle,bmj.PortugueseTopicTitle),'</a>') SEPARATOR ' ') " &_
                                                                " FROM cliniccentral.cid10_bmj bmj" &_
                                                                " WHERE bmj.cid10ID = cliniccentral.cid10.id)"
                                                    ELSE
                                                        sqlBmj = "''"
                                                    END IF
                                                    sqlBmj = "COALESCE("&sqlBmj&",'') as bmj_link "
                                                    set pcid = db.execute("select *, "&sqlBmj&" from cliniccentral.cid10 where id = '"&Valor&"'")
                                                    if not pcid.eof then
                                                        NomeCid = pcid("Codigo") &" - "& pcid("Descricao") &" "& replace(pcid("bmj_link")&"","[linkbmj]",urlbmj)
                                                    end if
                                                    response.Write( Rotulo &"<br>"& NomeCid &"<br>" )
                                                case else
                                                    if Valor<>"" and Valor<>"<p><br></p>" then
                                                    if left(Valor, 5)="{\rtf" then
                                                            'problema de conversao de RTF com problema critico
                                                            'call limpa("_"&ti("Modelo"), pcampos("id"), reg("id"))

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
                        if ti("MemedID")<>"" then
                            sqlPrescricaoMemed    = "SELECT pm.tipo, pm.nome, pm.posologia, pm.tipo_exame_selecionado, pm.exames_sus_codigo, pm.exames_tuss_codigo " &_
                                                    "FROM memedv2_prescricoes p " &_
                                                    "INNER JOIN memedv2_prescricoes_medicamentos pm ON pm.prescricao_id = p.id " &_
                                                    "WHERE p.memed_id = '" & ti("MemedID") & "' AND p.tipo = 'exame'"
                            set rsPrescricaoMemed = db.execute(sqlPrescricaoMemed)
                            memedCount = 1
                            %>
                            <ul class="memed-items">
                                <%
                                    while not rsPrescricaoMemed.eof
                                        memedTipo       = rsPrescricaoMemed("tipo")
                                        memedNome       = rsPrescricaoMemed("nome")
                                        memedPosologia  = rsPrescricaoMemed("posologia")
                                        memedTipoExame  = rsPrescricaoMemed("tipo_exame_selecionado")
                                        memedTuss       = rsPrescricaoMemed("exames_tuss_codigo")
                                        memedSus        = rsPrescricaoMemed("exames_sus_codigo")
                                %>
                                    <li class="item" data-tipo="<%=memedTipo%>">
                                        <p class="nome">
                                            <strong>
                                                <%=memedCount%>. <%=memedNome%>
                                            </strong>
                                            <span class="quantidade">
                                                <% if memedTipoExame = "tuss" and memedTuss <> "" then %>
                                                TUSS: <%=memedTuss%>
                                                <% end if %>
                                                <% if memedTipoExame = "sus" and memedSus <> "" then %>
                                                SUS: <%=memedSus%>
                                                <% end if %>
                                        </p>
                                        <div class="posologia"><%=memedPosologia%></div>
                                    </li>
                                <%
                                    rsPrescricaoMemed.movenext
                                    memedCount = memedCount + 1
                                wend
                                rsPrescricaoMemed.close
                                set rsPrescricaoMemed = nothing
                                %>
                            </ul>
                            <%
                        else
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
                        end if
                    case "Diagnostico", "Prescricao", "Atestado", "Tarefas"
                            if ti("MemedID")<>"" then
                                sqlPrescricaoMemed = "SELECT pm.tipo, pm.nome, pm.descricao, pm.posologia, pm.quantidade, pm.unit, pm.composicao " &_
                                                     "FROM memedv2_prescricoes p " &_
                                                     "INNER JOIN memedv2_prescricoes_medicamentos pm ON pm.prescricao_id = p.id " &_
                                                     "WHERE p.memed_id = '" & ti("MemedID") & "' AND p.tipo = 'prescricao'"
                                set rsPrescricaoMemed = db.execute(sqlPrescricaoMemed)
                                memedCount = 1
                                %>
                                <ul class="memed-items">
                                    <%
                                        while not rsPrescricaoMemed.eof
                                            memedTipo       = rsPrescricaoMemed("tipo")
                                            memedNome       = rsPrescricaoMemed("nome")
                                            memedComposicao = rsPrescricaoMemed("composicao")
                                            memedDescricao  = rsPrescricaoMemed("descricao")
                                            memedPosologia  = rsPrescricaoMemed("posologia")
                                            memedQuantidade = rsPrescricaoMemed("quantidade")
                                            memedUnit       = rsPrescricaoMemed("unit")
                                    %>
                                        <li class="item" data-tipo="<%=memedTipo%>">
                                            <p class="nome">
                                                <strong>
                                                    <%=memedCount%>.
                                                    <% if memedTipo = "manipulado" then
                                                        response.write("Fórmula")
                                                    else
                                                        response.write(memedNome)
                                                    end if
                                                    %>
                                                </strong>
                                                <span class="quantidade">
                                                    <% if memedQuantidade <> 0 then response.write(memedQuantidade) end if%>
                                                    <%=" " & memedUnit%></span>
                                            </p>
                                            <% if memedTipo <> "homeopático" then %>
                                            <div class="composicao">
                                                <%
                                                if memedComposicao <> "" then
                                                    response.write(memedComposicao)
                                                else
                                                    response.write(memedDescricao)
                                                end if
                                                %>
                                            </div>
                                            <% end if %>
                                            <div class="posologia"><%=memedPosologia%></div>
                                        </li>
                                    <%
                                        rsPrescricaoMemed.movenext
                                        memedCount = memedCount + 1
                                    wend
                                    rsPrescricaoMemed.close
                                    set rsPrescricaoMemed = nothing
                                    %>
                                </ul>
                                <%
                            else
                                IF urlbmj <> "" THEN
                                    response.Write("<small>" & replace(ti("Conteudo")&"","[linkbmj]",urlbmj) & "</small>")
                                ELSE
                                    response.Write("<small>" & ti("Conteudo") & "</small>")
                                END IF
                            end if
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
                    case "Protocolos"
                        set getProtocolos = db.execute("SELECT NomeProtocolo, GROUP_CONCAT(IFNULL(NomeProduto, '') SEPARATOR ', ') Produtos "&_
                                                       "FROM pacientesprotocolosmedicamentos ppm "&_
                                                       "LEFT JOIN protocolos prot ON prot.id=ppm.ProtocoloID "&_
                                                       "LEFT JOIN protocolosmedicamentos pm ON ppm.ProtocoloMedicamentoID=pm.id "&_
                                                       "LEFT JOIN produtos prod ON prod.id=COALESCE(pm.Medicamento, ppm.MedicamentoPrescritoID) "&_
                                                       "WHERE ppm.PacienteProtocoloID="&ti("id")&" GROUP BY ppm.ProtocoloID")

                        while not getProtocolos.eof
                            %>
                            <%= "<b>"&getProtocolos("NomeProtocolo")&"</b>: <br />"&getProtocolos("Produtos") %><br /><br />
                            <%
                        getProtocolos.movenext
                        wend
                        getProtocolos.close
                        set getProtocolos = nothing
                    case "Imagens"
                        if aut("ImagensV") = 1 then
                        %>
                        <div class="row">
                            <%
                                set im = db.execute("select * from arquivos where date(DataHora)="&mydatenull(ti("DataHora"))&" AND Tipo='I' AND PacienteID="&PacienteID)
                                while not im.eof
                                    'default pode ver, porém se não pertence ao CareTeam irá verificar a permissão da imagem
                                    podever = true
                                    if not autCareTeam(im("sysUser"), PacienteID) then
                                        permissao = VerificaProntuarioCompartilhamento(im("sysUser"), ti("Tipo"), im("id"))
                                        if permissao <> "" then
                                            permissaoSplit = split(permissao,"|")
                                            podever = permissaoSplit(0)
                                        end if
                                    end if

                                    if podever then
                                    %>
                                        <span>
                                        <% if ComEstilo = "S" then %>
                                                <img style="height:150px; width:150px" id-img-arquivos="<%=im("id") %>" src="<%=arqEx(im("NomeArquivo"), "Imagens")%>" class="img-thumbnail" title="<%=im("Descricao") %>" alt="<%=im("Descricao") %>">
                                        <% else %>
                                            <a class="gallery-item" href="<%=arqEx(im("NomeArquivo"), "Imagens")%>" target="_blank">
                                                <img style="height:150px; width:150px" id-img-arquivos="<%=im("id") %>" src="<%=arqEx(im("NomeArquivo"), "Imagens")%>" class="img-thumbnail" title="<%=im("Descricao") %>" alt="<%=im("Descricao") %>">
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
                        end if
                    case "Arquivos"
                            %>
                       <div class="row">
                         <%
                            set im = db.execute("select * from arquivos where date(DataHora)="&mydatenull(ti("DataHora"))&" AND Tipo='A' AND PacienteID="&PacienteID)
                            while not im.eof
                                podever = true
                                'default pode ver, porém se não pertence ao CareTeam irá verificar a permissão do arquivo
                                if not autCareTeam(im("sysUser"), PacienteID) then
                                    permissao = VerificaProntuarioCompartilhamento(im("sysUser"), ti("Tipo"), im("id"))
                                    if permissao <> "" then
                                        permissaoSplit = split(permissao,"|")
                                        podever = permissaoSplit(0)
                                    end if
                                end if

                                if podever then
                                %>
                                    <div class="col-xs-2 mb10" style="min-width:150px;">
                                        <div class="panel-tile text-center br-a br-light" >
                                            <div class="panel-body bg-light dark">
                                            <% if ComEstilo = "S" then %>
                                                    <h1 class="fs35 mbn"><i class="far fa-file-text"></i></h1>
                                            <% else %>
                                                <a href="<%=arqEx(im("NomeArquivo"), "Arquivos")%>" target="_blank">
                                                    <h1 class="fs35 mbn"><i class="far fa-file-text"></i></h1>
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

                 ' if c>0 then
                   ' response.Write("</div></div>             <div class=""timeline-divider"">            <div class=""divider-label"">"&Ano&"</div>          </div>")
                 ' end if
              %>