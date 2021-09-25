<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<!--#include file="Classes/Restricao.asp"-->
<%
   PendenciaID = req("I")&""
   valorMinimoParcela = getConfig("ValorMinimoParcelamento")
   
   bloquear = false
   
   if PendenciaID <> "" then
   
       set VerificaBloqueio = db.execute("SELECT Nome, UsuarioID FROM pendencia_sessao ps JOIN cliniccentral.licencasusuarios lu ON lu.id = ps.UsuarioID WHERE ps.PendenciaID = "&PendenciaID)
   
       if not VerificaBloqueio.eof then
   
           if VerificaBloqueio("UsuarioID") <> session("User") then
               bloquear = true
               response.write("Esta proposta está em uso por "&VerificaBloqueio("Nome"))
           end if
          
       end if
   end if
   
   if not bloquear and PendenciaID <> "" then
   
   db.execute("INSERT INTO pendencia_sessao (UsuarioID, PendenciaID) VALUES ("&session("User")&","&PendenciaID&")")
   
   set PendenciaSQL = db.execute("SELECT * "&_ 
                                " FROM pendencias "&_
                                " WHERE id= "&PendenciaID)
   
   set TimeLine = db.execute("SELECT StatusID FROM pendencia_timeline WHERE Ativo = 1 AND PendenciaID = "&PendenciaID)
   
   UnidadeID=PendenciaSQL("UnidadeID")
   PacienteID=PendenciaSQL("PacienteID")
   StatusID=PendenciaSQL("StatusID")
   Zonas=PendenciaSQL("Zonas")
   Requisicao=PendenciaSQL("Requisicao")
   Contato=PendenciaSQL("Contato")
   ObsRequisicao=PendenciaSQL("ObsRequisicao")
   ObsContato=PendenciaSQL("ObsContato")
   ObsTurno=PendenciaSQL("ObsTurno")
   
   set UnidadeSQL = db.execute("SELECT NomeFantasia FROM (SELECT 0 id, NomeFantasia FROM empresa UNION ALL SELECT id, NomeFantasia FROM sys_financialcompanyunits WHERE sysActive=1)t WHERE id="&treatvalzero(UnidadeID))
   
   %>
<style>
   .btn-info:hover, .btn-info:focus, .btn-info:active, .btn-info.active, .open > .dropdown-toggle.btn-info {
   background-color: #264cc9 !important;
   }
</style>
<form id="formPendencia">
   <input type="hidden" name="PacienteID" value="<%=PacienteID%>">
   <input type="hidden" name="PendenciaID" value="<%=PendenciaID%>">
   <input type="hidden" name="StatusIDAnterior" value="<%=StatusID%>">
   <input type="hidden" name="Acao" value="Salvar">
   <div class="panel">
      <div class="panel-body">
         <% 
            set sqlPaciente = db.execute(" SELECT DISTINCT pa.id, "&chr(13)&_
                                        " TRIM(pa.NomePaciente) NomePaciente, "&chr(13)&_
                                        " COALESCE(DATE_FORMAT(Nascimento, '%d/%m/%Y'),'(SEM DATA DE NASCIMENTO)') NascimentoData, "&chr(13)&_
                                        " COALESCE(TIMESTAMPDIFF(YEAR, Nascimento, CURDATE()),'') Idade,"&chr(13)&_
                                        " pa.Tel1 AS Contato1, "&chr(13)&_
                                        " pa.Tel2 AS Contato2, "&chr(13)&_
                                        " pa.Cel1 AS Contato3, "&chr(13)&_
                                        " pa.Cel2 AS Contato4, "&chr(13)&_
                                        " TRIM(NomePaciente) AS NomeOrdem "&chr(13)&_
                                        " FROM pacientes pa "&chr(13)&_
                                        " JOIN pendencias pe ON pe.PacienteID = pa.id WHERE pa.id = "&PacienteID)
            
            ContatoTel = ""
            
            if not sqlPaciente.EOF then
            NomePaciente = sqlPaciente("id")&" - "&sqlPaciente("NomePaciente")
            NascimentoData = sqlPaciente("NascimentoData")
            IdadePaciente = " ("&sqlPaciente("Idade")&" anos)"
            'FIXO
            if sqlPaciente("Contato1") <> "" then
            ContatoTel = sqlPaciente("Contato1")
            end if
            
            if sqlPaciente("Contato2") <> "" then
            if ContatoTel <> "" then
                ContatoTel = ContatoTel&" - "
            end if
            ContatoTel = ContatoTel&sqlPaciente("Contato2")
            end if
            
            'CELULAR
            if sqlPaciente("Contato3") <> "" then
            if ContatoTel <> "" then
                ContatoTel = ContatoTel&" / "
            end if
            ContatoTel = ContatoTel&sqlPaciente("Contato3")
            end if
            
            if sqlPaciente("Contato4") <> "" then
            if ContatoTel <> "" and sqlPaciente("Contato3") = "" then
                ContatoTel = ContatoTel&" / "
            elseif sqlPaciente("Contato3") <> "" then
                ContatoTel = ContatoTel&" - "
            end if
            ContatoTel = ContatoTel&sqlPaciente("Contato4")
            end if
            
            'SEM CONTATO
            if ContatoTel = "" then
            ContatoTel = "SEM TELEFONE"
            end if
            else
            NomePaciente = ""
            NascimentoData = ""
            IdadePaciente = ""
            ContatoTel = ""
            end if
            %>
         <table width="100%" class="table table-bordered">
            <tr class="primary">
               <th>
                  <b>Paciente:</b> <%=NomePaciente%>
               </th>
               <th>
                  <b>Nascimento:</b> <%=NascimentoData&IdadePaciente%>
               </th>
               <th>
                  <b>Contato:</b> <%=ContatoTel%>
               </th>
               <th width="1%" style="text-align: right">
                  <a href='?P=Pacientes&I=<%=PacienteID%>&Pers=1' target='_blank' class='btn btn-xs btn-primary'>Ver Cliente</button>
               </th>
            </tr>
         </table>
         <br>
         <table width="100%" class="table table-bordered">
            <thead>
               <tr class="primary">
                  <th>
                     Procedimento
                  </th>
                  <th>
                     Complemento
                  </th>
                  <th>
                     Executor
                  </th>
                  <th>
                     Data
                  </th>
                  <th>
                     Hora
                  </th>
                  <th>
                     Local
                  </th>
                  <th>
                     Antecedência
                  </th>
                  <th>
                     A Vista
                  </th>
                  <th>
                     3x
                  </th>
                  <th class="show-parc-seis">
                     6x
                  </th>
                  <th width="5%">
                     <button type="button" class="btn btn-success btn-sm btn-block" id="btnInserir" data-toggle="modal" data-target=".inserir-procedimento-modal">INSERIR</button>
                  </th>
               </tr>
            </thead>
            <tbody>
               <%
                  totalAVista = 0
                  totalParcelaTres = 0
                  totalParcelaSeis = 0
                  
                  set ProcedimentoSQL = db.execute(" SELECT pp.*, "&_ 
                                                   " proc.NomeProcedimento, "&_ 
                                                   " ab.ProcedimentoID, "&_ 
                                                   " ab.EspecialidadeID, "&_
                                                   " sys_preparos.id as DescricaoPreparoId, "&_
                                                   " sys_preparos.Descricao as DescricaoPreparo "&_ 
                                                   " FROM pendencia_procedimentos pp "&_
                                                   " INNER JOIN agendacarrinho ab ON ab.id=pp.BuscaID "&_
                                                   " LEFT JOIN procedimentos proc ON proc.id=ab.ProcedimentoID "&_
                                                   " LEFT JOIN procedimentospreparofrase ON procedimentospreparofrase.ProcedimentoID = ab.ProcedimentoID "&_
                                                   " LEFT JOIN sys_preparos ON sys_preparos.id = procedimentospreparofrase.PreparoID "&_
                                                   " WHERE pp.PendenciaID="&PendenciaID&_ 
                                                   " AND pp.sysActive = 1")
                  
                  set cart = db.execute("select ac.AgendamentoID, "&_
                                        " pp.id as ppid, ac.id, "&_
                                        " proc.NomeProcedimento, "&_
                                        " comp.NomeComplemento, "&_
                                        " prof.NomeProfissional, "&_
                                        " prof.NomeSocial, "&_
                                        " ac.Zona, "&_
                                        " ac.EspecialidadeID, "&_
                                        " a.Data, "&_
                                        " a.Hora, "&_
                                        " ep.especialidade, "&_
                                        " ac.ProcedimentoID, "&_
                                        " ac.ProfissionalID, "&_
                                        " ac.TabelaID "&_
                                        " FROM pendencia_procedimentos pp "&_
                                        " INNER JOIN agendacarrinho ac ON ac.id=pp.BuscaID "&_
                                        " LEFT JOIN procedimentos proc ON proc.id=ac.ProcedimentoID "&_
                                        " LEFT JOIN complementos comp ON comp.id=ac.ComplementoID "&_
                                        " LEFT JOIN profissionais prof ON prof.id=ac.ProfissionalID "&_
                                        " LEFT JOIN agendamentos a ON a.id=ac.AgendamentoID "&_
                                        " LEFT JOIN especialidades ep ON ep.id = ac.EspecialidadeID "&_
                                        " WHERE pp.PendenciaID="&PendenciaID&_ 
                                        " AND pp.sysActive = 1")
                  while not cart.eof
                  
                      valorProcedimento = 0
                      parcelaTres = 0
                      parcelaSeis = 0
                      if cart("ProcedimentoID") <> "" and  not isnull(cart("ProcedimentoID")) then
                          valorProcedimento = calcValorProcedimento(cart("ProcedimentoID"), cart("TabelaID"), "", cart("ProfissionalID"), cart("EspecialidadeID"), "", "")
                          sqlDesconto = "SELECT ParcelasDe, ParcelasAte, Acrescimo FROM sys_formasrecto WHERE tipoDesconto = 'P' AND (procedimentos LIKE '%|ALL|%' OR procedimentos LIKE '%|" & cart("ProcedimentoID") & "|%') " &_
                                                      " AND MetodoID IN (8,9,10) limit 1"
                  
                          set descontos = db.execute(sqlDesconto)
                                          
                          parcelaTres = valorProcedimento / 3
                          parcelaSeis = valorProcedimento / 6
                  
                          if not descontos.eof then
                              if descontos("ParcelasDe") <= 3 then
                                  parcelaTres = (valorProcedimento * (ccur(descontos("Acrescimo") + 100))) / (3 * 100 )
                              end if
                  
                              if descontos("ParcelasAte") >= 6 then
                                  parcelaSeis = (valorProcedimento * (ccur(descontos("Acrescimo") + 100))) / (6 * 100)
                              end if
                          end if
                  
                      end if
                  
                        NomeLocal = ""
                        Endereco = ""
                        NomeProfissional = ""
                        Data = ""
                        Hora = ""
                        TempoAntecedencia=""

                          if not isnull(cart("AgendamentoID")) then
 
                              set AgendamentoSQL = db.execute("SELECT loc.NomeLocal, "&_
                                                              " a.ValorPlano, "&_
                                                              " a.rdValorPlano, "&_
                                                              " a.Data, "&_
                                                              " a.Hora, "&_
                                                              " loc.UnidadeID as uID, " &_ 
                                                              " IF(loc.UnidadeID = 0, (select CONCAT(Endereco, ' ', Numero, ' ', Complemento, ' ', Bairro, ' ', Cep, ' ', Cidade, ' ', Estado) Enderecos from empresa where id = loc.UnidadeID), " &_ 
                                                              " (select CONCAT(Endereco, ' ', Numero, ' ', Complemento, ' ', Bairro, ' ', Cep, ' ', Cidade, ' ', Estado) Enderecos from sys_financialcompanyunits where id = loc.UnidadeID) ) Enderecos " &_
                                                              " FROM agendamentos a "&_
                                                              " LEFT JOIN locais loc ON loc.id=a.LocalID "&_
                                                              " WHERE a.id="&cart("AgendamentoID"))
                                 
                              if not AgendamentoSQL.eof then
                  
                                  AVista = "Convenio"
                                  valorProcedimento = 0
                                  parcelaTres = 0
                                  parcelaSeis = 0
                  
                                  if AgendamentoSQL("rdValorPlano") = "V" then 
                                      valorProcedimento = AgendamentoSQL("ValorPlano")    
                  
                                      if not descontos.eof then
                                          if descontos("ParcelasDe") <= 3 then
                                              parcelaTres = valorProcedimento * descontos("Acrescimo") / (3 * 100)
                                          end if
                  
                                          if descontos("ParcelasAte") >= 6 then
                                              parcelaSeis = valorProcedimento * descontos("Acrescimo") / (6 * 100)
                                          end if
                                      end if
                                  end if
                  
                                  NomeLocal = AgendamentoSQL("NomeLocal")
                                  Data = AgendamentoSQL("Data")
                                  Hora = formatdatetime(AgendamentoSQL("Hora"),4)
                                  Endereco = AgendamentoSQL("Enderecos")
                  
                              end if
                          end if
                  
                          ' recupera o último contato não excluido
                          set ExecutanteSQL = db.execute(" SELECT COALESCE(NULLIF(prof.NomeSocial,''), prof.NomeProfissional) NomeProfissional, "&_
                                                              " ce.StatusID, ce.Data, ce.Hora, CONCAT(prof.tempoantecedencia, ' min') tempoantecedencia, loc.NomeLocal"&_
                                                              " FROM pendencia_contatos_executantes ce "&_
                                                              " INNER JOIN profissionais prof ON prof.id = ce.ExecutanteID "&_
                                                              " LEFT JOIN locais loc ON loc.id=ce.LocalID "&_
                                                              " WHERE ce.PendenciaProcedimentoID = "&cart("ppid")&_
                                                              " AND ce.sysActive = 1 ORDER BY ce.id DESC LIMIT 1")
                  
                          if not ExecutanteSQL.eof then
                              ' só exibe os dados do executor se o último contato for agendado
                              if ExecutanteSQL("StatusID") = 6 then
                                 
                                 NomeLocal = ExecutanteSQL("NomeLocal")
                                 NomeProfissional=ExecutanteSQL("NomeProfissional")
                                 TempoAntecedencia=ExecutanteSQL("tempoantecedencia")
                                 Data=ExecutanteSQL("Data")
                                 if ExecutanteSQL("Hora") <> "" then
                                    splHora = split(ExecutanteSQL("Hora"), " ")
                                    splSemSegundo = split(splHora(1),":")
                                    Hora=splSemSegundo(0)&":"&splSemSegundo(1)
                                 end if
                              end if
                          end if
                  
                          totalAVista = totalAVista + valorProcedimento
                          totalParcelaTres = totalParcelaTres + parcelaTres
                          totalParcelaSeis = totalParcelaSeis + parcelaSeis
                  
                          dim restricaoObj
                          set restricaoObj = new Restricao
                  
                          %>
               <tr id="trProcedimento<%=cart("ppid")%>">
                  <td style="cursor:pointer;" onclick="carregaProcedimentoExecutante('<%=cart("ppid")%>','<%=cart("ProcedimentoID")%>','<%=cart("EspecialidadeID")%>')">
                     <%=cart("NomeProcedimento")%>
                  </td>
                  <td>
                     <%= cart("NomeComplemento") %>
                  </td>
                  <td>
                     <%= NomeProfissional %>
                  </td>
                  <td>
                     <%=Data%>
                  </td>
                  <td>
                     <%=Hora%>
                  </td>
                  <td>
                     <span data-toggle="tooltip" title="<%= Endereco %>" href="#" class=""><%= NomeLocal %></span>
                  </td>
                  <td>
                     <%=TempoAntecedencia%>
                  </td>
                  <td>
                     R$ <%= fn(valorProcedimento) %>
                  </td>
                  <td>
                     R$ <%= fn(parcelaTres) %>
                  </td>
                  <td>
                     <% if ccur(valorProcedimento) >= ccur(valorMinimoParcela) then %> 
                     R$ <%=fn(parcelaSeis)%>
                     <% else 
                        response.write(" - ")
                        end if %>
                  </td>
                  <td style="text-align:center">
                     <%
                        if ccur(restricaoObj.possuiRestricao(cart("ProcedimentoID"))) > 0 then
                        %>
                     <button class="btn btn-warning btn-xs" type="button" onclick="abrirModalRestricao('',<%=ProcedimentoSQL("ProcedimentoId")%>,<%=PacienteID%>)"><i class="fa fa-caret-square-o-left"></i></button>
                     <%
                        end if
                        %>
                     <button type="button" class="btn btn-xs btn-danger remove-item-subform remover-data" onclick="removerProcedimento(<%=cart("ppid")%>,'<%=cart("NomeProcedimento")%>')"><i class="fa fa-trash"></i></button>
                  </td>
               </tr>
               <%
                  cart.movenext
                  wend
                  cart.close
                  set cart = nothing
                  %>
               <tr>
                  <td></td>
                  <td></td>
                  <td></td>
                  <td></td>
                  <td></td>
                  <td></td>
                  <td></td>
                  <td>R$ <%=fn(totalAVista)%></td>
                  <td>R$ <%=fn(totalParcelaTres)%></td>
                  <td>
                     <% if ccur(totalAVista) >= ccur(valorMinimoParcela) then %> 
                     R$ <%=fn(totalParcelaSeis)%>
                     <% else 
                        response.write(" - ")
                        end if %>
                  </td>
                  <td></td>
               </tr>
            </tbody>
         </table>
         <br>
         <table width="100%" class="table table-bordered">
            <thead>
               <tr class="primary">
                  <th width="30%">
                     Executor
                  </th>
                  <th>
                     Cidade
                  </th>
                  <th width="15%">
                     Zona
                  </th>
                  <th width="10%">
                     Status
                  </th>
                  <th width="10%">
                     Valor
                  </th>
                  <th width="5%">
                     Contatos
                  </th>
                  <th width="10%">
                  </th>
               </tr>
            </thead>
            <tbody id="pendencia-executantes">
            </tbody>
         </table>
         <br>  
         <div class="panel panel-default">
            <div class="panel-heading" style="color: #196090; border-color: #82c0e9; background-color: #b6daf2; cursor: pointer;">
               <p class="panel-title" data-toggle="collapse" data-target="#collapseOne" style="font-size: 13px;">
                  <strong>PREFERÊNCIAS DO PACIENTE</strong>
               </p>
            </div>
            <div id="collapseOne" class="panel-collapse collapse">
               <div class="panel-body">
                  <table width="100%" class="table table-bordered">
                     <thead>
                        <tr class="primary">
                           <th style="text-align:center" width="20%">
                              UNIDADE DE PENDÊNCIA
                           </th>
                           <th style="text-align:center" width="30%">
                              ZONA
                           </th>
                           <th style="text-align:center" width="50%">
                              SELEÇÃO DE DIAS
                           </th>
                        </tr>
                     </thead>
                     <tbody>
                        <tr>
                           <td style="vertical-align:top">
                              <div class="btn-group btn-group-toggle" data-toggle="buttons">
                                 <% set Empresa = db.execute("select * from empresa where OcultoAgenda <> 'S'") %>
                                 <% while not Empresa.eof %>
                                 <label class="btn btn-info btn-sm btn-block <% if UnidadeID = 0 then response.write("active") end if %>">
                                 <input type="radio" name="UnidadeID" id="option0" value="0" autocomplete="off" <% if UnidadeID = 0 then response.write("checked") end if %>> <%=Empresa("NomeEmpresa")%>
                                 </label>
                                 <% Empresa.movenext
                                    wend
                                    Empresa.close
                                    set Empresa=nothing %>
                                 <% set Unidades = db.execute("select * from sys_financialcompanyunits where not isnull(UnitName) and sysActive=1 and (OcultoAgenda <> 'S' OR OcultoAgenda IS NULL)  order by UnitName") %>
                                 <% while not Unidades.eof %>
                                 <label class="btn btn-info btn-sm btn-block <% if Unidades("id") = UnidadeID then response.write("active") end if %>">
                                 <input type="radio" name="UnidadeID" id="option<%=Unidades("id")%>" autocomplete="off" value="<%=Unidades("id")%>" <% if Unidades("id") = UnidadeID then response.write("checked") end if %>> <%=Unidades("NomeFantasia")%>
                                 </label>
                                 <%Unidades.movenext
                                    wend
                                    Unidades.close
                                    set Unidades=nothing %>
                              </div>
                           </td>
                           <td style="vertical-align: top">
                              <table width="100%">
                                 <thead>
                                    <tr>
                                       <td width="90%">
                                          <div id="divZona">
                                          </div>
                                       </td>
                                       <td style="text-align: center">
                                          <button type="button" class="btn btn-sm btn-success" id="insereZona" onclick="$('#insereZona').prop('disabled', true);insereZona2()">
                                             <li class="fa fa-plus"></li>
                                          </button>
                                       </td>
                                    </tr>
                                 </thead>
                              </table>
                            
               </div>
            </div>
         </div>
         <table class="table" id="tblZona" width="100%">
         <tbody>
         <%
            if Zonas <> "" then
                zonaSplt = split(Zonas, ",")
                for z=0 to ubound(zonaSplt)
            %>
         <tr>
         <td width="90%">
         <input type="hidden" name="zona[]" value="<%=zonaSplt(z)%>"><%=zonaSplt(z)%>
         </td>
         <td>
         <button type="button" class="btn btn-sm btn-danger remove-item-subform" onclick="removeZona(this)">
         <i class="fa fa-trash"></i>
         </button>
         </td>
         </tr>
         <%
            next
            end if
            %>
         </tbody>
         </table>
         <script>
            $(document).ready(function(){
                $('#insereZona').dblclick(function(e){
                    e.preventDefault();
                });   
            });
            
            carregaZona();
            
            function insereZona2() {
            
                var a = $("#Regiao").val();
            
                if (a != null) {
                    var b = $("#Regiao option:selected").text();
                    $('#tblZona tbody').append(`<tr>
                                                    <td width="90%">
                                                        <input type="hidden" name="zona[]" value="${a}">${b}
                                                    </td>
                                                    <td>
                                                        <button type="button" class="btn btn-sm btn-danger remove-item-subform" onclick="removeZona(this)">
                                                            <i class="fa fa-trash"></i>
                                                        </button>
                                                    </td>
                                                </tr>`);
                    carregaZona();
                } 
            }
            
            function removeZona(ele) {
                $(ele).parent().parent().remove();
                carregaZona();
            }
            
            function carregaZona() {
                var zonaValor = [];
                var inputZonaValor = $("input[type='hidden'][name^='zona']").map(function() {
                    return $.trim($(this).val());
                }).toArray();
                
                if (inputZonaValor.length > 0) {
                    zonaValor = " AND Regiao NOT IN ('"+inputZonaValor.join("','")+"')";
                }
            
                $.post("pendenciasUtilities.asp", {
                    acao: "carregaZona",
                    zonaValor: zonaValor,
                }, function(data) {
                    $("#divZona").html(data);
                    $('#insereZona').prop('disabled', false);
                });
            }
         </script>
         </td>
         <td style="vertical-align:top">
         <table width="100%">
         <tr>
         <td width="240px" style="vertical-align:top">
         <link href="css/vanillaCalendar.css" rel="stylesheet">
         <div style="max-height: 300px; overflow: auto; padding: 5px;width: 280px">
         <div id="v-cal">
         <div class="vcal-header">
         <button class="vcal-btn" type="button" data-calendar-toggle="previous">
         <svg height="24" version="1.1" viewbox="0 0 24 24" width="24" xmlns="http://www.w3.org/2000/svg">
         <path d="M20,11V13H8L13.5,18.5L12.08,19.92L4.16,12L12.08,4.08L13.5,5.5L8,11H20Z"></path>
         </svg>
         </button>
         <div class="vcal-header__label" data-calendar-label="month">
         March 2017
         </div>
         <button class="vcal-btn" type="button" data-calendar-toggle="next">
         <svg height="24" version="1.1" viewbox="0 0 24 24" width="24" xmlns="http://www.w3.org/2000/svg">
         <path d="M4,11V13H16L10.5,18.5L11.92,19.92L19.84,12L11.92,4.08L10.5,5.5L16,11H4Z"></path>
         </svg>
         </button>
         </div>
         <div class="vcal-week">
         <span>SEG</span>
         <span>TER</span>
         <span>QUA</span>
         <span>QUI</span>
         <span>SEX</span>
         <span>SAB</span>
         <span>DOM</span>
         </div>
         <div class="vcal-body" data-calendar-area="month"></div>
         </div>
         <div class="container2 dias _dias flex-wrap flex-start">
         </div>
         <script src="js/vanillaCalendar.js" type="text/javascript"></script>
         </div>
         </td>
         <td style="vertical-align:top">
         <table class="table" id="tblDias" width="100%">
         <tbody>
         <%
            set DiasSQL = db.execute("SELECT id, DATE_FORMAT(Data, '%d/%m/%Y') AS Data, Data as ordernar, TurnoManha, TurnoTarde, Observacao FROM pendencia_data WHERE PendenciaID = "&PendenciaID&" ORDER BY ordernar")
            
            while not DiasSQL.eof
            %>
         <tr>
         <td width="15%">
         <input type="hidden" name="Dias|x<%=DiasSQL("id")%>" value="<%=DiasSQL("Data")%>">
         <b><%=DiasSQL("Data")%></b>
         </td>
         <td>
         <input class="form-control" type="text" name="Dias|x<%=DiasSQL("id")%>" value="<%=DiasSQL("Observacao")%>">
         </td>
         <td width="147px">
         <div class="btn-group btn-group-toggle" data-toggle="buttons">
         <label class="btn btn-sm btn-info <% if DiasSQL("TurnoManha") = "M" then response.write("active") end if %>">
         <input type="checkbox" name="DiasM|x<%=DiasSQL("id")%>" id="Contato1" value="M" autocomplete="off" <% if DiasSQL("TurnoManha") = "M" then response.write("checked") end if %>> MANHÃ
         </label>
         <label class="btn btn-sm btn-info <% if DiasSQL("TurnoTarde") = "T" then response.write("active") end if %>">
         <input type="checkbox" name="DiasT|x<%=DiasSQL("id")%>" id="Contato2" value="T" autocomplete="off" <% if DiasSQL("TurnoTarde") = "T" then response.write("checked") end if %>> TARDE
         </label>
         </div>
         </td>
         <td width="10%">
         <button type="button" class="btn btn-sm btn-danger remove-item-subform remover-data" remove-selected-day="<%=DiasSQL("Data")%>" onclick="$(this).parent().parent().remove();removeSelectedDay('<%=DiasSQL("Data")%>')">
         <i class="fa fa-trash"></i>
         </button>
         </td>
         </tr> 
         <%
            DiasSQL.movenext
            wend
            
            DiasSQL.close
            set DiasSQL = nothing
            %>
         </tbody>
         </table>
         </td>
         </tr>
         </table>
         </td>
         </tr>
         </tbody>
         </table>
         <script>
            vanillaCalendar.init({
                disablePastDays: true
            });
            
            function removeSelectedDay(data){
                vanillaCalendar.removeSelectedDay(data)
            }
         </script>
         <br>
         <style>
            .modal-dialog {
            width: 1280px !important;
            margin: 30px auto !important;
            }
            .custom{ width: 33% !important;}
            .custom2{ width: 50% !important;}
         </style>
         <table width="100%" class="table table-bordered">
            <thead>
               <tr class="primary">
                  <th style="text-align:center">
                     REQUISIÇÃO
                  </th>
                  <th style="text-align:center">
                     CONTATO
                  </th>
               </tr>
            </thead>
            <tbody>
               <tr>
                  <td style="text-align:center">
                     <div class="btn-group btn-group-toggle" data-toggle="buttons" style="width:100%">
                        <label class="btn btn-sm btn-info custom <% if Requisicao = "C" then response.write("active") end if %>">
                        <input type="radio" class="custom-control-input" name="Requisicao" id="Requisicao1" value="C" autocomplete="off" <% if Requisicao = "C" then response.write("checked") end if %>> CENTRAL
                        </label>
                        <label class="btn btn-sm custom btn-info <% if Requisicao = "P" then response.write("active") end if %>">
                        <input type="radio" name="Requisicao" id="Requisicao2" value="P" autocomplete="off" <% if Requisicao = "P" then response.write("checked") end if %>> PARTICULAR
                        </label>
                        <label class="btn btn-sm custom btn-info <% if Requisicao = "S" then response.write("active") end if %>">
                        <input type="radio" name="Requisicao" id="Requisicao3" value="S" autocomplete="off" <% if Requisicao = "S" then response.write("checked") end if %>> SUS
                        </label>
                     </div>
                  </td>
                  <td style="text-align:center">
                     <div class="btn-group btn-group-toggle" data-toggle="buttons"  style="width:100%">
                        <label class="btn btn-sm btn-info custom2 <% if Contato = "P" then response.write("active") end if %>">
                        <input type="radio" name="Contato" id="Contato1" value="P" autocomplete="off" <% if Contato = "P" then response.write("checked") end if %>> PACIENTE
                        </label>
                        <label class="btn btn-sm custom2 btn-info <% if Contato = "O" then response.write("active") end if %>">
                        <input type="radio" name="Contato" id="Contato2" value="O" autocomplete="off" <% if Contato = "O" then response.write("checked") end if %>> OUTRO
                        </label>
                     </div>
                  </td>
               </tr>
               <tr>
                  <td>            
                     <label for="textRequisicao">Observação</label>
                     <textarea class="form-control" name="ObsRequisicao" id="ObsRequisicao"><%=ObsRequisicao%></textarea>
                  </td>
                  <td>
                     <label for="textContato">Observação</label>
                     <textarea class="form-control" name="ObsContato" id="ObsContato"><%=ObsContato%></textarea>
                  </td>
               </tr>
            </tbody>
         </table>
         <div class="modal fade" id="modal-procedimentos-excecao" tabindex="-1" role="dialog" aria-labelledby="modal-procedimentos-excecao-label" aria-hidden="true">
            <div class="modal-dialog" role="document">
               <div class="modal-content">
                  <div class="modal-header">
                     <h5 class="modal-title" id="modal-procedimentos-excecao-label">Atenção - Procedimentos exceções</h5>
                     <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                     <span aria-hidden="true">&times;</span>
                     </button>
                  </div>
                  <div class="modal-body">
                     <table id = "procedimentos-ex" class="table table-bordered">
                        <tbody>
                           <tr>
                              <th>PROCEDIMENTO</th>
                              <th>DESCRIÇÃO</th>
                           </tr>
                        </tbody>
                     </table>
                     <div class="checkbox-custom checkbox-primary">      
                        <br>
                        <input type="checkbox" name="procedimento_excecao_concorda" id="termo-procedimentos" value="1">
                        <label for="termo-procedimentos"> Estou ciente que todos os procedimentos acima, precisam respeitar as exceções descritas.</label>
                     </div>
                  </div>
                  <div class="modal-footer">        
                     <button type="button" class="btn btn-secondary" data-dismiss="modal">Sair</button>
                     <button type="button" id="salvar-pendencias" onclick="SalvaPendencia(false)" data-dismiss="modal" class="btn btn-primary">Concordo</button>
                  </div>
               </div>
            </div>
         </div>
         <input type="hidden" name="diasSelecionados" id="diasSelecionados" value="">
         <div id="msg-alert">
         </div>
      </div>
   </div>

   <div class="row" style="margin-top: 15px;">
            <div class="col-md-6">
               <p style="font-size: 13px; color: #196090; border-color: #82c0e9; background-color: #b6daf2; padding: 10px">
                     <strong>OBSERVAÇÃO GERAL</strong>
               </p>
               <div class="col-md-12 qf">
                  <label for="textGeral">Observação</label>
                  <textarea class="form-control" name="ObsGeral" id="ObsGeral" style="height:73px!im"></textarea>
                  <a title='Histórico de Alterações' href='javascript:log(<%=PendenciaID%>)' class='btn btn-sm btn-default hidden-xs m5'><i class='fa fa-history'></i></a>
                  <button type="button" class="btn btn-primary pull-right m5" style="padding: 5px 7px;" onclick="SalvaObservacao()">Salvar</button>
               </div>
            </div>
            <div class="col-md-3">
               <p style="font-size: 13px; color: #196090; border-color: #82c0e9; background-color: #b6daf2; padding: 10px">
                     <strong>ORIENTAÇÕES</strong>
               </p>
               <br/>
               <%=quickfield("simpleCheckbox", "trazerDocumento", "Trazer documentos de identidade e CPF", 12, "", "", "", "")%>
               <%=quickfield("simpleCheckbox", "tempoAntecedencia", "Informar o tempo de antecedência", 12, "", "", "", "")%>
            </div>
            <div class="col-md-3">
               <p style="font-size: 13px; color: #196090; border-color: #82c0e9; background-color: #b6daf2; padding: 10px">
                     <strong>STATUS DA PENDÊNCIA</strong>
               </p>
               <%=quickfield("select", "StatusID", "Status", 12, StatusID, "SELECT id, NomeStatus FROM pendenciasstatus", "NomeStatus", "") %>
            </div>
        <div class="col-md-12">
            <br><button type="button" class="btn btn-primary pull-right m5" onclick="SalvaPendencia(true)">Salvar</button>
            <button type="button" class="btn btn-seconday pull-right m5" onclick="window.location.href='?P=Pendencias&Pers=1'">Voltar</button>
        </div>
   </div>  
</form>
<div id="modalpendencias" class="modalpendencias modal fade">
   <div class="modal-dialog modal-lg">
      <div class="modal-content" style="width: 900px; margin: 30px auto;">
         <div class="modal-header">
            <h4 class="modal-title">Restrições</h4>
         </div>
         <div class="modal-body modalpendenciasbody" >
         </div>
      </div>
      <!-- /.modal-content -->
   </div>
   <!-- /.modal-dialog -->
</div>
<!-- /.modal -->
<div id="modalObservacao" class="modal fade">
   <div class="modal-dialog modal-lg">
      <div class="modal-content">
         <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal">&times;</button>
            <h4 class="modal-title">Observações</h4>
         </div>
         <div class="modal-body modalObservacaoBody" >
         </div>
      </div>
      <!-- /.modal-content -->
   </div>
   <!-- /.modal-dialog -->
</div>
<!-- /.modal -->
<div class="modal fade inserir-procedimento-modal" tabindex="-1" role="dialog">
   <div class="modal-dialog" role="document">
      <div class="modal-content" style="width: 600px; margin: 30px auto;">
         <div class="modal-header">
            <h5 class="modal-title">Pendência</h5>
            <button type="button" class="close" data-dismiss="modal" aria-label="Close">
            <span aria-hidden="true">&times;</span>
            </button>
         </div>
         <div class="modal-body">
            <div class="row">
               <div id="divComboGrupoProcedimento">
                  <%= quickfield("simpleSelect", "bGrupoID", "Grupo", 4, "", "select id, NomeGrupo from procedimentosgrupos where sysActive=1 order by NomeGrupo", "NomeGrupo", " onchange=""recarregaCombo('carregaComboProcedimento',$(this).val())""") %>
               </div>
               <div id="divComboProcedimento">
                  <%= quickfield("simpleSelect", "bProcedimentoID", "Procedimento", 4, "", "select id, NomeProcedimento from procedimentos p where p.GrupoID not in (select id from procedimentosgrupos pg where pg.sysActive = 1 and (pg.NomeGrupo like '%Laboratório%')) AND sysActive=1 and Ativo='on' order by NomeProcedimento", "NomeProcedimento", "onchange=""recarregaCombo('carregaComplemento','',$(this).val());"" ") %>
               </div>
               <div id="divComboComplemento" class="col-md-4">
                  <div class="form-group">
                     <label for="bComplementos">Complemento</label>
                     <select class="form-control class_complementos" id="bComplementos">
                        <option value="0">Selecione</option>
                     </select>
                  </div>
               </div>
            </div>
         </div>
         <div class="modal-footer">
            <button type="button" class="btn btn-secondary" data-dismiss="modal">Fechar</button>
            <button type="button" class="btn btn-success" id="btnSalvarProcedimentoModal">Salvar</button>
         </div>
      </div>
   </div>
</div>
<script>
   function log(PendenciaID){
      $('#modal-table').modal('show');$.get('pendenciaLogsObservacao.asp?usuarioID=0&pendenciaID='+PendenciaID, function(data){$('#modal').html(data);})
   }
   $(".modal-content").removeAttr("style")
   function recarregaCombo(acao, GrupoID, ProcedimentoID){
   
   $.post("MultiplaFiltrosCombo.asp",{acao:acao, ProcedimentoID:ProcedimentoID, GrupoID:GrupoID},function(data){
       switch (acao) {
           case 'carregaComboProcedimento':
               $("#divComboProcedimento").html(data);
               break;
           case 'carregaComplemento':
               $("#divComboComplemento").html(data);
               $("#qfbcomplementoid").removeClass("col-md-2 qf");
               break 
           }
       });
   }
   
   function agfilParametros(){};
   
   var pendenciaID = <%=PendenciaID%>;
   var pacienteID = <%=PacienteID%>
   
   $("#btnSalvarProcedimentoModal").click(function () {   
        var procedimentoID = $("#bProcedimentoID").val();
        var complementoID = $("#bComplementoID").val(); 
        
        if(procedimentoID === "0") {
            new PNotify({
                title: 'PENDÊNCIA',
                text: 'Selecione um procedimento para prosseguir',
                sticky: true,
                type: 'error',
                delay: 1000
            });
            return;
        }
        
       $.post("savePendencia.asp",{Acao:"InserirProcedimento", PendenciaID: pendenciaID, ProcedimentoID: procedimentoID, ComplementoID: complementoID}, function (data) {
           
            new PNotify({
                title: 'PENDÊNCIA',
                text: 'Pendência inserida com sucesso.',
                sticky: true,
                type: 'success',
                delay: 500
            });
           
           data = JSON.parse(data);
           let totalRestricoes = data[0].total;   
           
           if(totalRestricoes > 0){
                $.ajax({
                    type: 'GET',
                    url: 'procedimentosListagem.asp?ProcedimentoId=' + procedimentoID + '&PacientedId=' + pacienteID + '&requester=MultiplaPorFiltro&criarPendencia=Sim',
                    data: true
                }).done(function(data) {
                    $(".inserir-procedimento-modal").modal("hide");
                    $(".modalpendencias").modal("show")
                    $(".modalpendenciasbody").html(data)
                    $(".btn-success").click(function (){
                        location.reload();
                    });
                });
           } else {
               location.reload();
           }
       });
   });
   
    function enviar(totalPreparo){
        $.ajax({
                type: 'GET',
                url: 'procedimentosListagem.asp?totalPreparo='+totalPreparo+'&ProcedimentoId=' + procedimentoID+ '&PacientedId=' + pacienteID,
                data: true
            }).done(function(data) { 
                 $(".modalpendencias").modal("show")
                 $(".modalpendenciasbody").html(data)
            });
    };


   function removerProcedimento(ppid, nomeprocedimento){
       let confirmacao = confirm("Deseja excluir o procedimento "+nomeprocedimento+"?")
   
       if (confirmacao == true) {
           $.post("savePendencia.asp",{Acao:"RemoverProcedimento", ppid: ppid}, function(data){
               alert("Procedimento excluido com sucesso")
               window.location.href='?P=AdministrarPendencia&Pers=1&I='+<%=PendenciaID%>
           })
       }
   }    
   
   $(document).ready(function(){
   
       $(document).on('show.bs.modal', '.modal-content', function (event) {
           var zIndex = 1040 + (10 * $('.modal-content:visible').length);
           $(this).css('z-index', zIndex);
   
           setTimeout(function() {
   
               $('.modal-backdrop').not('.modal-stack').css('z-index', zIndex - 1).addClass('modal-stack');
   
           }, 0);
       });
   
   });
   
   function abrirModalRestricao (ProfissionalID,ProcedimentoID,PacienteID) {
   
       if (ProfissionalID == '') {
           $.post("ProcedimentoListagemRestricoes.asp?ProcedimentoId="+ProcedimentoID+"&PacientedId=" + PacienteID + "&requester=AdministrarPendencia",function(data){
               $(".modalpendencias").modal("show")
               $(".modalpendenciasbody").html(data)
               $("#modalPendenciasFooter").html("")
           })
       } else {
   
           $.ajax({
               type: 'GET',
               url: 'procedimentosListagem.asp?ProfissionalID='+ProfissionalID+'&ProcedimentoId=' + ProcedimentoID + '&PacientedId=' + PacienteID + '&requester=AdministrarPendencia&criarPendencia=Nao',
               data: true
           }).done(function(data) { 
               $(".modalpendencias").modal("show")
               $(".modalpendenciasbody").html(data)
   
           });
       }
   }
   
   function RealizarContato(PendenciaProcedimentoID, ProfissionalID, PacienteID = 0) {
   
       $('#modal').removeAttr('style');
       $('head').append('<style type="text/css">.modal .modal-content {max-height: ' + ($('body').height() * .8) + 'px;overflow-y: auto;}.modal-open .modal{overflow-y: hidden !important;}</style>');
       $("#modal-table").modal("show");
       $("#modal").html("Carregando...");
   
       $.get("PendenciaExecutanteContato.asp", {
           PendenciaProcedimentoID: PendenciaProcedimentoID,
           ProfissionalID: ProfissionalID, PacienteID: PacienteID,
       }, function (data) {
           $("#modal").html(data);
       });
   }
   
   function carregaProcedimentoExecutante(PendenciaProcedimentoID, ProcedimentoID, EspecialidadeID) {
   
       $("tr[id^='trProcedimento']").removeClass("info")
       $("#trProcedimento"+PendenciaProcedimentoID).addClass("info");
   
       $("#pendencia-executantes").html("<tr><td colspan='100%' style='text-align:center'>Carregando...</td></tr>");
   
       $.post("pendenciasUtilities.asp", {
           acao: "carregaProcedimentoExecutante",
           PendenciaProcedimentoID: PendenciaProcedimentoID,
           ProcedimentoID: ProcedimentoID,
           EspecialidadeID: EspecialidadeID,
           PacienteID: <%=PacienteID%>,
           UnidadeID: <%=UnidadeID%>
       }, function(data) {
           $("#pendencia-executantes").html(data);
       })
   }
   
   $(document).ready(function(){
       $("#form-components").submit(function(e){
           e.preventDefault();
       });
   });
   
   function controleTextArea(id,bool) {
       $("#"+id).prop("disabled",bool);
   }
   
   $(function(){
       $(".enviar").on('click', function(){
           //$(this).attr("disabled", "");
           //$(this).prop("disabled", false);
       } );
       $("#Requisicao").on('change', function(){
           var value = $(this).val();
           $("#ObsRequisicao").prop("required", false);
           if(value != "C"){
               $("#ObsRequisicao").prop("required", true);
           }
       });
       $(".components-modal-submit-btn").on('click', function(){
           $(this).attr("disabled", "");
           $(this).prop("disabled", false);
       });
       $(".contato-paciente-outros").on('change', function(){
           var value = $(this).val();
           $("#ObsContato").prop("required", false);
           if(value == "O"){
               $("#ObsContato").prop("required", true);
           }
       });
   })
   
   function RealizarContato_old(PendenciaProcedimentoID, ProfissionalID, PacienteID = 0) {
       openComponentsModal("PendenciaExecutanteContato.asp", {
           PendenciaProcedimentoID: PendenciaProcedimentoID,
           ProfissionalID: ProfissionalID, PacienteID: PacienteID
       }, "Contatar executante", true, "Salvar contato");
   }
   
   function VisualizarContatos(PendenciaProcedimentoID, ProfissionalID) {
       openComponentsModal("PendenciaVisualizarContatos.asp", {
           PendenciaProcedimentoID: PendenciaProcedimentoID,
           ProfissionalID: ProfissionalID
       }, "Contatos realizados", true);
   }
   
   function ExcluirExecutante2(id) {
       if(confirm("Tem certeza que deseja excluir este executor?")){
           $.post("PendenciaExecutanteContato.asp?Id="+id, {
               A: "E",
           }, function(dados) {
               eval(dados)
               
           })
       }
   }
   
   function ExcluirExecutante(PendenciaProcedimentoID, ProfissionalID) {
       if(confirm("Tem certeza que deseja excluir este executor?")){
           $.post("PendenciaExecutanteContato.asp?ProfissionalID="+ProfissionalID+"&PendenciaProcedimentoID="+PendenciaProcedimentoID, {
               A: "E",
               StatusID: 7
           }, function() {
               $(".linha-executor[data-id="+ProfissionalID+"]").remove();
           })
       }
   }
   
   function SelecionaProcedimento(PendenciaProcedimentoID, ProcedimentoID, EspecialidadeID) {
       $.get("carregaProcedimentoExecutantes.asp", {
           PendenciaProcedimentoID: PendenciaProcedimentoID,
           ProcedimentoID: ProcedimentoID,
           EspecialidadeID: EspecialidadeID,
           PacienteID: document.getElementsByName("PacienteID")[0].value
       }, function(data) {
           $(".pendencia-executantes").html(data);
       })
   }
   
   $(".crumb-active a").html("Administrar pendência");
   $(".crumb-link").removeClass("hidden");
   $(".crumb-link").html("");
   $(".crumb-icon a span").attr("class", "fa fa-cog");
   
   var $form = $("#formPendencia");
   
   clearListLinhasTabelaProcedimentos = () => {    
       procedimentosList = [...document.getElementById("procedimentos-ex").getElementsByTagName("tr")];
       procedimentosList.forEach((value, key) => {
           if(key != 0 ){
               document.getElementById("procedimentos-ex").deleteRow(-1);
           }
       });
   }
   
   gerarLinhaTabelaProcedimentoExcecao = (nomeProcedimento, descricaoProcedimento) => {
       let tableRef = document.getElementById("procedimentos-ex");
       let newRow = tableRef.insertRow(-1);
   
       let newCellNomeProcedimento = newRow.insertCell(0);
       let newCellDescricaoProcedimento = newRow.insertCell(1);		
   
       let newTextNomeProcedimento = document.createTextNode(nomeProcedimento);
       let newTextDescricaoProcedimento = document.createTextNode(descricaoProcedimento);	
   
       newCellNomeProcedimento.appendChild(newTextNomeProcedimento);
       newCellDescricaoProcedimento.appendChild(newTextDescricaoProcedimento);	
   }
   
   findProcedimentosExcecao = () => {        
       return [...document.querySelectorAll("input[name^='procedimentos_excecao_t[']")].filter((item, key) => {            
           if(item.dataset.descricaopreparoId != '') {                
               return item;    
           }
       });  
   }
   
   generateTabela = (procedimentosList) => {
       clearListLinhasTabelaProcedimentos();
       procedimentosList.forEach((item, key) => {            
           gerarLinhaTabelaProcedimentoExcecao(item.dataset.nomeprocedimento, item.dataset.descricaoprocedimento); 
           $('#modal-procedimentos-excecao').modal({
               show: 'true'
           });           
       });  
   }
   $('#modal-components').modal({
       backdrop: 'static',
       keyboard: false  // to prevent closing with Esc button (if you want this too)
   })

   function SalvaObservacao() {
      if ($("#ObsGeral").val() == "" ) {
         showMessageDialog("Campo Observação vazio", "danger")
         return false;
      }else{
      $.post("savePendencia.asp", `${$form.serialize()}&SalvarObservacao=true`, function(data) {
               showMessageDialog("Salvo com sucesso", "success")
               document.getElementById('termo-procedimentos').checked = false
               $("#ObsGeral").val("")
               })
      }
   }
   function SalvaPendencia(checkProcedimentosExcecao) {
   
       var retorno = true;
   
       $("#msg-alert").html("");
   
       if($("input[name='zona[]']").length == 0){
           retorno = false;
           $("#msg-alert").append(`<div class="alert alert-danger alert-border-left alert-dismissable">Favor selecionar a <b>ZONA</b> </div>`);
       }
   
       if($("input[name^='Dias']").length == 0){
           retorno = false;
           $("#msg-alert").append(`<div class="alert alert-danger alert-border-left alert-dismissable">Favor selecionar o <b>DIA</b> </div>`);
       }
   
       if (($("input[name='Requisicao']:checked").val() == "P" || $("input[name='Requisicao']:checked").val() == "S") && $.trim($("#ObsRequisicao").val()) == "") {
           retorno = false;
           $("#msg-alert").append(`<div class="alert alert-danger alert-border-left alert-dismissable">Favor escrever uma observação para a <b>REQUISIÇÃO</b> </div>`);
       }
   
       if (!$("input[name='Requisicao']").is(':checked')) {
           retorno = false;
           $("#msg-alert").append(`<div class="alert alert-danger alert-border-left alert-dismissable">Favor selecionar a <b>REQUISIÇÃO</b> </div>`);
       }
       
       if ($("input[name='Contato']:checked").val() == "O" && $.trim($("#ObsContato").val()) == "") {
           retorno = false;
           $("#msg-alert").append(`<div class="alert alert-danger alert-border-left alert-dismissable">Favor escrever uma observação para o <b>CONTATO</b> </div>`);
       }
   
       if (!$("input[name='Contato']").is(':checked')) {
           retorno = false;
           $("#msg-alert").append(`<div class="alert alert-danger alert-border-left alert-dismissable">Favor selecionar a <b>CONTATO</b> </div>`);
       }
   
       if (!retorno) {
           return false;
       }
   
       var diasSelecionados = [];
   
       $("#tblDias tr").each(function(tr){
           var arrDias = $(this).find("input[type=hidden][name^=Dias]").val();
           var arrTurnoM = $(this).find("input[type=checkbox][name^=DiasM]:checked").val();
           var arrTurnoT = $(this).find("input[type=checkbox][name^=DiasT]:checked").val();
           var arrObs = $(this).find("input[type=text][name^=Dias]").val();
   
           strData = arrDias;
           arrData = strData.split("/");
           novaData = arrData[2]+"-"+arrData[1]+"-"+arrData[0];
           diasSelecionados.push(novaData+","+arrTurnoM+","+arrTurnoT+","+arrObs);
       });
   
       $("#diasSelecionados").val(diasSelecionados.join("|"));
       
       procedimentosList = [];
       
       if(checkProcedimentosExcecao){
          procedimentosList = findProcedimentosExcecao();               
       }        
   
       if(procedimentosList != ''){
           generateTabela(procedimentosList);
           return;
       }
   
       let procedimentoExcecaoConcorda = (document.getElementById('termo-procedimentos').checked) ? 1 : 0
   
       function postSavePendencia(){
           $.post("savePendencia.asp", `${$form.serialize()}&procedimento_excecao_concorda=${procedimentoExcecaoConcorda}`, function(data) {
               showMessageDialog("Salvo com sucesso", "success")
               document.getElementById('termo-procedimentos').checked = false
               if ($("#StatusID").val() == 6) {
                   window.location.href='?P=Pendencias&Pers=1'
               }
           });
       }
   
       var status = $("#StatusID").val();
           if(status == 6){
              if ($("#trazerDocumento").is(':checked') && $("#tempoAntecedencia").is(':checked')){
                 $.post("pendenciasUtilities.asp",
                  {
                     acao: "VerificaPendencia",
                     PendenciaID: <%=PendenciaID%>},
                     function(data) {
                        if(data > 0){
                           showMessageDialog(
                              "É necessário que todos os procedimentos estejam agendados.",
                              "warning",
                              "Atenção",
                              5000
                           );                      
                        } else {
                           postSavePendencia(); 
                        }   
               });
              }else{
               if (!$("#trazerDocumento").is(':checked')) {
                  showMessageDialog(
                     "Trazer documentos",
                     "warning",
                     "Confirme todas as orientações",
                     5000
                  );
               }else{
                  showMessageDialog(
                     "Tempo de antecedência",
                     "warning",
                     "Confirme todas as orientações",
                     5000
                  );
               }
            }
           } else {
               postSavePendencia();
           }        
   }
   
   function obs(ProfissionalID) {
   
       $.get("ObsAgenda.asp?ProfissionalID=" + ProfissionalID, function (data) {
           $("#modalObservacao").modal("show")
           $(".modalObservacaoBody").html(data)
       });
   }
   
   $("input, textarea").change(function() {
       SalvaPendencia(true);
   });
   // criar regra e excecao dentro do modal em executor RealizarContato('14', '8'), 
</script>
<%
   end if
   %>