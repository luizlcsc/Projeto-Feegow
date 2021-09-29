<!--#include file="connect.asp"-->
<!--#include file="Classes/Preparo.asp"-->

<script>
fechar = true
</script>
<%
valorMinimoParcela = getConfig("ValorMinimoParcelamento")
tempoIntervalo = getConfig("AntecedenciaPadraoProcedimento")
finalizar = req("finalizar")
set preparoObj = new Preparo

Agendamentos=req("Agendamentos")
IdPaciente = 0
set AgendamentosSQL = db.execute("SELECT age.id, age.Data, age.Encaixe, age.Hora, age.ValorPlano, COALESCE(prof.NomeSocial, prof.NomeProfissional) NomeProfissional, age.PacienteID, " &_ 
" proc.NomeProcedimento, age.TipoCompromissoID ProcedimentoID, age.ProfissionalID, age.TipoCompromissoID ProcID,  " &_
" age.LocalID localAgend, l.NomeLocal, COALESCE(prof.TempoAntecedencia, "&tempoIntervalo&") TempoAntecedencia, l.UnidadeID, unit.Cep, unit.Endereco, unit.Numero, unit.Complemento, unit.Bairro, unit.Cidade, unit.Estado  " &_
" FROM agendamentos age " &_
" LEFT JOIN profissionais prof ON prof.id=age.ProfissionalID " &_
" LEFT JOIN procedimentos proc ON proc.id=age.TipoCompromissoID " &_
" LEFT JOIN locais l ON l.id=age.LocalID " &_
" LEFT JOIN (SELECT 0 id, NomeFantasia, Cep, Endereco, Numero, Complemento, Bairro, Cidade, Estado FROM empresa UNION ALL SELECT id, NomeFantasia, Cep, Endereco, Numero, Complemento, Bairro, Cidade, Estado FROM sys_financialcompanyunits WHERE sysActive=1) unit ON unit.id=l.UnidadeID "&_
" WHERE age.id IN ("&Agendamentos&")" &_
" UNION ALL  " &_
" SELECT agep.id, age.Data, age.Encaixe, age.Hora, agep.ValorPlano, COALESCE(prof.NomeSocial, prof.NomeProfissional) NomeProfissional, age.PacienteID,  " &_
" proc.NomeProcedimento, agep.TipoCompromissoID ProcedimentoID, age.ProfissionalID,  " &_
" agep.TipoCompromissoID ProcID, agep.LocalID localProcs, l.NomeLocal, COALESCE(prof.TempoAntecedencia, "&tempoIntervalo&") TempoAntecedencia, l.UnidadeID, unit.Cep, unit.Endereco, unit.Numero, unit.Complemento, unit.Bairro, unit.Cidade, unit.Estado  " &_
" FROM agendamentos age " &_
" INNER JOIN agendamentosprocedimentos agep ON agep.AgendamentoID=age.id " &_
" LEFT JOIN profissionais prof ON prof.id=age.ProfissionalID " &_
" LEFT JOIN procedimentos proc ON proc.id=age.TipoCompromissoID " &_
" LEFT JOIN locais l ON l.id=agep.LocalID " &_
" LEFT JOIN (SELECT 0 id, NomeFantasia, Cep, Endereco, Numero, Complemento, Bairro, Cidade, Estado FROM empresa UNION ALL SELECT id, NomeFantasia, Cep, Endereco, Numero, Complemento, Bairro, Cidade, Estado FROM sys_financialcompanyunits WHERE sysActive=1) unit ON unit.id=l.UnidadeID "&_
" WHERE age.id IN ("&Agendamentos&")")

if not AgendamentosSQL.eof then 
IdPaciente = AgendamentosSQL("PacienteID")

%>
<% if finalizar&"" = "1" then 
    set pac = db.execute("select Id, NomePaciente, DATE_FORMAT(Nascimento,'%d/%m/%Y') Nascimento, Tel1, Cel1, DATE_FORMAT(FROM_DAYS(DATEDIFF(NOW(), Nascimento)), '%Y')+0 Idade from pacientes where id="&IdPaciente)
    if not pac.eof then 
        response.write("Paciente: " & pac("NomePaciente")& " " & pac("Nascimento") & " Idade: " & pac("Idade") &  " anos FONE: " & pac("Tel1") & " " & pac("Cel1"))
        response.write(" <a href='./?P=Pacientes&I="&pac("Id")&"&Pers=1' target='_blank' class='btn btn-primary btn-sm'>Ver Cliente</a>")
    end if
end if
%>
<table class="table table-striped">
    <thead>
        <tr class="primary">
            <th>Procedimento</th>
            <th>Data</th>
            <th>Hora</th>
            <th>Executor</th>
            <th>Unidade</th>
            <th>Antecedência</th>
            <th>À vista</th>
            <th>3x</th>
            <th>6x</th>
            <th></th>
        </tr>
    </thead>
    <tbody>
        <%
        totalProcedimentos = 0
        total3xProcedimentos = 0
        total6xProcedimentos = 0

        while not AgendamentosSQL.eof
            TempoAntecedencia = AgendamentosSQL("TempoAntecedencia")
            if TempoAntecedencia&"" = "0" then 
                TempoAntecedencia = getConfig("AntecedenciaPadraoProcedimento")
            end if
            
            sqlDesconto = "SELECT ParcelasDe, ParcelasAte, Acrescimo FROM sys_formasrecto WHERE tipoDesconto = 'P' AND (procedimentos LIKE '%|ALL|%' OR procedimentos LIKE '%|" & AgendamentosSQL("ProcID") & "|%') " &_
                                                " AND MetodoID IN (8,9,10) limit 1"
            set descontos = db.execute(sqlDesconto)

            ProcedimentoID=AgendamentosSQL("ProcID")
            ProfissionalID=AgendamentosSQL("ProfissionalID")
            
            valorProcedimento = AgendamentosSQL("ValorPlano")
            parcelaTres = valorProcedimento / 3
            parcelaSeis = valorProcedimento / 6

            if not descontos.eof then
                if descontos("ParcelasDe") <= 3 then
                    parcelaTres = (valorProcedimento * (ccur(descontos("Acrescimo") + 100))) / (3 * 100 )
                end if

                if descontos("ParcelasAte") >= 6 then
                    parcelaSeis = (valorProcedimento * (ccur(descontos("Acrescimo") + 100))) / (6 * 100 )
                end if
            end if

            totalProcedimentos = totalProcedimentos + valorProcedimento
            total3xProcedimentos = total3xProcedimentos + parcelaTres
            total6xProcedimentos = total6xProcedimentos + parcelaSeis

                %>
                <tr>
                    <td><%=AgendamentosSQL("NomeProcedimento")%></td>
                    <td><%=AgendamentosSQL("Data")%></td>
                    <td><%=ft(AgendamentosSQL("Hora"))%>
                    <% if AgendamentosSQL("Encaixe")&"" = "1" then 
                            response.write("(E)") 
                    end if %></td>
                    <td><%=AgendamentosSQL("NomeProfissional")%></td>
                    <%
                    
                    %>
                    <td title="<%=AgendamentosSQL("Endereco")%>, <%=AgendamentosSQL("Numero")%>"><%=AgendamentosSQL("NomeLocal")%></td>
                    <td><%=TempoAntecedencia%> (Min)</td>
                    <td><%=fn(valorProcedimento)%></td>
                    <td><%=fn(parcelaTres)%></td>
                    <td>
                        <% if ccur(valorProcedimento) >= ccur(valorMinimoParcela) then %> 
                            R$ <%=fn(parcelaSeis)%>
                        <% else 
                            response.write(" - ")
                        end if %>
                    </td>
                    <td style="text-align:center">
                        <button class="btn btn-warning btn-xs" type="button" onclick="abrirModalRestricao(<%=ProfissionalID%>,<%=ProcedimentoID%>,<%=IdPaciente%>)"><i class="fa fa-caret-square-o-left"></i></button>
                        <button class="btn btn-success btn-xs" type="button" onclick="abrirModalPreparo2(<%=ProcedimentoID%>,<%=IdPaciente%>,<%=ProfissionalID%>)"><i class="fa fa-lock"></i></button>
                    </td>
                </tr>
                <%
        AgendamentosSQL.movenext
        wend
        AgendamentosSQL.close
        set AgendamentosSQL=nothing
        %>
        <tr>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
            <td><%=fn(totalProcedimentos)%></td>
            <td><%=fn(total3xProcedimentos)%></td>
            <td>
                <% if ccur(totalProcedimentos) >= ccur(valorMinimoParcela) then %> 
                    R$ <%=fn(total6xProcedimentos)%>
                <% else 
                    response.write(" - ")
                end if %>
            </td>
            <td>&nbsp;</td>
        </tr>
    </tbody>
</table>
<%end if%>
<% if finalizar&"" = "1" then %>
<div class="row">
<div class="col-xs-12">
<div class="pull-right">
<div class="checkbox-custom checkbox-primary">
    <input type="checkbox" class="ckinfo" name="trazedocumento" id="trazedocumento" value="1">
    <label class="checkbox" for="trazedocumento">Trazer documento de identidade e CPF</label>
</div>
<div class="checkbox-custom checkbox-primary">
    <input type="checkbox" class="ckinfo" name="tempoantecedencia" id="tempoantecedencia" value="1">
    <label class="checkbox" for="tempoantecedencia">Informar o tempo de antecedência</label>
</div>    
</div>
</div></div>
<script>
fechar = false

$(".ckinfo").on('change', function(){
    fechar = true
    urlDirect = "Redirect";
    $(".ckinfo").each(function(i, v){
        if(!v.checked){
            fechar = false
            urlDirect = "";
        }
    })
})
</script>
<% end if %>

