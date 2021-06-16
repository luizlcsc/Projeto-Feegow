<!--#include file="connect.asp"-->
<!--#include file="AgendamentoUnificado.asp"-->
<%
profissionalIDFilho = ref("profissionalIDFilho")&""
profissionalIDMae = ref("profissionalIDMae")&""
licencaIDFilho = ref("licencaIDFilho")&""
licencaIDMae = ref("licencaIDMae")&""

vinculoStatus = -1
permissaoTipoTXT = "Permissão desativada"
alertType  = "warning"
tipoAgendamento = "desvincular"

desvinculoSucesso = false
acaoErro = true

if ref("vinculoStatus")="true" then
  vinculoStatus=1
  permissaoTipoTXT = "Permissão ativada"
  alertType  = "success"
  tipoAgendamento = "vincular"
end if

if vinculoStatus = -1 then
  call agendaUnificada(tipoAgendamento, 0, profissionalIDFilho)
end if

if profissionalIDMae<>"" and licencaIDMae=replace(session("Banco"),"clinic","") then
  if profissionalIDFilho<>"" and licencaIDFilho<>"" then
    
    qLicencaProfVinculadosSQL = " SELECT *                                                                                   "&chr(13)&_
                                " FROM cliniccentral.licencasprofissionaisvinculados                                                       "&chr(13)&_
                                " WHERE licencaIDMae="&licencaIDMae&" AND licencaIDFilho="&licencaIDFilho&" AND profissionalIDMae="&profissionalIDMae&" AND profissionalIDFilho="&profissionalIDFilho&""
    SET LicencaProfVinculadosSQL = db.execute(qLicencaProfVinculadosSQL)
    if LicencaProfVinculadosSQL.eof then
      qLicencaProfVinculadosAcaoSQL = " INSERT INTO `cliniccentral`.`licencasprofissionaisvinculados` "&chr(13)&_
      " (`licencaIDMae`,`licencaIDFilho`,`profissionalIDMae`,`profissionalIDFilho`,`sysUser`,`sysActive`) "&chr(13)&_
      " VALUES ("&licencaIDMae&","&licencaIDFilho&","&profissionalIDMae&","&profissionalIDFilho&","&session("User")&","&vinculoStatus&");"      
    else
      qLicencaProfVinculadosAcaoSQL = "UPDATE cliniccentral.`licencasprofissionaisvinculados` "&chr(13)&_
      " SET `sysActive`="&vinculoStatus&", `DHUp`="&myDateTime(now)&" "&chr(13)&_
      " WHERE  `licencaIDMae`="&licencaIDMae&" AND `licencaIDFilho`="&licencaIDFilho&" AND profissionalIDMae="&profissionalIDMae&" AND profissionalIDFilho="&profissionalIDFilho 
    end if

    db.execute(qLicencaProfVinculadosAcaoSQL)

    acaoErro   = false
    alertTitle = "Sucesso!"
    alertText  = permissaoTipoTXT
    
  end if

end if

if acaoErro=true then
  alertTitle = "Erro!"
  alertText  = "Ação não permitida"
  alertType  = "danger"
end if

if vinculoStatus = 1 then
  call agendaUnificada(tipoAgendamento, 0, profissionalIDFilho)
end if

if acaoErro=false AND desvinculoSucesso = true then
  alertTitle = "Desvinculado com sucesso"
  alertText  = "Bloqueios futuros foram desvinculados"
  alertType  = "warning"
end if
%>
new PNotify({
  title: '<%=alertTitle%>',
  text:  '<%=alertText%>',
  type:  '<%=alertType%>',
  delay: 3000
});
<%
response.end()
if profissionalIDFilho<>"" and licencaIDFilho<>"" and profissionalIDMae<>"" and licencaIDFilho<>"" then
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
