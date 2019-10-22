<!-- #include file = "connect.asp" -->
<!-- #include file = "UploadFuncoes.asp" -->
<style type="text/css">
    body{
        background-color:#fff!important;
        padding:0!important;
        margin:0!important;
    }
</style>
<link rel="stylesheet" type="text/css" href="assets/skin/default_skin/css/fgw.css">
<%
ProfissionalID = req("ProfissionalID")
if req("X")="S" then
    db.execute("update profissionais set Assinatura='' where id="& ProfissionalID)
end if

set vca = db.execute("select Assinatura from profissionais where id="& ProfissionalID &" and Assinatura not like ''")
if vca.eof then
    %>
    <form name="form1" action="./UploadAssinatura.asp?Pers=1&ProfissionalID=<%= ProfissionalID %>" method="post" enctype="multipart/form-data">
        <div class="panel mt20">
            <div class="panel-body">
                <div class="row">
                    <div class="col-md-3">
                        <input required type="file" name="foto">
                    </div>
                    <div class="col-md-3">
                        <button type="submit" class="btn btn-primary btn-xs" name="submit"><i class="fa fa-save"></i> Salvar</button>
                    </div>
                </div>
            </div>
        </div>
    </form>
<% else %>
<img src="./../uploads/<%= replace(session("Banco"), "clinic", "") &"/Imagens/"& vca("Assinatura") %>" class="img-thumbnail" width="100%" />
<br />
<button type="button" class="btn btn-block btn-danger btn-xs" onclick="if(confirm('Tem certeza de que deseja excluir esta assinatura?'))location.href='./Assinatura.asp?ProfissionalID=<%= ProfissionalID %>&X=S';">EXCLUIR</button>
<% end if %>