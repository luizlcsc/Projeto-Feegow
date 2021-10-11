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

        <div class="panel">
            <div class="panel-body mt20 ">
                <div id="divProcedimentoRapido">

                </div>
                <table id="table-" class="table table-striped table-bordered table-hover">
                    <thead>
                        <tr class="info">
                           
                                <th class=" hidden-xs ">Tipo</th>

                                <th class=" hidden-xs">Descrição</th>
                                
                                <th class=" hidden-xs ">Ações</th>

                                <th class=" hidden-xs ">Ativo</th>
                                
                            <th width="1%" class="hidden-print"></th>
                        </tr>
                    </thead>
        
                    <tbody>
                        
                        <tr>
                            
                                    <td class="">
                                        <a href="?P=eventos_emailsms&amp;I=1&amp;Pers=0">Confirmação de Agendamentos Teste</a>
                                    </td>

                                    <td class="hidden-xs">
                                        <span class="text-truncate">Utilizado para confirmar agendamentos ...</span>
                                    </td>

                                    <td class=" hidden-xs ">
                                        <button data-toggle="modal" data-target="#modalModel" class="fa fa-eye"></button>
                                    </td>

                                    <td >
                                        <input id="ativoCheckbox"  type="checkbox" />
                                    </td>

                        </tr>
                        <div id="modalModel" class="modal">
                            <div class="modal-dialog">
                                <div class="modal-content">
                                    Teste Teste Teste Teste Teste <br/>
                                    Teste Teste Teste Teste Teste <br/>
                                    Teste Teste Teste Teste Teste <br/>
                                    Teste Teste Teste Teste Teste <br/>
                                    Teste Teste Teste Teste Teste <br/>
                                    Teste Teste Teste Teste Teste <br/>
                                    Teste Teste Teste Teste Teste <br/>
                                    Teste Teste Teste Teste Teste <br/>
                                    Teste Teste Teste Teste Teste <br/>
                                </div>
                            </div>
                        </div>
                        
                    </tbody>
                </table>
                <script>
                    const checkbox = document.getElementById("ativoCheckbox")

                    checkbox.addEventListener("change",()=>{
                        setTimeout(()=>{checkbox.checked == true?alert("Marcado"):alert("Desmarcado");},10)
                         
                    })
                    
                </script>
            </div>
        </div>
    </div>
</body>
</html>

<!--#include file="disconnect.asp"-->