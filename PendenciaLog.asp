<!--#include file="connect.asp"-->
<div class="panel">
    <div class="panel-body">
        <div class="bs-component">
            <div class="panel">
                <div class="panel-heading">
                    <ul class="nav panel-tabs-border panel-tabs panel-tabs-left" id="myTab">
                        <li class="active">
                            <a data-toggle="tab" href="#Pendencia" id="tabPendencia">
                                Pendência 
                            </a>
                        </li>
                        <li>
                            <a data-toggle="tab" href="#Data" id="tabData">
                                Datas
                            </a>
                        </li>
                        <li>
                            <a data-toggle="tab" href="#Procedimento" id="tabProcedimento">
                                Procedimentos
                            </a>
                        </li>
                        <li>
                            <a data-toggle="tab" href="#Contato" id="tabContato">
                                Contatos
                            </a>
                        </li>
                    </ul>
                </div>
                <div class="panel-body">
                    <div class="tab-content pn br-n">
                        <div id="Pendencia" class="tab-pane active widget-box transparent">
                            <table class="table table-striped">
                                <thead>
                                    <tr class="success">
                                        <th>ID</th>
                                        <th>Data registro</th>
                                        <th>Hora registro</th>
                                        <th>Usuário</th>
                                        <th>Paciente</th>
                                        <th>Zonas</th>
                                        <th>Requisição</th>
                                        <th>Observação da requisição</th>
                                        <th>Contato</th>
                                        <th>Observação do contato</th>
                                        <th>Status</th>
                                        <th>Ativo</th>
                                        <th>Observação da exclusão</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr class="danger">
                                        <th> 999999 </th>
                                        <td> 99/99/9999 </td>
                                        <td> 99:99 </td>
                                        <td> USUARIO </td>
                                        <td> PACIENTE </td>
                                        <td> ZONAS </td>
                                        <td> REQUISICAO </td>
                                        <td> REQUISICAOOBS </td>
                                        <td> CONTATO </td>
                                        <td> CONTATOOBS </td>
                                        <td> STATUS </td>
                                        <td> ATIVO </td>
                                        <td> OBSEXCLUSAO </td>
                                    </tr>
                                    <tr>
                                        <th> 999999 </th>
                                        <td> 99/99/9999 </td>
                                        <td> 99:99 </td>
                                        <td> USUARIO </td>
                                        <td> PACIENTE </td>
                                        <td> ZONAS </td>
                                        <td> REQUISICAO </td>
                                        <td> REQUISICAOOBS </td>
                                        <td> CONTATO </td>
                                        <td> CONTATOOBS </td>
                                        <td> STATUS </td>
                                        <td> ATIVO </td>
                                        <td> OBSEXCLUSAO </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                        <div id="Data" class="tab-pane">
                            <table class="table table-striped">
                                <thead>
                                    <tr class="success">
                                        <th>ID</th>
                                        <th>Data registro</th>
                                        <th>Hora registro</th>
                                        <th>Usuário</th>
                                        <th>Paciente</th>
                                        <th>Data selecionada</th>
                                        <th>Turno manhã</th>
                                        <th>Turno tarde</th>
                                        <th>Observação</th>
                                        <th>Ativo</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr class="danger">
                                        <th> 999999 </th>
                                        <td> 99/99/9999 </td>
                                        <td> 99:99 </td>
                                        <td> USUARIO </td>
                                        <td> PACIENTE </td>
                                        <td> 99/99/9999 </td>
                                        <td> TURNOMANHA </td>
                                        <td> TURNOTARDE </td>
                                        <td> OBSERVACAO </td>
                                        <td> ATIVO </td>
                                    </tr>
                                    <tr>
                                        <th> 999999 </th>
                                        <td> 99/99/9999 </td>
                                        <td> 99:99 </td>
                                        <td> USUARIO </td>
                                        <td> PACIENTE </td>
                                        <td> 99/99/9999 </td>
                                        <td> TURNOMANHA </td>
                                        <td> TURNOTARDE </td>
                                        <td> OBSERVACAO </td>
                                        <td> ATIVO </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                        <div id="Procedimento" class="tab-pane">
                            <table class="table table-striped">
                                <thead>
                                    <tr class="success">
                                        <th>ID</th>
                                        <th>Data registro</th>
                                        <th>Hora registro</th>
                                        <th>Usuário</th>
                                        <th>Paciente</th>
                                        <th>Procedimento</th>
                                        <th>Ativo</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr class="danger">
                                        <th> 999999 </th>
                                        <td> 99/99/9999 </td>
                                        <td> 99:99 </td>
                                        <td> USUARIO </td>
                                        <td> PACIENTE </td>
                                        <td> PROCEDIMENTO </td>
                                        <td> ATIVO </td>
                                    </tr>
                                    <tr>
                                        <th> 999999 </th>
                                        <td> 99/99/9999 </td>
                                        <td> 99:99 </td>
                                        <td> USUARIO </td>
                                        <td> PACIENTE </td>
                                        <td> PROCEDIMENTO </td>
                                        <td> ATIVO </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                        <div id="Contato" class="tab-pane">
                            <table class="table table-striped">
                                <thead>
                                    <tr class="success">
                                        <th>ID</th>
                                        <th>Data registro</th>
                                        <th>Hora registro</th>
                                        <th>Usuário</th>
                                        <th>Paciente</th>
                                        <th>Procedimento</th>
                                        <th>Data selecionada</th>
                                        <th>Hora selecionada</th>
                                        <th>Valor</th>
                                        <th>Profissional</th>
                                        <th>Observação</th>
                                        <th>Contato</th>
                                        <th>Status</th>
                                        <th>Ativo</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr class="danger">
                                        <th> 999999 </th>
                                        <td> 99/99/9999 </td>
                                        <td> 99:99 </td>
                                        <td> USUARIO </td>
                                        <td> PACIENTE </td>
                                        <td> PROCEDIMENTO </td>
                                        <td> 99/99/9999 </td>
                                        <td> 99:99 </td>
                                        <td> 999,99 </td>
                                        <td> PROFISSIONAL </td>
                                        <td> OBSERVACAO </td>
                                        <td> CONTATO </td>
                                        <td> STATUS </td>
                                        <td> ATIVO </td>
                                    </tr>
                                    <tr>
                                        <th> 999999 </th>
                                        <td> 99/99/9999 </td>
                                        <td> 99:99 </td>
                                        <td> USUARIO </td>
                                        <td> PACIENTE </td>
                                        <td> PROCEDIMENTO </td>
                                        <td> 99/99/9999 </td>
                                        <td> 99:99 </td>
                                        <td> 999,99 </td>
                                        <td> PROFISSIONAL </td>
                                        <td> OBSERVACAO </td>
                                        <td> CONTATO </td>
                                        <td> STATUS </td>
                                        <td> ATIVO </td>
                                    </tr>
                                </tbody>
                            </table>

                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>