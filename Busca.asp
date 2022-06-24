<!--#include file="connect.asp"-->
<%
q = req("q")
%>

<script type="text/javascript">
        $(".crumb-active a").html("Resultados da Busca");
        $(".crumb-link").removeClass("hidden");
        $(".crumb-link").html("termo buscado: <em><%=q%></em>");
        $(".crumb-icon a").html("<i class='far fa-search'></i>");
        $("#sidebar-search").val("<%=q%>");
</script>
<%
'if isnumeric(q) and len(q)=6 then
'    set inv = db.execute("select id, CD from sys_financialinvoices where CD='C' and id="&q)
'    if not inv.eof then
'        response.redirect("./?P=invoice&I="&inv("id")&"&T=C&Pers=1&Scan=1")
'    end if
'elseif isnumeric(q) and len(q)=10 and left(q, 1)="2" then
' comentado para atender ao tk 13358

if isnumeric(q) and len(q)=10 and left(q, 1)="2" then
    'response.write(len(q))
    gsid = ccur(q)-2222222222
    set gs = db.execute("select id from tissguiasadt where id="& gsid)
    if not gs.eof then
        response.Redirect("./?P=tissguiasadt&Pers=1&I="& gsid)
    else
        response.write("GUIA N�O ENCONTRADA.")
    end if
elseif isnumeric(q) and len(q)=10 and left(q, 1)="1" then
    'response.write(len(q))
    gsid = ccur(q)-1111111111
    set gs = db.execute("select id from tissguiaconsulta where id="& gsid)
    if not gs.eof then
        response.Redirect("./?P=tissguiaconsulta&Pers=1&I="& gsid)
    else
        response.write("GUIA N�O ENCONTRADA.")
    end if
elseif isnumeric(q) and len(q)=10 and left(q, 1)="3" then
    'response.write(len(q))
    gsid = ccur(q)-3333333333
    set gs = db.execute("select id from tissguiahonorarios where id="& gsid)
    if not gs.eof then
        response.Redirect("./?P=tissguiahonorarios&Pers=1&I="& gsid)
    else
        response.write("GUIA N�O ENCONTRADA.")
    end if
end if

if trim(q)="" then
	erro = "Digite um termo para a busca."
elseif len(trim(q))<2 then
	erro = "Sua busca deve conter no m&iacute;nimo dois caracteres."
else
q = trim(q)
q = replace(replace(q, "'", ""), " ", "%")

isstr = True

if isdate(q) then
	sqlNasc = " OR Nascimento="& mydatenull(q) &" "
	isstr = False
end if

if isnumeric(q) then
	sqlBuscaCpf = " or CPF = '"&q&"'"
	sqlBuscaCelular = " or (Cel1 = '"&q&"' or Tel1 = '"&q&"')"
	sqlBuscaId = " or id = '"&q&"'"
	isstr = False
end if

	if PorteClinica > 3 and len(q)<MinimoCaracteresBuscaPaciente and TypeName(q)="String" then
		set contaPac = db_execute("select -1 as Pacientes")

	else
		IF PorteClinica > 3 THEN
			q = trim(request.QueryString("q"))
			q = replace(replace(q, "'", ""), " ", "%")

			q = replace(UCASE(q),UCASE("José%"),"José ")
			q = replace(UCASE(q),UCASE("Jose%"),"Jose ")
			q = replace(UCASE(q),UCASE("João%"),"João ")
			q = replace(UCASE(q),UCASE("Joao%"),"Joao ")
			q = replace(UCASE(q),UCASE("Maria%"),"Maria ")
			q = replace(UCASE(q),UCASE("María%"),"María ")
			q = replace(UCASE(q),UCASE("Mari%"),"Mari ")
			q = replace(UCASE(q),UCASE("Ana%"),"Ana ")
			q = replace(UCASE(q),UCASE("%Das%"),"%Das ")
			q = replace(UCASE(q),UCASE("%De%"),"%De ")
			q = replace(UCASE(q),UCASE("Antonio%"),"Antonio ")
			q = replace(UCASE(q),UCASE("Antônio%"),"Antônio ")
			q = replace(UCASE(q),UCASE("Francisco%"),"Francisco ")
			q = replace(UCASE(q),UCASE("Silva%"),"Silva ")

			if isstr then
				sqlBuscaNome = " OR NomePaciente like '"&q&"%' or NomeSocial like '"&q&"%'"
			end if

			set contaPac = db_execute("select count(*) as Pacientes from pacientes where sysActive=1 AND (FALSE "&sqlBuscaNome&" "& sqlBuscaCelular &sqlBuscaCPF&sqlBuscaID & sqlNasc &")")
		ELSE
			set contaPac = db_execute("select count(*) as Pacientes from pacientes where TRIM(NomePaciente) like '%"&q&"%' or TRIM(NomeSocial) like '%"&q&"%' or replace(replace(CPF,'.',''),'-','') like replace(replace('"&q&"%','.',''),'-','') or Tel1 like '%"&q&"%' or Tel2 like '%"&q&"%' or Cel1 like '%"&q&"%' or Cel2 like '%"&q&"%' or id = '"&q&"' or (idImportado = '"&q&"' and idImportado <>0)" & sqlNasc)
		END IF
	end if

	set contaPro = db.execute("select count(*) as Profissionais from profissionais where NomeProfissional like '%"&q&"%'"& sqlNasc)
	set contaFun = db.execute("select count(*) as Funcionarios from funcionarios where NomeFuncionario like '%"&q&"%'"& sqlNasc)
	set contaFor = db.execute("select count(*) as Fornecedores from fornecedores where sysActive=1 and NomeFornecedor like '%"&q&"%' or replace(replace(replace(CPF,'.',''),'-',''),'/','') like replace(replace(replace('"&q&"%','.',''),'-',''),'/','') ")
	set contaProc = db.execute("select count(*) as Procedimentos from procedimentos where sysActive=1 AND NomeProcedimento like '%"&q&"%' or Sigla LIKE '%"&q&"%' or Codigo LIKE '%"&q&"%'")
	set contaConv = db.execute("select count(*) as Convenios from convenios where sysActive=1 and NomeConvenio like '%"&q&"%'")
	set contaProd = db.execute("select count(*) as Produtos from produtos where sysActive=1 and NomeProduto like '%"&q&"%' or id = '"&q&"' ")
	set contaCont = db.execute("select count(*) as ContasCorrentes from sys_financialcurrentaccounts where AccountName like '%"&q&"%'")
	set contaContatos = db.execute("select count(*) as Contatos from contatos where NomeContato like '%"&q&"%'")
	Pacientes = ccur(contaPac("Pacientes"))
	Profissionais = ccur(contaPro("Profissionais"))
	Funcionarios = ccur(contaFun("Funcionarios"))
	Fornecedores = ccur(contaFor("Fornecedores"))
	Procedimentos = ccur(contaProc("Procedimentos"))
	Convenios = ccur(contaConv("Convenios"))
	Produtos = ccur(contaProd("Produtos"))
	ContasCorrentes = ccur(contaCont("ContasCorrentes"))
	Contatos = ccur(contaContatos("Contatos"))
	
	recursosBuscar = "Pacientes|"&Pacientes&"|pacientes|user, Profissionais|"&Profissionais&"|profissionais|user-md, Funcion&aacute;rios|"&Funcionarios&"|funcionarios|user, Fornecedores|"&Fornecedores&"|fornecedores|truck, Procedimentos|"&Procedimentos&"|procedimentos|stethoscope, Conv&ecirc;nios|"&Convenios&"|convenios|credit-card, Produtos|"&Produtos&"|produtos|medkit, Contas Correntes|"&ContasCorrentes&"|sys_financialcurrentaccounts|money, Contatos|"&Contatos&"|contatos|mobile-phone"
	spl = split(recursosBuscar, ", ")
	%>
            <%
			for i=0 to ubound(spl)
				spl2 = split(spl(i), "|")
				if ccur(spl2(1))>0 then
					if ativo = "" then
						ativo = spl2(2)
						classActive = " class='active'"
					else
						classActive = ""
					end if
					%>
                <script type="text/javascript">
                    $(".sidebar-label").after("<li<%=classActive%>><a data-toggle='tab' class='tab' id='tabExtrato' href='#divHistorico' onclick=\"ajxContent('<%=spl2(2)%>', '', 'Follow', 'divContent')\"><span class='far fa-<%=spl2(3)%>'></span><span class='sidebar-title'><%=spl2(0)%></span><span class='sidebar-title-tray'><span class='label label-xs bg-primary'><%= spl2(1) %></span></span></a></li>");
                    </script>
					<%
				end if
			next
				%>
	
			<div class="tab-content">
				<div id="divContent" class="tab-pane active">
					<div class="panel mt40">
					    <div class="panel-body">
                            <i class="far fa-circle-o-notch fa-spin"></i> Carregando...
                         </div>
                    </div>
				</div>

			</div>
	<%
    if aut("produtosV") and ativo="" then
        set prodBarcode = db.execute("select id from produtos where Codigo like '"&q&"'")
        if not prodBarcode.eof then
            response.redirect("./?P=Produtos&Pers=1&I="& prodBarcode("id"))
        end if
    end if
end if
if ativo="" then
	if erro="" then
		erro = "Nenhum registro encontrado com o termo '<em>"&q&"</em>'"
	end if
	%>
    <script language="javascript">
	$(".tab-content").hide();
	</script>
    <%
end if
if erro<>"" then
%>
<br>
<div class="alert alert-warning"><strong><i class="far fa-remove"></i> </strong> <strong><%=erro%></strong><br></div>
<%
else
%>
<script language="javascript">
$(document).ready(function(){
	ajxContent('<%=ativo%>', '', 'Follow', 'divContent');
});
</script>
<%
end if
%>
<!--#include file="disconnect.asp"-->