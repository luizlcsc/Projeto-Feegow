<?php
/*
* Criando e exportando planilhas do Excel
* /
*/
// Definimos o nome do arquivo que será exportado
$arquivo = 'planilha.xls';
// Criamos uma tabela HTML com o formato da planilha
$html = '';
$html .= '<table>';
$html .= '<tr>';
$html .= '<td colspan="3">Planilha teste</tr>';
$html .= '</tr>';
$html .= '<tr>';
$html .= '<td><b>Coluna 1</b></td>';
$html .= '<td><b>Coluna 2</b></td>';
$html .= '<td><b>Coluna 3</b></td>';
$html .= '</tr>';
$html .= '<tr>';
$html .= '<td>L1C1</td>';
$html .= '<td>L1C2</td>';
$html .= '<td>L1C3</td>';
$html .= '</tr>';
$html .= '<tr>';
$html .= '<td>L2C1</td>';
$html .= '<td>L2C2</td>';
$html .= '<td>L2C3</td>';
$html .= '</tr>';
$html .= '</table>';
// Configurações header para forçar o download
header ("Expires: Mon, 26 Jul 1997 05:00:00 GMT");
header ("Last-Modified: " . gmdate("D,d M YH:i:s") . " GMT");
header ("Cache-Control: no-cache, must-revalidate");
header ("Pragma: no-cache");
header ("Content-type: application/x-msexcel");
header ("Content-Disposition: attachment; filename=\"{$arquivo}\"" );
header ("Content-Description: PHP Generated Data" );
// Envia o conteúdo do arquivo
echo $html;
exit;