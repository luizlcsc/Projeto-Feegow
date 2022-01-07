<!--#include file="connect.asp"-->
<!--#include file="Classes/Json.asp"-->
<%
Acao = request.form("Acao")

sql = " SELECT pe.id pendenciaid,                                                                                                                                                                       "&chr(13)&_
" pe.sysUser usuarioid,                                                                                                                                                                           "&chr(13)&_
" DATE_FORMAT(pe.DHUp,'%d/%m/%Y') Data,                                                                                                                                                           "&chr(13)&_
" DATE_FORMAT(pe.DHUp,'%H:%i') Hora,                                                                                                                                                              "&chr(13)&_
" lu.nome usuario,                                                                                                                                                                                "&chr(13)&_
" retorna_nome_unidade(pe.UnidadeID) Unidade,                                                                                                                                                     "&chr(13)&_
" ps.NomeStatus,                                                                                                                                                                                  "&chr(13)&_
" pa.NomePaciente,                                                                                                                                                                                "&chr(13)&_
" (SELECT GROUP_CONCAT(pr.NomeProcedimento) FROM pendencia_procedimentos pp                                                                                                                       "&chr(13)&_
" JOIN agendacarrinho ac ON ac.id = pp.BuscaID                                                                                                                                                    "&chr(13)&_
" JOIN procedimentos pr ON pr.id = ac.ProcedimentoID                                                                                                                                              "&chr(13)&_
" WHERE pp.pendenciaID = pe.id  ) Procedimento ,                                                                                                                                                  "&chr(13)&_
" pe.Zonas, CASE pe.Requisicao WHEN 'C' THEN 'Central' WHEN 'P' THEN 'Particular' WHEN 'S' THEN 'SUS' END Requisicao, CASE pe.Contato WHEN 'P' THEN 'Paciente' WHEN 'O' THEN 'Outro' END Contato, "&chr(13)&_
" pe.ObsRequisicao,                                                                                                                                                                               "&chr(13)&_
" pe.ObsContato,                                                                                                                                                                                  "&chr(13)&_
" pe.ObsExclusao,                                                                                                                                                                                 "&chr(13)&_
" me.Motivo,                                                                                                                                                                                      "&chr(13)&_
" pe.sysActive                                                                                                                                                                                    "&chr(13)&_
" FROM pendencias pe                                                                                                                                                                              "&chr(13)&_
" JOIN pendenciasstatus ps ON ps.id = pe.StatusID                                                                                                                                                 "&chr(13)&_
" JOIN cliniccentral.licencasusuarios lu ON lu.id = pe.sysUser                                                                                                                                    "&chr(13)&_
" LEFT JOIN motivoexclusao me ON me.Id = pe.MotivoExclusaoID                                                                                                                                      "&chr(13)&_
" LEFT JOIN pacientes pa ON pa.id = pe.PacienteID                                                                                                                                                 "&chr(13)&_
" ORDER BY pe.DHUp DESC                                                                                                                                                                           " 

If Acao = "pendencia" Then %>

<% End If %>
