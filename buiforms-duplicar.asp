<!--#include file="connect.asp"-->
<!--#include file="connectCentral.asp"-->
<!--#include file="Classes/Json.asp"-->
<%

licencaMae = ""
LicencaOrigem = replace(session("Banco"), "clinic", "")

IF NOT ModoFranquia THEN
    set FranquiaCodigoSQL = db.execute("SELECT * FROM cliniccentral.licencas WHERE (Cupom,Franquia) = (SELECT Cupom,'P' FROM cliniccentral.licencas WHERE id="&replace(session("Banco"), "clinic", "")&")")

    IF FranquiaCodigoSQL.eof then
        Response.End
    END IF
    LicencaOrigem = FranquiaCodigoSQL("id")
    licencaMae = "clinic"&FranquiaCodigoSQL("id")
    set dblicense = newConnection(licencaMae,FranquiaCodigoSQL("Servidor"))
    licencaMae=licencaMae&"."
END IF
%>
<script src="https://unpkg.com/react@16.7.0/umd/react.production.min.js"></script>
<script src="https://unpkg.com/react-dom@16.7.0/umd/react-dom.production.min.js"></script>
<script src="https://unpkg.com/babel-standalone@6/babel.min.js"></script>
<script type="text/babel">


    <% IF ModoFranquia THEN
            sql = " SELECT buiforms.id                                                           "&chr(13)&_
                  "       ,buiforms.Nome                                                         "&chr(13)&_
                  "       ,buitiposforms.NomeTipo as Tipo                                        "&chr(13)&_
                  " FROM buiforms                                                                "&chr(13)&_
                  " LEFT JOIN buitiposforms ON buitiposforms.id = buiforms.Tipo                  "&chr(13)&_
                  " WHERE buiforms.sysActive = 1 and COALESCE(UnidadeID = 0,TRUE);               "
       ELSE
            sql = " SELECT buiforms.id                                                           "&chr(13)&_
                  "       ,buiforms.Nome                                                         "&chr(13)&_
                  "       ,buitiposforms.NomeTipo as Tipo                                        "&chr(13)&_
                  " FROM "&licencaMae&"buiforms                                                 "&chr(13)&_
                  " LEFT JOIN "&licencaMae&"buitiposforms ON buitiposforms.id = buiforms.Tipo   "&chr(13)&_
                  " WHERE buiforms.sysActive = 1;"
       END IF
    %>

    var Formularios     = <%= recordToJSON(dblicense.execute(sql))%>;
    var LicencaOrigem   = <%= LicencaOrigem %>;
    var LicencaDestino  = <%=replace(session("Banco"), "clinic", "") %>;
    var UnidadeID       = <%=session("UnidadeID") %>;

    var duplicarFunction = (form) => {
        bootbox.alert(`Deseja realmente importar o formulário "${form.Nome}"?`, function(){
            let url = `&model=${LicencaOrigem}&target=${LicencaDestino}&UnidadeID=${UnidadeID}&forms[]=${form.id}`;
            fetch(domain+"api/copy-forms?tk="+localStorage.getItem("tk")+url)
            .then(j => j.text())
            .then((json) => {
                $.gritter.add({
                    title: '<i class="far fa-download"></i>',
                    text:  'Formulario Importado',
                    class_name: 'gritter-success gritter-light'
                });
                window.location.href = `?P=buiforms&Pers=Follow`;
            });
        });
    };

    const App = () => {
        return  <div className="panel">
                       <div className="panel-heading">
                           <span className="panel-title">
                               Importação de Formulários
                           </span>
                       </div>
                       <div className="panel-body">
                            <table className="table table-striped table-bordered table-hover">
                                <thead>
                                    <tr className="info">
                                        <td width="5">ID</td>
                                        <td>Nome</td>
                                        <td>Tipo</td>
                                        <td width="10">#</td>
                                    </tr>
                                </thead>
                                <tbody>
                                     {Array.isArray(Formularios) && Formularios.map((item) => {
                                        return <tr>
                                            <td>{item.id}</td>
                                            <td>{item.Nome}</td>
                                            <td>{item.Tipo}</td>
                                            <td>
                                                <button type="button" onClick={() => duplicarFunction(item)} className="btn btn-dark btn-sm">
                                                    <i className="far fa-copy"></i> Importar
                                                </button>
                                            </td>
                                        </tr>
                                    })}
                                </tbody>
                            </table>
                       </div>
                   </div>;
    };

    ReactDOM.render(<App/>,document.getElementById('root'));
</script>
<script type="text/javascript">
    $(document).ready(function(){
        $(".crumb-active a").html("Formulários");
        $(".crumb-icon a").html("");
        $(".crumb-icon a span").attr("class", "far fa-bar-chart");
    });
</script>
<style>
    .align-right{text-align: right;}
</style>
<div style="padding: 20px;">
    <div id="root">
        <div style="font-size: 50px;text-align: center; padding: 40px">
            <i class="far fa-spin fa-circle-o-notch"></i>
        </div>
    </div>
</div>