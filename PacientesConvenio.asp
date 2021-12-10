<!--#include file="connect.asp"--> 
<%

PacienteID = req("I") 
agendamentosFuturosSQL = "SELECT a.id, a.Data, a.Hora FROM agendamentos a LEFT JOIN profissionais prof ON prof.id=a.ProfissionalID WHERE DATE(a.`Data`) > CURDATE() AND a.PacienteID="&PacienteID&" ORDER BY a.Data ASC, a.Hora ASC"

set agendamentosFuturos = db.execute(agendamentosFuturosSQL)
if not agendamentosFuturos.eof then
    temAgendamentosFuturos = agendamentosFuturos("id")
else
    temAgendamentosFuturos = null
end if
                                      
agendamentosFuturos.close
set agendamentosFuturos = nothing

%>  

<div class="panel" id="p1">
    <div class="panel-heading">
        <span class="panel-title"><%'= getResource("name") %>Convênios do Paciente</span>

        <span class="panel-controls">
        <a class="panel-control-collapse hidden" href="#"></a>
        </span>
    </div>
    <div class="panel-body pn">
    
        <div class="widget-main padding-6 no-padding-left no-padding-right">
            <script>
                function getConvenioDetails(campo){
                    let convenioID = $("#ConvenioID"+campo).val();

                    if(convenioID){
                        $.post("ConvenioDetails.asp?ConvenioID="+convenioID, "", function(data){
                        let dados =  eval(data);
                        if(dados){
                                $("#Matricula"+campo).attr("pattern",".{"+dados.MinimoDigitos+","+dados.MaximoDigitos+"}");
                                $("#Matricula"+campo).attr("title","O padrão da matrícula deste convênio está configurado para o de minimo de "+dados.MinimoDigitos+" e o maximo de "+dados.MaximoDigitos+" caracteres");
                            }
                        });
                    }

                    <%
                    if temAgendamentosFuturos then %>
                        $("#modal-table").modal("show");
                        $("#modal").html("Carregando...");
                        $.post("modalAlterarConvenioFuturo.asp",
                            {
                                convenioID:convenioID,
                                pacienteID:<%=PacienteID%>
                            }, 
                            function(data){
                            $("#modal").html(data);
                        });
                    <%
                    end if %>

                }
            </script>
            <table class="table">
                <thead>
                    <tr class="">
                        <th width="12%">Convênio</th>
                        <th width="12%">Plano</th>
                        <th width="22%">Matrícula / Carteirinha</th>
                        <th width="18%">Token Carteirinha</th>
                        <th width="18%">Validade</th>
                        <th width="21%">Titular</th>
                        <th width="1%"></th>
                    </tr>
                </thead>
                <tbody>
                <%
                Numero = 0
                ExibeConvenio=1
                while Numero<3
                    Numero=Numero+1
                    if instr(Omitir, "|convenioid"&Numero&"|")>0 AND instr(Omitir, "|planoid"&Numero&"|")>0 AND instr(Omitir, "|matricula"&Numero&"|")>0 AND instr(Omitir, "|token"&Numero&"|")>0 AND instr(Omitir, "|validade"&Numero&"|")>0 AND instr(Omitir, "|titular"&Numero&"|")>0 then
                        ExibeConvenio=0
                        ExibeConvenioClass = "hidden"
                    else
                        ExibeConvenioClass = ""
                    end if
                    %>
                    <tr class="<%=ExibeConvenioClass%>">
                        <td>
                            <%
                            if instr(Omitir, "|convenioid"&Numero&"|") then
                                response.write("<input type='hidden' name='ConvenioID"&Numero&"' value='"&reg("ConvenioID"&Numero)&"'><center> - </center>")
                            else
                                response.write(selectInsert("", "ConvenioID"&Numero, reg("ConvenioID"&Numero), "convenios", "NomeConvenio", "onchange='getConvenioDetails("&Numero&");'", "empty", ""))
                            end if
                            %>
                        </td>
                        <td>
                            <%
                            if instr(Omitir, "|planoid"&Numero&"|") then
                                response.write("<input type='hidden' name='planoid"&Numero&"' value='"&reg("planoid"&Numero)&"'><center> - </center>")
                            else
                                response.write(selectInsert("", "PlanoID"&Numero, reg("PlanoID"&Numero), "conveniosplanos", "NomePlano", "", "", "ConvenioID"&Numero))
                            end if
                            %>
                        </td>
                        <td>
                            <%
                            if instr(Omitir, "|matricula"&Numero&"|") then
                                response.write("<input type='hidden' name='Matricula"&Numero&"' value='"&reg("Matricula"&Numero)&"'><center> - </center>")
                            else
                                response.write(quickField("text", "Matricula"&Numero, "", 12, reg("Matricula"&Numero), " lt ", "", ""))
                            end if
                            %>
                        </td>
                        <td>
                            <%
                            if instr(Omitir, "|token"&Numero&"|") then
                                response.write("<input type='hidden' name='Token"&Numero&"' value='"&reg("Token"&Numero)&"'><center> - </center>")
                            else
                                response.write(quickField("text", "Token"&Numero, "", 12, reg("Token"&Numero), " lt ", "", ""))
                            end if
                            %>
                        </td>
                        <td>
                            <%
                            if instr(Omitir, "|validade"&Numero&"|") then
                                response.write("<input type='hidden' name='Validade"&Numero&"' value='"&reg("Validade"&Numero)&"'><center> - </center>")
                            else
                                response.write(quickField("datepicker", "Validade"&Numero, "", 12, reg("Validade"&Numero), " input-mask-date ", "", ""))
                            end if
                            %>
                        </td>
                        <td>
                            <%
                            if instr(Omitir, "|titular"&Numero&"|") then
                                response.write("<input type='hidden' name='Titular"&Numero&"' value='"&reg("Titular"&Numero)&"'><center> - </center>")
                            else
                                response.write(quickField("text", "Titular"&Numero, "", 12, reg("Titular"&Numero), "", "", ""))
                            end if
                            %>
                        </td>

                        <td>
                            <button id="btnElegibilidade<%=Numero %>" title="Verificar elegibilidade" class="btn btn-xs btn-warning" onclick="verificaElegibilidade(<%=Numero %>)" type="button">
                                <i id="icoElegibilidade<%=Numero %>" class="fa fa-compress"></i>
                            </button>
                        <script type="text/javascript"> getConvenioDetails("<%=Numero%>"); </script>

                        </td>
                    </tr>
                    <%
                wend
                if ExibeConvenio=0 and session("admin")=0 then
                %>
                <tr>
                    <td colspan="7" class="text-right">
                        <i>
                        Habilite o cadastro de até <%=Numero%> convênios acessando <strong>configurações > Omissão de dados</strong>.
                        </i>
                    </td>
                </tr>
                <%
                end if
                %>
                </tbody>
            </table>
        </div>
    </div>
</div>