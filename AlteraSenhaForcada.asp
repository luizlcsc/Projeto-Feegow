<%
set usr = db.execute("SELECT lu.Email, u.idInTable FROM cliniccentral.licencasusuarios lu LEFT JOIN sys_users u ON u.id = lu.id WHERE lu.id = "&session("User"))

txt = "O período de validade de sua senha venceu. Favor altere-a, escolhendo uma senha diferente da anterior."
if session("AlterarSenha") = "1" then
    txt = "É necessário definir uma nova senha."
end if

if not usr.eof then
%>
<div id="modal-alterar-senha" class="modal fade" role="dialog" data-keyboard="false" data-backdrop="static">
  <div class="modal-dialog">

    <!-- Modal content-->
    <form id="form-alterar-senha">
        <input type="hidden" name="I" id="I" value="<%=session("idInTable")%>">
        <input type="hidden" name="T" id="T" value="<%=session("Table")%>">
        <input type="hidden" name="User" id="User-email" value="<%=usr("Email")%>">
        <input type="hidden" name="E" value="E">
        <input type="hidden" name="ForcarAlteracao" value="S">
        <div class="modal-content">
          <div class="modal-header">
            <h4 class="modal-title">Alteração de senha</h4>
          </div>
          <div class="modal-body">
            <p><%=txt%></p>
            <div class="col-md-6">
                <label for="senha-acesso">Digite sua senha</label>
                <input name="password" type="password" id="senha-acesso" class="form-control">
                <span id="erro-senha" style="color: #cf0100;font-size: 12px;display: none;">A senha deve possuir mais de 8 caracteres. Ao menos um número e uma letra.</span>
            </div>
            <div class="col-md-6">
                <label for="password2">Repita sua senha</label>
                <input name="password2" type="password" id="password2" class="form-control">
            </div><br><br>
          </div>
          <div class="modal-footer mt70">
            <button class="btn btn-primary"><i class="far fa-save"></i> Salvar</button>
          </div>
        </div>
    </form>

  </div>
</div>
<script >
    ModalOpened=true;

    $(document).ready(function() {
          
        $("#modal-alterar-senha").modal("show");
        var $senha = $("#senha-acesso");
        var $formAlterarSenha = $("#form-alterar-senha");
        var $erroSenha = $("#erro-senha");

        $formAlterarSenha.submit(function() {
                  var str = $senha.val();
                  var regex = /(?:[A-Za-z].*?\d|\d.*?[A-Za-z])/;
                  var hasNumerAndLetter = !!str.match(regex);
                  var moreThan8 = str.length >= 8;

                  if((moreThan8 && hasNumerAndLetter )){
                      $erroSenha.fadeOut();

                      $.ajax({
                            type:"POST",
                            url:"saveAcesso2.asp",
                            data:$(this).serialize(),
                            success:function(data){
                                eval(data);
                            }
                        });
                  }else{
                      $erroSenha.fadeIn();
                  }
                return false;
        });

    });
</script>
<%
end if
%>