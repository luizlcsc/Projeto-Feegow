<!--#include file="connect.asp"-->
<%
licencaMae    = ref("licMae")&""
licencaFilho  = ref("licFilho")&""

if licencaMae<>"" and licencaFilho<>"" then
  set FranquiaCodigoSQL = db.execute("SELECT id, NomeContato, DataHora, Status, Cupom FROM cliniccentral.licencas WHERE Franquia='P' AND id="&session("Franquia"))
  if FranquiaCodigoSQL.eof then
      Response.End
  else
      FranquiaCodigo = FranquiaCodigoSQL("Cupom")&""

      qLicencasSelectSQL =  " SELECT lic.id,lic.NomeContato as Nome "&chr(13)&_
                            " FROM cliniccentral.licencas lic                                    "&chr(13)&_
                            " LEFT JOIN cliniccentral.softwares s ON s.id=lic.SoftwareAnteriorID "&chr(13)&_
                            " WHERE lic.Cupom='"&FranquiaCodigo&"' AND STATUS<>'B' AND lic.Franquia='S' AND lic.id="&licencaFilho

      'response.write("console.log(`"&qLicencasSelectSQL&"`)")
      set LicencasSelectSQL = db.execute(qLicencasSelectSQL)
      if not LicencasSelectSQL.eof then
        qLicencaVinculadaUpdateSQL = "UPDATE `cliniccentral`.`licencas` SET `LicencaIDMae`='"&licencaMae&"' WHERE id="&licencaFilho&";"
        db.execute(qLicencaVinculadaUpdateSQL)

        alertTitle = "Sucesso!"
        alertText  = "Gerenciamento alterado."
        alertType  = "success"
      else
        alertTitle = "Erro!"
        alertText  = "Ação não permitida"
        alertType  = "danger"
      end if
      LicencasSelectSQL.close
      set LicencasSelectSQL = nothing
  end if
FranquiaCodigoSQL.close
set FranquiaCodigoSQL = nothing
end if
%>

new PNotify({
  title: '<%=alertTitle%>',
  text:  '<%=alertText%>',
  type:  '<%=alertType%>',
  delay: 3000
});
