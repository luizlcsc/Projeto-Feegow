<!--#include file="connect.asp"-->


<body>
    <% 
        valorSQL = "SELECT sa.MensalidadeIndividual custo FROM cliniccentral.servicosadicionais sa WHERE sa.id =43;"
        SET  valor = db.execute(valorSQL)
        
        custoMSG  = valor("custo")
        custoMSG = formatNumber(custoMSG, 2)
        valor.close
        SET valor  = nothing
        
    %>
    <div class="container-fluid">

        <div class="row mt35">
            <div class="col-md-12">
                <div class="panel-heading">
                    <div class="painel-title ml50"> Custo por notificação enviada 
                        <span id ="custoWhatsapp" class="badge badge-pink">R$ <%=custoMSG%></span>
                    </div>
                </div>
            </div>
        </div>

        <div class="panel">
            <div class="panel-body mt20 ">
                <div id="divProcedimentoRapido">

                </div>
                <table id="table-" class="table table-striped table-bordered table-hover">
                    <thead>
                        <tr class="info">
                            <th class="center hidden-xs" width="1%">
                                <label>
                                    <input type="checkbox" class="ace">
                                    <span class="lbl"></span>
                                </label>
                            </th>
                            
                                <th class="">Descrição</th>

                                <th class=" hidden-xs ">Conteúdo</th>
                                
                                <th class=" hidden-xs ">Ativo</th>
                                
                                <th class=" hidden-xs ">Enviar para</th>
                                
                            <th width="1%" class="hidden-print"></th>
                        </tr>
                    </thead>
        
                    <tbody>
                        
                        <tr>
                            <td class="center hidden-xs">
                                <label>
                                    <input type="checkbox" class="ace">
                                    <span class="lbl"></span>
                                </label>
                            </td>
                            
                                    <td class="">
                                        <a href="?P=eventos_emailsms&amp;I=1&amp;Pers=0">Confirmação de Agendamentos Teste</a>
                                    </td>

                                    <td class="hidden-xs">
                                        <span class="text-truncate">Texto grande pra caraca que virá de algum lugar e por isso estou usando o text.trucate do bootstrap</span>
                                    </td>
                                    <td class=" hidden-xs ">
                                        Ativo
                                    </td>
                                    
                                    <td class=" hidden-xs ">
                                        Pacientes
                                    </td>
                                    
                            <td width="1%" nowrap="nowrap" class="hidden-print">
                                <div class="action-buttons">
                                    

                                    <a class="btn btn-l btn-success tooltip-success" data-toggle="modal" data-target="#modalModelo1" data-rel="tooltip" title="" href="" data-original-title="Mostrar Modelo">
                                        Mostrar
                                    </a>
                                </div>
        
                            </td>
                        </tr>
                        
                    </tbody>
                </table>
            </div>
        </div>
        <div class="modal" id="modalModelo1" >
                <div class="modal-dialog">
                    <div class="modal-content">
                        qualquer coisa para teste<br/>
                        qualquer coisa para teste<br/>
                        qualquer coisa para teste<br/>
                        qualquer coisa para teste<br/>
                        qualquer coisa para teste<br/>
                        qualquer coisa para teste<br/>
                    </div>
                </div>
        </div>
        
    </div>
</body>
</html>

<!--#include file="disconnect.asp"-->