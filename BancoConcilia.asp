<!-- #include file = "connect.asp" -->
<!-- #include file = "UploadFuncoes.asp" -->
<form name="form1" action="./?P=UploadOFX&Pers=1" method="post" enctype="multipart/form-data">
<input hidden name="bancoConcilia" value="true">
    <div class="panel mt20">
        <div class="panel-body">
            <div class="col-md-3">
                Arquivo: <input required type="file" name="foto" size="14">
            </div>
            <%= quickfield("simpleSelect", "ContaID", "Conta bancária", 3, "", "select * from sys_financialcurrentaccounts where sysActive=1 AND AccountType=2 ORDER BY AccountName", "AccountName", " required semVazio ") %>
            <div class="col-md-2">
                <button type="submit" class="mt25 btn btn-primary" name="submit">ENVIAR</button>
            </div>
        </div>
    </div>
</form>
