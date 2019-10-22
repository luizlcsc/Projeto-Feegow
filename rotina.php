<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

/**
 * Created by PhpStorm.
 * User: Vinicius Maia
 * Date: 17/03/2016
 * Time: 17:57
 */

/**
 * @param $ProfissionalID
 * @param $LocalID
 * @return mixed|string
 */
    class disponiblidade
    {

        var $disponivel = array();
		var $disponivelF = array();
        var $ProfissionalID;
        var $LocalID;
        var $banco;
        var $horariospreenchidos = array();
        var $aceiteConfig = array();

        public function __construct($ProfissionalID, $LocalID, $banco){
        $this->ProfissionalID = $ProfissionalID;
            $this->LocalID = $LocalID;
            $this->banco = $banco;

            $this->gradePadrao();
            $this->excecoes();
            $this->bloqueio();
            $this->horariosPreenchidos();
            $res = $this->grade();
            var_dump($res);
}

        function gradeBD($ProfissionalID)
        {
            $this->ProfissionalID = $ProfissionalID;
            $mysqli = $this->con();

            if ($stmt = $mysqli->prepare("SELECT Grade FROM profissionais WHERE id = ?")) {
                $stmt->bind_param('i', $this->ProfissionalID);
                $stmt->execute();

                $result = $stmt->get_result()->fetch_assoc();

                $this->disponivel = json_decode($result["Grade"], true);
            }
        }

        function gradePadrao()
        {
            
            $mysqli = $this->con();

            if ($stmt = $mysqli->prepare("SELECT g.* FROM assfixalocalxprofissional g LEFT JOIN locais l on l.id=g.LocalID WHERE g.ProfissionalID=? AND l.UnidadeID=? ORDER BY g.HoraDe")) {
                $stmt->bind_param("ii", $this->ProfissionalID, $this->LocalID);
                $stmt->execute();

                $result = $stmt->get_result();
            }

//MOSTRA TODOS OS HORARIOS DA SEMANA

            $i = 0;
            while ($assFixaLocalXProfissionalArray = $result->fetch_assoc()) {
                $i++;
                $diaSemanaInt = (int) $assFixaLocalXProfissionalArray['DiaSemana'] -1 ;

                switch ($diaSemanaInt) {
                    case 0:
                        $diaSemanaVarchar = 'sunday';
                        break;
                    case 1:
                        $diaSemanaVarchar = 'monday';
                        break;
                    case 2:
                        $diaSemanaVarchar = 'tuesday';
                        break;
                    case 3:
                        $diaSemanaVarchar = 'wednesday';
                        break;
                    case 4:
                        $diaSemanaVarchar = 'thursday';
                        break;
                    case 5:
                        $diaSemanaVarchar = 'friday';
                        break;
                    case 6:
                        $diaSemanaVarchar = 'saturday';
                        break;
                }

                $proximoDiaSemana = date('Y-m-d', strtotime('next ' . $diaSemanaVarchar));


                if (($diaSemanaInt) == date('w')) {
                    $dataParaSubtrair = date_create($proximoDiaSemana);
                    $tira7 = date_sub($dataParaSubtrair, date_interval_create_from_date_string("7 days"));
                    $dateYMD = date_format($tira7, 'Y-m-d');

                } else {
                    $dateYMD = $proximoDiaSemana;
                }

                $dateYMD = new DateTime($dateYMD);
                $horade = $assFixaLocalXProfissionalArray['HoraDe'];
                $horaa = $assFixaLocalXProfissionalArray['HoraA'];
                $intervalo = $assFixaLocalXProfissionalArray['Intervalo'];

                //hora inicial
                $horaInicial = new DateTime($horade);

                //hora final
                $horaFinal = new DateTime($horaa);

                $datePlus = new DateTime(date("Y-m-d"));
                $datePlus30 = $datePlus->modify("+30 days");

                $gradeEmCadaData = array();


                for ($dateToIncrement = $dateYMD; $dateToIncrement <= $datePlus30; $dateYMD->modify("7 days")) {
                    $horaInicial = new DateTime($horade);
                    if (!isset($this->disponivel[$dateToIncrement->format('Y-m-d')])) {
                        $this->disponivel[$dateToIncrement->format('Y-m-d')] = array();
                    }
                    for ($co = 0; $horaInicial <= $horaFinal; $co++) {
                        if (date("Y-m-d") == date("Y-m-d", strtotime($dateToIncrement->format("Y-m-d")))) {
                            if (date("H:i:s") < date("H:i:s", strtotime($horaInicial->format("H:i:s")))) {
                                $this->disponivel[$dateToIncrement->format('Y-m-d')][] = $horaInicial->format("H:i:s");
                            }
                        } else {
                            $this->disponivel[$dateToIncrement->format('Y-m-d')][] = $horaInicial->format("H:i:s");
                        }
                        $horaInicial->modify("+" . $intervalo . " minutes");
                    }
                }

            }//ACABA
            $mysqli->close();
        }

        private function con()
        {
            $g_link = new mysqli('localhost', 'root', 'pipoca453', $this->banco);
            if ($g_link->connect_error) {
                die('Erro de conexão (' . $g_link->connect_errno . ') '
                    . $g_link->connect_error);
            }
            return $g_link;
        }

        function bloqueio()
        {
            $mysqli = $this->con();
            if ($stmt = $mysqli->prepare("SELECT DISTINCT * FROM compromissos WHERE ProfissionalID=? AND DataDe >= date(now())")) {
                $stmt->bind_param("i", $this->ProfissionalID);
                $stmt->execute();
                $result = $stmt->get_result();

                while ($bloqueios = $result->fetch_assoc()) {
                    $dataDe = new DateTime($bloqueios["DataDe"]);
                    $dataA = new DateTime($bloqueios["DataA"]);
                    $horaInicial = new DateTime($bloqueios["HoraDe"]);
                    $horaFinal = new DateTime($bloqueios["HoraA"]);
                    $diasSemana = explode(" ", $bloqueios['DiasSemana']);

                    while ($dataDe <= $dataA) {
                        foreach ($diasSemana as $diaSemana) {
                            if (($diaSemana) == date("w", strtotime($dataDe->format("Y-m-d"))) && isset($this->disponivel[$dataDe->format("Y-m-d")])) {
                                foreach ($this->disponivel[$dataDe->format("Y-m-d")] as $key => $horarios) {
                                    $horario = new DateTime($horarios);
                                    if ($horario >= $horaInicial && $horario <= $horaFinal) {
                                        unset($this->disponivel[$dataDe->format("Y-m-d")][$key]);
                                    }
                                }
                            }
                        }
                        $dataDe->modify("+1 day");
                    }
                }
            }
        }

        function excecoes()
        {
            $mysqli = $this->con();
            if ($stmt = $mysqli->prepare("SELECT DISTINCT ex.* FROM assperiodolocalxprofissional ex LEFT JOIN locais l on l.id=ex.LocalID WHERE ex.ProfissionalID =? AND l.UnidadeID=? AND ex.DataA >= date(now())")) {
                $stmt->bind_param("ii", $this->ProfissionalID, $this->LocalID);
                $stmt->execute();
                $result = $stmt->get_result();
            }

            $i = 0;
            while ($excecoesArray = $result->fetch_assoc()) {
                $dataDe = new DateTime($excecoesArray["DataDe"]);
                $dataA = new DateTime($excecoesArray["DataA"]);
                $horaInicial = new DateTime($excecoesArray["HoraDe"]);
                $horaFinal = new DateTime($excecoesArray["HoraA"]);
                $intervalo = $excecoesArray['Intervalo'];

                $datas = array();
                if ($horaInicial == $horaFinal) {
                    $dateToRemove = new DateTime($excecoesArray["DataDe"]);
                    while ($dateToRemove <= $dataA) {
                        unset($this->disponivel[$dateToRemove->format("Y-m-d")]);
                        $dateToRemove->modify("+1 day");
                    }
                } else {
                    while ($dataDe <= $dataA) {
                        $horaInicial = new DateTime($excecoesArray["HoraDe"]);
                        if (isset($this->disponivel[$dataDe->format('Y-m-d')]) && $i > 0) {
                            if (!isset($datas[$dataDe->format("Y-m-d")])) {
                                $this->disponivel[$dataDe->format('Y-m-d')] = array();
                            }
                            for ($co = 0; $horaInicial <= $horaFinal; $co++) {
                                if (date("Y-m-d") == date("Y-m-d", strtotime($dataDe->format("Y-m-d")))) {
                                    if (date("H:i:s") < date("H:i:s", strtotime($horaInicial->format("H:i:s")))) {
                                        $this->disponivel[$dataDe->format('Y-m-d')][] = $horaInicial->format("H:i:s");
                                    }
                                }
                                $horaInicial->modify("+" . $intervalo . " minutes");

                            }
                        } else {
                            $this->disponivel[$dataDe->format('Y-m-d')] = array();
                            $datas[] = $dataDe->format("Y-m-d");
                            for ($co = 0; $horaInicial <= $horaFinal; $co++) {
                                if (date("Y-m-d") == date("Y-m-d", strtotime($dataDe->format("Y-m-d")))) {
                                    if (date("H:i:s") < date("H:i:s", strtotime($horaInicial->format("H:i:s")))) {
                                        $this->disponivel[$dataDe->format('Y-m-d')][] = $horaInicial->format("H:i:s");
                                    }
                                } else {

                                    $this->disponivel[$dataDe->format('Y-m-d')][] = $horaInicial->format("H:i:s");
                                }
                                $horaInicial->modify("+" . $intervalo . " minutes");
                            }
                        }
                        $dataDe->modify("+1 day");
                    }
                    $i++;
                }
            }

            $mysqli->close();
        }

        public function horariosPreenchidos()
        {
			$this->disponivelF = $this->disponivel;

            $mysqli = $this->con();
            if ($stmt = $mysqli->prepare("SELECT a.Data, a.Hora, a.Tempo, if(a.rdValorPlano='V', 0, a.ValorPlano) ConvenioID FROM agendamentos a LEFT JOIN locais l on l.id=a.LocalID WHERE a.ProfissionalID = ? AND l.UnidadeID = ? AND Data >= date(now()) order by a.Hora")) {
                $stmt->bind_param("ii", $this->ProfissionalID, $this->LocalID);
                $stmt->execute();
                $result = $stmt->get_result();

                while ($arrayPreenchidos = $result->fetch_assoc()) {
                    $data = new DateTime($arrayPreenchidos['Data']);
                    $hora = new DateTime($arrayPreenchidos['Hora']);

                    if (!is_null($arrayPreenchidos['Tempo']) && $arrayPreenchidos['Tempo'] != 0 && !empty($arrayPreenchidos['Tempo'])) {
                        $horaAteCls = new DateTime($arrayPreenchidos['Hora']);
                        $horaAte = $horaAteCls->modify("+" . ($arrayPreenchidos['Tempo'] - 1) . " minutes");
                        if (isset($this->disponivel[$data->format("Y-m-d")])) {
                        $ok = false;
                            foreach ($this->disponivel[$data->format("Y-m-d")] as $loopkey => $loopHorario) {
                                $horarioGrade = new DateTime($loopHorario);
                                if ($horarioGrade >= $hora && $horarioGrade <= $horaAte) {
                                    unset($this->disponivelF[$data->format("Y-m-d")][$loopkey]);
									$this->disponivelF[$data->format("Y-m-d")][] .= $hora->format("H:i:s").'_'.$arrayPreenchidos['ConvenioID'];
                                    $ok = true;
                                }
                            }
                            if(!$ok){
                                                                   $this->disponivelF[$data->format("Y-m-d")][] = $hora->format("H:i:s").'_'.$arrayPreenchidos['ConvenioID'];

}
                        }
                    } else {
                        if (isset($this->disponivel[$data->format("Y-m-d")])) {
                        $ok = false;
                            foreach ($this->disponivel[$data->format("Y-m-d")] as $loopkey => $loopHorario) {
                                if ($this->disponivel[$data->format("Y-m-d")][$loopkey] == $hora->format("H:i:s")) {
									unset($this->disponivelF[$data->format("Y-m-d")][$loopkey]);
                                    $this->disponivelF[$data->format("Y-m-d")][] .= $hora->format("H:i:s").'_'.$arrayPreenchidos['ConvenioID'];
                                    $ok = true;
                                }
                            }
                            if(!$ok){
                                       $this->disponivelF[$data->format("Y-m-d")][] = $hora->format("H:i:s").'_'.$arrayPreenchidos['ConvenioID'];
}
                        }
                    }
                }
                $mysqli->close();
            }
        }

     
        public function grade()
        {
            $json = json_encode($this->disponivelF);
            $mysqli = $this->con();


            if ($stmt = $mysqli->prepare("UPDATE locaisxprofissionais SET Grade = ? WHERE ProfissionalID=? AND LocalID=?")) {
                $stmt->bind_param("sii", $json, $this->ProfissionalID,$this->LocalID);
                $stmt->execute();
            }
                    return $json;

        }

        public function removerHorario($data, $hora)
        {
            if (@($key = array_search($hora, $this->disponivel[$data])) !== false) {
                unset($this->disponivel[$data][$key]);
            }
        }

    }

$disp = new disponiblidade(3, 3, 'clinic522');

