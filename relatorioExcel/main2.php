<?php
/**
 * Created by PhpStorm.
 * User: Vinicius
 * Date: 09/09/2016
 * Time: 16:47
 */
include "phpexcel/Classes/PHPExcel.php";
include "phpexcel/Classes/PHPExcel/IOFactory.php";

class htmlToExcel
{
    var $contentHTML;
    var $contentArray;
    var $objPHPExcel;
    var $tmpfile;
    var $filename;

    function __construct($title = "Relatório")
    {
        $this->filename = $_GET['N'].".xlsx";
        $this->PHPExcel();
        $this->get_content();
        $this->parse_content();
        $this->each_sheet();
    }

    function defineFileProperties($subject = null,$keywords = null,$category = null,$creator = 'Feegow Technologies',$description = 'Dados fornecidos por Feegow ltda.'){
        $this->objPHPExcel->getProperties()
            ->setCreator($creator)
            ->setTitle($this->filename)
            ->setDescription($description)
            ->setSubject($subject)
            ->setKeywords($keywords)
            ->setCategory($category)
        ;
    }

    function PHPExcel()
    {
        $this->objPHPExcel = new PHPExcel();
    }

    function get_content($params = null)
    {
        $filename = "http://localhost/feegowclinic/excel.asp?" . $params;
        $this->contentHTML = file_get_contents($filename);
    }
   
    function parse_content()
    {

//        REGEX PARA FILTRAR TR
        $pattern = "/<tr.*?>(.*?)<\/tr>/";
        preg_match_all($pattern, $this->contentHTML, $row);
        $row = $row[1];
//        INDICE DE CADA SHEET
        $SheetID = 0;
//        INDICA CADA ROW
        $TRi = 0;
//        VERIFICACAO DO RELATORIO
//        $verify = "<span class='0090'>";
        $arrayWithContent = array();
        for ($i = 0; $i < count($row); $i++) {
        $pattern = "/<td.*?>(.*?)<\/td>/";
            preg_match_all($pattern,$row[$i],$td);

            $count = count($td);
//            PRIMEIRA TR SÃO AS COLUNAS
            if ($i == 0) {
                foreach ($td as $col) {                 
                    if ($col != '') {
                        $this->contentArray["Cols"][] = $col;
                    }
                }
            } else {
                if (substr_count($row[$i],"data-title='1'") > 0) {
//                    TITULO E NOVA SHEET
                    $SheetID++;
                    $TRi = 0;
                    $value = str_replace(array($verify,"<span class='0090' data-title='1'>", "</span>"), array("","",""), $row[$i]);
                    $arrayWithContent[$SheetID]['Tit'] = $value;
                } else {
//                    INCREMENTA VALORES AO SHEET CRIADO
                    $cols = explode("</span>", $row[$i]);
                    foreach ($cols as $col) {
                        $col = str_replace($verify, "", $col);
                        if ($col != '') {
                            $arrayWithContent[$SheetID][$TRi][] = $col;
                        }
                    }
                    $TRi++;
                }
            }
            $this->contentArray["Values"] = $arrayWithContent;
        }
//        print_r($this->contentArray);
    }

    function each_sheet()
    {
        $sheetID = 0;
        $sheetCount = count($this->contentArray['Values']);
        foreach ($this->contentArray['Values'] as $sheetArray){
            $TRi = 2;

//            PRIMEIRA LINHA SÃO AS COLUNAS


            $this->objPHPExcel->setActiveSheetIndex($sheetID);
            for($i=0;$i<(count($sheetArray)-1);$i++){
                $TDi = 1;
                foreach ($sheetArray[$i] as $current_sheet){
                    $this->objPHPExcel->getActiveSheet()->setCellValue(chr(64+$TDi).$TRi, $current_sheet);
                    $TDi ++;
                }
//                echo $TRi;
                $TRi++;
            }

            $TDi = 1;
            foreach ($this->contentArray['Cols'] as $labelRow){
                $this->objPHPExcel->getActiveSheet()->setCellValue(chr(64+$TDi)."1", $labelRow);
                $this->objPHPExcel->getActiveSheet()->getStyle(chr(64+$TDi)."1")->getFont()->setBold(true);
                $TDi ++;
            }

//
            $this->objPHPExcel->getActiveSheet()->setTitle($sheetArray['Tit']);

            $sheetID++;

            if($sheetID != $sheetCount){
                $this->objPHPExcel->createSheet();
            }
        }
    }

    function download_xls()
    {
        header('Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'); // header for .xlxs file
        header('Content-Disposition: attachment;filename=' . $this->filename); // specify the download file name
        header('Cache-Control: max-age=0');

// Creates a writer to output the $objPHPExcel's content
        $writer = PHPExcel_IOFactory::createWriter($this->objPHPExcel, 'Excel2007');
        $writer->save('php://output');
        exit;

    }
}

$hte = new htmlToExcel();
//AQUI DEFINE AS PROPRIEDADOS DO ARQUIVO (ASSUNTO, CRIADOR ...)
$hte->defineFileProperties();
$hte->download_xls();