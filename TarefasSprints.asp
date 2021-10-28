<!--#include file="connect.asp"-->

<%
        sql =  " SELECT                                                                         "&chr(13)&_
           " t.id,                                                                              "&chr(13)&_
           " t.Ordem,                                                                           "&chr(13)&_
           " t.Titulo,                                                                          "&chr(13)&_
           " t.TempoEstimado,                                                                   "&chr(13)&_
           " t.TipoEstimado,                                                                    "&chr(13)&_
           " TIME_FORMAT(SEC_TO_TIME(t.TempoEstimado * t.TipoEstimado * 60), '%H:%i') AS Tempo  "&chr(13)&_
           " FROM sprints s                                                                     "&chr(13)&_
           " INNER JOIN tarefas t ON t.SprintID = s.id                                          "&chr(13)&_
           " WHERE s.id = "&req("I")                                                             &chr(13)&_
           " ORDER BY t.Ordem, t.Titulo"
        set sprints = db.execute(sql)
%>

        <script>
            function addRow() {
                $("#newQtd").val(parseInt($("#newQtd").val())+1);
                let num = $("#newQtd").val();
                let linha = '<tr>' +
                                '<td class="text-center">' +
                                    '<input type="number" class="form-control" name="NewOrdem'+num+'" id="NewOrdem'+num+'" value="" min="1">' +
                                '</td>' +
                                '<td class="text-center">' +
                                    '<input type="text" class="form-control" name="NewTitulo'+num+'" id="NewTitulo'+num+'" value="">' +
                                '</td>' +
                                '<td class="text-center">' +
                                    '<div class="row">' +
                                        '<div class="col-md-6">' +
                                            '<input type="number" class="form-control" name="NewTempoEstimado'+num+'" id="NewTempoEstimado'+num+'" value="0" min="0" step="0.01">' +
                                        '</div>' +
                                        '<div class="col-md-6">' +
                                            '<select name="NewTipoEstimado'+num+'" id="NewTipoEstimado'+num+'" class="form-control semvazio no-select2">' +
                                                '<option value="1">Minutos</option>' +
                                                '<option value="60">Horas</option>' +
                                                '<option value="1440">Dias</option>' +
                                            '</select>' +
                                        '</div>' +
                                    '</div>' +
                                '</td>' +
                                '<td class="text-center"></td>' +
                            '</tr>';

                $('#tasks tr:last').after(linha);
            }
        </script>
        <input id="newQtd" name="newQtd" type="hidden" value="0" />
        <div class="panel" style="margin-top:20px">
            <div class="panel-body" id="lista">
                <div class="col-md-12">
                    <table class="table table-striped table-hover table-bordered table-condensed" id="tasks">
                        <thead>
                          <tr>
                            <th style="width: 5%">Ordem</th>
                            <th style="width: 70%">Título</th>
                            <th>Tempo Estimado</th>
                            <th class="text-center"><button type="button" class="btn btn-xs btn-success mn" onclick="addRow();"><i class="far fa-plus"></i></button></th>
                          </tr>
                        </thead>
                        <tbody>
                        <% while not sprints.eof %>
                            <tr>
                                <td class="text-center"><%=sprints("Ordem")%></td>
                                <td class="text-center"><%=sprints("Titulo")%></td>
                                <td class="text-center"><%=sprints("Tempo")%></td>
                                <td class="text-center"><a href="./?P=Tarefas&I=<%=sprints("id")%>&Pers=1" target="_blank"><button type="button" class="btn btn-xs btn-primary mn"><i class="far fa-external-link"></i></button></a></td>
                            </tr>
                        <%
                           sprints.movenext
                           wend
                           sprints.close
                           set sprints=nothing
                        %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>