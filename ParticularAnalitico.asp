<!--#include file="connect.asp"-->
<div class="alert alert-danger hidden">
    <button class="close" data-dismiss="alert" type="button">
        <i class="far fa-remove"></i>
    </button>
    <strong><i class="far fa-warning-sign"></i>ATEN&Ccedil;&Atilde;O:</strong>
    Este relatório encontra-se em manutenção, o que poderá ocasionar inconsistência de dados. A liberação ocorrerá hoje, até as 20 horas.<br>
    <br>
    Atenciosamente,<br>
    Equipe Feegow Clinic
</div>
<%
DataDe = req("DataDe")
DataAte = req("DataAte")

if DataDe="" then
	DataDe = date()
end if
if DataAte="" then
	DataAte = date()
end if
%>
<h4>Caixa - Analítico</h4>
<form method="get" target="_blank" action="PrintStatement.asp">
    <input type="hidden" name="R" value="rParticularAnalitico">
    <div class="clearfix form-actions">
        <div class="row">
            <%=quickField("datepicker", "DataDe", "De", 3, DataDe, "", "", "")%>
            <%=quickField("datepicker", "DataAte", "At&eacute;", 3, DataAte, "", "", "")%>
            <div class="col-md-6">
                <div class="row">
                    <div class="col-md-12">
                        <label>Unidade</label><br>
                        <select multiple="" class="multisel" id="Unidades" name="Unidades">
                            <%
                    if instr(session("Unidades"), "|0|")>0 then
                            %>
                            <option selected value="0">Empresa principal</option>
                            <%
                    end if
                    set punits = db.execute("select * from sys_financialcompanyunits where sysActive=1 order by UnitName")
                    while not punits.eof
                        if instr(session("Unidades"), "|"&punits("id")&"|")>0 then
                            %>
                            <option selected value="<%=punits("id")%>"><%=punits("NomeFantasia")%></option>
                            <%
                        end if
                    punits.movenext
                    wend
                    punits.close
                    set punits=nothing
                            %>
                        </select>
                        <%'=session("Unidades")%><br>
                    </div>
                </div>
            </div>
        </div>
        <hr />
        <div class="row">
            <%= quickfield("multiple", "ProfissionalID", "Profissionais", 3, "", "(select '-1' id, 'Não executado' NomeProfissional, 1 as p ) UNION ALL (select id, NomeProfissional, 0 as p from profissionais where sysActive=1 and Ativo='on') order by p desc, NomeProfissional", "NomeProfissional", "") %>
            <%= quickfield("multiple", "ProfissionalExtID", "Profissionais externos", 3, "", "select id, NomeProfissional from profissionalexterno where sysActive=1 order by NomeProfissional", "NomeProfissional", "") %>
                <div class="col-md-3">
                Procedimentos 
                <label><input type="radio" name="Procedimentos" value="|ALL|" checked class="ace" /><span class="lbl"> Todos</span></label>
                <label><input type="radio" name="Procedimentos" value="|ONLY|" class="ace" /><span class="lbl"> Somente</span></label>
                <label><input type="radio" name="Procedimentos" value="|EXCEPT|" class="ace" /><span class="lbl"> Exceto</span></label>
                <br />
                <%=quickfield("multiple", "Procedimentos", "", 6, "", "select id, NomeProcedimento from procedimentos where sysActive=1 order by NomeProcedimento", "NomeProcedimento", "") %>
            </div>
            <div class="row">


                <div class="col-md-3 pull-right">
                    <label>&nbsp;</label><br>
                    <button type="submit" class="btn btn-success btn-block"><i class="far fa-search"></i>Buscar</button>
                </div>
            </div>
        </div>
        <div class="row">
            <div class="col-md-3">
                <label for="FormaRecto">Forma de recebimento</label>
                <select name="FormaRecto" id="FormaRecto" class="form-control">
                    <option value="">Todas</option>
                    <%
                    set Formas = db.execute("SELECT id,PaymentMethod FROM sys_financialpaymentmethod")
                    while not Formas.eof
                        %>
                        <option value="<%=Formas("id")%>"><%=Formas("PaymentMethod")%></option>
                        <%
                    Formas.movenext
                    wend
                    Formas.close
                    set Formas=nothing
                    %>
                </select>
            </div>
            <div class="col-md-3">
                <label for="GrupoProcedimentos">Grupo de procedimentos</label>
                <select name="GrupoProcedimentos" id="GrupoProcedimentos" class="form-control">
                    <option value="">Todos</option>
                    <%
                    set Grupos = db.execute("SELECT id,NomeGrupo FROM procedimentosgrupos WHERE sysActive=1")
                    while not Grupos.eof
                        %>
                        <option value="<%=Grupos("id")%>"><%=Grupos("NomeGrupo")%></option>
                        <%
                    Grupos.movenext
                    wend
                    Grupos.close
                    set Grupos=nothing
                    %>
                </select>
            </div>
        </div>
        </div>
</form>
<script>
<!--#include file="jQueryFunctions.asp"-->
</script>
