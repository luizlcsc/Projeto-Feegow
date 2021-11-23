<!--#include file="connect.asp"-->
<div class="mt10 panel">
    <div class="panel-body">
<%
idTipo = req("idTipo")
Tipo = req("Tipo")
ConteudoProposta = ""

set vcaConf = db.execute("SELECT * FROM email_config WHERE Usuarios LIKE '%|"& session("User") &"|%' OR Usuarios LIKE '%|ALL|%' LIMIT 1")
if vcaConf.eof then
    response.write("Não há contas de e-mail configuradas para este usuário.")
    response.end
else
    SMTP = vcaConf("SMTP")
    EmailDe = vcaConf("Email")
    NomeDe = vcaConf("Nome")
    Senha = vcaConf("Senha")
    PortaSMTP = vcaConf("PortaSMTP")
end if

function SendMailMarketing(Para, Titulo, Mensagem)

	Set objCDOSYSMail = Server.CreateObject("CDO.Message") 
	Set objCDOSYSCon = Server.CreateObject ("CDO.Configuration") 
	objCDOSYSCon.Fields("http://schemas.microsoft.com/cdo/configuration/smtpserver") = SMTP
	objCDOSYSCon.Fields("http://schemas.microsoft.com/cdo/configuration/sendusername") = EmailDe
	objCDOSYSCon.Fields("http://schemas.microsoft.com/cdo/configuration/sendpassword") = Senha
	objCDOSYSCon.Fields("http://schemas.microsoft.com/cdo/configuration/smtpserverport") = PortaSMTP
	'objCDOSYSCon.Fields.Item("http://schemas.microsoft.com/cdo/configuration/smtpusessl") = True
	objCDOSYSCon.Fields("http://schemas.microsoft.com/cdo/configuration/sendusing") = 2
	objCDOSYSCon.Fields("http://schemas.microsoft.com/cdo/configuration/smtpconnectiontimeout") = 60 
	objCDOSYSCon.Fields("http://schemas.microsoft.com/cdo/configuration/smtpauthenticate") = 1
	objCDOSYSCon.Fields.update 
	Set objCDOSYSMail.Configuration = objCDOSYSCon 
	objCDOSYSMail.From = DeNome & "<orcamentos@consultare.com.br>"
	objCDOSYSMail.ReplyTo = EmailDe
	objCDOSYSMail.To = Para
	'objCDOSYSMail.cc = lcase(pPai("Email2"))
	objCDOSYSMail.Subject = Titulo
	objCDOSYSMail.HtmlBody = "<html> <head><meta http-equiv=""Content-Type"" content=""text/html;charset=utf-8""></head><body>"& Mensagem &"</body></html>"
	objCDOSYSMail.Send
	
	Set objCDOSYSMail = Nothing 
	Set objCDOSYSCon = Nothing 

    db.execute("INSERT INTO email_enviados (sysUser, De, Para, Titulo, Texto) VALUES ("& session("User") &", '"& EmailDe &"', '"& Para &"', '"& Titulo &"', '"& Mensagem &"')")

end function



if instr(ref("Para"), "@") then

    call SendMailMarketing(trim(ref("Para")), ref("Assunto"), ref("Mensagem"))

else

    if Tipo<>"" then
        set modelo = db.execute("SELECT * FROM email_modelos WHERE Tipo='"& Tipo &"'")
        if not modelo.eof then
            Assunto = modelo("Titulo")
            Mensagem = modelo("Texto")
        end if

        if Tipo="Proposta" then
            PropostaID = idTipo
            set prop = db.execute("select prop.PacienteID, pac.Email1 FROM propostas prop INNER JOIN pacientes pac ON pac.id=prop.PacienteID WHERE prop.id="& PropostaID )
            if not prop.eof then
                PacienteID = prop("PacienteID")
                Para = prop("Email1")
            end if
            '-> MONTANDO A PROPOSTA
            if req("Agrupada")="1" then
                itensSql = "SELECT T.*, Quantidade*ValorUnitario+(Quantidade*Acrescimo)-(Quantidade*Desconto) AS total "&_
                    " FROM ( "&_
                    " SELECT MAX(ii.Prioridade) AS Prioridade, group_concat(proc.NomeProcedimento SEPARATOR ', ') AS NomeProcedimento, sum(ii.ValorUnitario) AS ValorUnitario, 1 AS Quantidade, sum(ii.Acrescimo) AS Acrescimo, sum(ii.Desconto) AS Desconto,ii.TipoDesconto AS TipoDesconto,proc.DiasLaudo AS DiasLaudo,prop.TabelaID AS Tabela "&_
                    " FROM itensproposta ii "&_
                    " LEFT JOIN procedimentos proc ON proc.id=ii.ItemID "&_
                    " LEFT JOIN propostas prop ON prop.id=ii.PropostaID "&_
                    " WHERE ii.PropostaID="& PropostaID &_
                    " GROUP BY proc.GrupoID "&_
                    " ORDER BY Prioridade DESC, ii.id ASC) AS T"
            else
                itensSql = "SELECT T.*,Quantidade*ValorUnitario+(Quantidade*Acrescimo)-(Quantidade*Desconto) as total FROM ("&_
                    "SELECT "&_
                    "         MAX(ii.Prioridade)    AS Prioridade"&_
                    "        ,proc.NomeProcedimento AS NomeProcedimento"&_
                    "        ,ii.ValorUnitario      AS ValorUnitario"&_
                    "        ,SUM(ii.Quantidade)    AS Quantidade"&_
                    "        ,ii.Acrescimo          AS Acrescimo"&_
                    "        ,ii.Desconto           AS Desconto"&_
                    "        ,ii.TipoDesconto       AS TipoDesconto"&_
                    "        ,proc.DiasLaudo        AS DiasLaudo"&_
                    "        ,prop.TabelaID         AS Tabela"&_
                    "      FROM itensproposta ii"&_
                    " LEFT JOIN procedimentos proc  on proc.id=ii.ItemID "&_
                    " LEFT JOIN propostas prop       on prop.id=ii.PropostaID "&_
                    " WHERE ii.PropostaID="&PropostaID&" "&_
                    " GROUP BY proc.NomeProcedimento, ValorUnitario, proc.NomeProcedimento,Acrescimo,Desconto "&_
                    " ORDER BY Prioridade DESC, ii.id ASC "&_
                    ") AS T"
            end if





            set itens = db.execute(itensSql)
            if not itens.eof then

                if itens("Tabela")&"" <> "0" then
                    set tabelaPrivadaSQL = db.execute("select NomeTabela from tabelaparticular where id ="&treatvalzero(itens("Tabela")))
                    if not tabelaPrivadaSQL.eof then
                        nometabela = "<br>("&tabelaPrivadaSQL("nometabela")&")"
                    end if
                end if

                ConteudoProposta = ConteudoProposta &"<h3>Serviços</h3>"
                ConteudoProposta = ConteudoProposta &"<table style=""text-align: center"" width=""100%"" class=""table table-striped table-condensed"">"
                ConteudoProposta = ConteudoProposta &"<thead><tr>"
                IF getConfig("ExibirPrioridadeDePropostas") THEN
                    ConteudoProposta = ConteudoProposta &"<th class="""& hiddenValor &""">Prioridade</th>"
                END IF
                ConteudoProposta = ConteudoProposta &"<th style=""text-align: center"">Qtd</th>"
                ConteudoProposta = ConteudoProposta &"<th style=""text-align: center"">Descrição</th>"
                ConteudoProposta = ConteudoProposta &"<th style=""text-align: right"" align=""right"" class="""& hiddenValor &""">"
                IF getConfig("ExibirValorUnitario") = "1" THEN
                    ConteudoProposta = ConteudoProposta &"Valor Unitário"
                END IF
                ConteudoProposta = ConteudoProposta &"</th><th style=""text-align: right"" align=""right"" class="""& hiddenValor &""">"
                IF getConfig("ExibirDesconto") = "1" THEN
                    ConteudoProposta = ConteudoProposta &"Desconto Unitário "& nometabela
                END IF
                ConteudoProposta = ConteudoProposta &"</th><th style=""text-align: right"" align=""right"" class="""& hiddenValor &""">"
                IF getConfig("ExibirDesconto") = "1" THEN
                    ConteudoProposta = ConteudoProposta &"Desconto Total "& nometabela
                END IF
                ConteudoProposta = ConteudoProposta &"</th><th style=""text-align: right"" align=""right"" class="""& hiddenValor &""">"
                IF getConfig("ExibirValorTotal") = "1" THEN
                    ConteudoProposta = ConteudoProposta &"Valor Total"
                END IF
                ConteudoProposta = ConteudoProposta &"</th></tr></thead><tbody>"

                Qtd = 0
                TotalTotal = 0
                TotalDesconto = 0

                ExibirValorTotal=getConfig("ExibirValorTotal")
                ExibirDesconto=getConfig("ExibirDesconto")
                ExibirValorUnitario=getConfig("ExibirValorUnitario")
                ExibirPrioridadeDePropostas=getConfig("ExibirPrioridadeDePropostas")

                while not itens.EOF
                    TabelaID = itens("Tabela")&""
                    Desconto = itens("Desconto")
                    Acrescimo = itens("Acrescimo")
                    Prioridade = itens("Prioridade")
                    if itens("TipoDesconto")="P" then
                        Desconto = itens("Desconto") /100 * itens("ValorUnitario")
                    end if
                    ValorUnitarioSemDesconto = itens("ValorUnitario")
                    ValorUnitario = itens("ValorUnitario")-Desconto+Acrescimo
                    Total = ValorUnitario*itens("Quantidade")
                    Qtd = Qtd+itens("Quantidade")
                    DescontoQtd = Desconto*itens("Quantidade")

                    if Desconto&""<>"" then
                        TotalDesconto = TotalDesconto + (Desconto * itens("Quantidade"))
                    end if

                    TotalTotal = TotalTotal+Total
                    ConteudoProposta = ConteudoProposta &"<tr>"
                    IF ExibirPrioridadeDePropostas THEN
                        ConteudoProposta = ConteudoProposta &"<td class="""& hiddenValor &""">"& prioridadeList.Item(itens("Prioridade")&"") &"</td>"
                    END IF
                    ConteudoProposta = ConteudoProposta &"<td>"& itens("Quantidade")&"</td>"
                    ConteudoProposta = ConteudoProposta &"<td>"& itens("NomeProcedimento") &"</td>"
                    ConteudoProposta = ConteudoProposta &"<td class="""& hiddenValor &""" align=""right"">"
                    IF ExibirValorUnitario = "1" THEN
                        ConteudoProposta = ConteudoProposta &"R$ "& formatnumber(ValorUnitarioSemDesconto,2)
                    END IF
                    ConteudoProposta = ConteudoProposta &"</td>"
                    ConteudoProposta = ConteudoProposta &"<td class="""& hiddenValor &""" align=""right"">"
                    IF ExibirDesconto = "1" THEN
                        ConteudoProposta = ConteudoProposta &"R$ "& formatnumber(Desconto,2)
                    END IF
                    ConteudoProposta = ConteudoProposta &"</td>"
                    ConteudoProposta = ConteudoProposta &"<td class="""& hiddenValor &""" align=""right"">"
                    IF ExibirDesconto = "1" THEN
                        ConteudoProposta = ConteudoProposta &"R$ "& formatnumber(DescontoQtd,2)
                    END IF
                    ConteudoProposta = ConteudoProposta &"</td><td class="""& hiddenValor &""" align=""right"">"
                    IF ExibirValorTotal = "1" THEN
                        ConteudoProposta = ConteudoProposta &"R$ "& formatnumber(Total,2)
                    END IF
                    ConteudoProposta = ConteudoProposta &"</td></tr>"
                    itensPrazoEntrega = itens("DiasLaudo")

                    if isnumeric(itensPrazoEntrega) then
                        if itensPrazoEntrega > PrazoEntrega then
                            PrazoEntrega = itensPrazoEntrega
                        end if
                    end if
                itens.movenext
                wend
                itens.close
                set itens=nothing

                ConteudoProposta = ConteudoProposta &"</tbody><tfoot><tr><th align=""left"" colspan="""
                IF ExibirPrioridadeDePropostas=0 THEN
                    ConteudoProposta = ConteudoProposta &"3"
                else
                    ConteudoProposta = ConteudoProposta &"4"
                end if
                ConteudoProposta = ConteudoProposta &""">"& Qtd &" ite"
                if Qtd>1 then
                    ConteudoProposta = ConteudoProposta &"ns"
                else
                    ConteudoProposta = ConteudoProposta &"m"
                end if
                ConteudoProposta = ConteudoProposta &"</th>"
                ConteudoProposta = ConteudoProposta &"<th style=""text-align: right"" class="""& hiddenValor &""" align=""right"">"
                IF ExibirDesconto = "1" THEN
                END IF
                ConteudoProposta = ConteudoProposta &"</th>"
                ConteudoProposta = ConteudoProposta &"<th style=""text-align: right"" class="""& hiddenValor &""" align=""right"">"
                IF ExibirDesconto = "1" THEN
                    ConteudoProposta = ConteudoProposta &"R$ "& formatnumber(TotalDesconto,2)
                END IF
                ConteudoProposta = ConteudoProposta &"</th>"
                ConteudoProposta = ConteudoProposta &"<th style=""text-align: right"" class="""& hiddenValor &""" align=""right"">"
                IF ExibirValorTotal = "1" THEN
                    ConteudoProposta = ConteudoProposta &"R$ "& formatnumber(TotalTotal,2)
                END IF
                ConteudoProposta = ConteudoProposta &"</th></tr></tfoot></table><br><br>"
            end if

            set formas = db.execute("select pp.Descricao,p.PacienteID from pacientespropostasformas pp "_
            &"LEFT JOIN propostas p ON p.id=pp.PropostaID "_
            &"WHERE pp.PropostaID="&PropostaID)

            if not formas.eof then
                ConteudoProposta = ConteudoProposta &"<h3>"& reg("TituloPagamento") &"</h3><table width=""100%"" class=""table table-striped table-condensed""><tbody>"
                while not formas.EOF
                    'Descricao = formas("Descricao")
                    Descricao = TagsConverte(formas("Descricao"),"PacienteID_"&formas("PacienteID"),"")
                    Descricao = replace(Descricao, chr(10), "<br>")
                    ConteudoProposta = ConteudoProposta &"<tr><td class="""& hiddenValor &""" width=""75%"">"& replacePagto(Descricao, TotalTotal) &"</td></tr>"
                formas.movenext
                wend
                formas.close
                set formas=nothing
                ConteudoProposta = ConteudoProposta &"</tbody></table><br><br>"
            end if








            '<- MONTANDO A PROPOSTA
        end if

        'Assunto = "Proposta Feegow Clinic"
        'Mensagem = "Prezado(a) sr(a). "& prop("NomePaciente") & "<br><br>Conforme conversado, envio proposta para implementação do melhor e mais completo software do mercado.<br><br> Para quaisquer esclarecimentos, coloco-me inteiramente à disposição.<br><br>Atenciosamente, <br> "& session("NameUser")
    end if

    'Para = prop("Email1")
    ''    if instr(prop("Email2"), "@") then
    ''    Para = Para &"; "& prop("Email2")
    'end if

    set pema = db.execute("select Email from cliniccentral.licencasusuarios where id="&session("User"))


    Mensagem = replaceTags(Mensagem&"", PacienteID, session("UserID"), session("UnidadeID"))
    Mensagem = Mensagem & ConteudoProposta
    %>

    <form id="frmEmail" method="post">
        <div class="modal-header">
            <h4 class="modal-title">Enviar proposta</h4>
        </div>
        <div class="modal-body">
                <div class="clearfix form-actions no-margin">
                    <%=quickfield("memo", "Para", "Para", 12, Para, "", "", " rows=1") %>
                    <%=quickfield("text", "Assunto", "Assunto", 12, Assunto, "", "", "") %>
                </div>
                <div class="row"><br>
                    <%=quickfield("editor", "Mensagem", " ", 12, Mensagem, "400", "", "") %>
                </div>

        </div>
        <div class="modal-footer">
            <button type="button" class="btn btn-default" data-dismiss="modal">Fechar</button>
            <button class="btn btn-primary"><i class="far fa-paper-plane"></i> Enviar</button>
        </div>
    </form>

    <script type="text/javascript">
    <!--#include file="jQueryFunctions.asp"-->
    </script>

    <%
end if
%>
    </div>
</div>

<script type="text/javascript">
    $(".crumb-active a").html("Envio de e-mail");
    $(".crumb-icon a span").attr("class", "far fa-paper-plane");
</script>