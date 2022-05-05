<!--#include file="connect.asp"-->
<!--#include file="Classes/Json.asp"-->
<%
id = req("I")

'recupera os dados do protocolo
sqlProtocolo = "SELECT p.id FROM protocolos p WHERE p.id = '" & id & "'"
set rsProtocolo = db.execute(sqlProtocolo)
if rsProtocolo.eof then
    response.write("Protocolo não encontrado")
    response.status = 422
    response.end
end if

'recupera os convenios deste protocolo
sqlConvenios = "SELECT pc.ConvenioID, pc.PlanoID, NomeConvenio, NomePlano FROM protocolos_convenios pc " &_
               "LEFT JOIN convenios ON convenios.id = pc.ConvenioID " &_
               "LEFT JOIN conveniosplanos ON conveniosplanos.id = pc.PlanoID " &_
               "WHERE pc.ProtocoloID = '" & id & "'"
set rsConvenios = db.execute(sqlConvenios)
conveniosJson = recordToJSON(rsConvenios)

'recupera as regras existentes deste protocolo
sqlRegras = "SELECT r.*, p.NomePaciente AS _NomePaciente FROM protocolos_regras r " &_
            "LEFT JOIN pacientes p ON r.campo = 'Paciente' AND p.id = r.Valor " &_
            "WHERE r.ProtocoloID = '" & id & "' AND r.sysActive = 1 ORDER BY r.id"
set rsRegras = db.execute(sqlRegras)
regrasJson = recordToJSON(rsRegras)


'recupera os formulários customizados
sqlWhereTiposCampos = "1,2,4,5,6,8,16"

sqlForms = "SELECT f.id, f.Nome FROM buiforms AS f INNER JOIN buicamposforms AS c ON c.FormID = f.id " &_
           "WHERE f.sysActive = 1 AND c.TipoCampoID IN (" & sqlWhereTiposCampos & ") " &_
           "AND (c.NomeCampo != '' OR c.RotuloCampo != '') " &_
           "GROUP BY f.id ORDER BY f.Nome "
set rsForms = db.execute(sqlForms)

camposFormJson = "{"
while not rsForms.eof

    'recupera os campos do formulário
    sqlCamposForm = "SELECT c.id, c.NomeCampo, c.RotuloCampo, c.TipoCampoID FROM buicamposforms c " &_
                    "WHERE c.FormID = '" & rsForms("id") & "' AND c.TipoCampoID IN (" & sqlWhereTiposCampos & ") " &_
                    "AND (c.NomeCampo != '' OR c.RotuloCampo != '') "
    set rsCamposForm = db.execute(sqlCamposForm)

    camposJson = "["
    while not rsCamposForm.eof

        fieldJson = fieldToJSON(rsCamposForm.Fields)
        fieldJson = Left(fieldJson, Len(fieldJson) - 1)

        ' se for checkbox, seleção ou radio, recupera as opções do campo
        if rsCamposForm("TipoCampoID") = 4 or rsCamposForm("TipoCampoID") = 5 or rsCamposForm("TipoCampoID") = 6 then
            sqlOpcoesCampo    = "SELECT id, Nome FROM buiopcoescampos bo WHERE bo.CampoID = '" & rsCamposForm("id") & "'"
            set rsOpcoesCampo = db.execute(sqlOpcoesCampo)

            opcoesCampo = recordToJson(rsOpcoesCampo)

            fieldJson = fieldJson & ", ""Opcoes"": " & opcoesCampo & "}"
        else
            fieldJson = fieldJson & ", ""Opcoes"": []}"
        end if

        if camposJson <> "[" then
            camposJson = camposJson & ", "
        end if

        camposJson = camposJson & fieldJson

        rsCamposForm.movenext
    wend
    
    camposJson = camposJson & "]"

    if camposFormJson <> "{" then
        camposFormJson = camposFormJson & ", "
    end if

    camposFormJson = camposFormJson & """" & rsForms("id") & """: " & camposJson

    rsForms.movenext
wend
camposFormJson = camposFormJson & "}"

%>

<style>
    #app-regras .modal-body {
        max-height: 70vh;
        overflow-x: hidden;
        overflow-y: auto;
    }

    #app-regras .select[tabindex="-1"], #app-regras .input-hidden {
        display: block !important;
        position: absolute;
        opacity: 0;
        z-index: 0 !important;
        margin: 0;
        width: 1em;
        height: 1em;
    }
    #app-regras .bloco-campos-form {
        padding: 10px 0;
    }
    #app-regras .bloco-campos-form > i {
        float: left;
        width: 7%;
        padding-top: 13px;
    }
    #app-regras .bloco-campos-form > div {
        float: left;
        width: 93%;
    }

    #app-regras #table-regras thead th:nth-child(2), #app-regras #table-regras thead th:nth-child(3),
      #app-regras #table-regras thead th:nth-child(4) {
        width: 40px;
    }

    #app-regras #table-regras td:last-child, #app-regras #table-regras th:last-child {
        width: 50px;
        min-width: 50px;
    }

    #app-regras #table-regras tbody td:nth-child(1), #app-regras #table-regras tbody td:nth-child(2),
      #app-regras #table-regras tbody td:nth-child(3){
        width: 30%;
        max-width: 280px;
    }

    #app-regras .btn-convenio {
        margin-top: 30px;
    }
</style>

<script src="assets/js/vue-2.5.17.min.js"></script>

<script>
    const protocoloId   = <%=id%>;
    const conveniosJson = <%=conveniosJson%>;
    const regrasJson    = <%=regrasJson%>;
    const camposForm    = <%=camposFormJson%>;

    // agrupa os registros das regras
    let regras = {};
    regrasJson.map(item => {
        if (!regras[item.Regra]) {
            regras[item.Regra] = [];
        }
        regras[item.Regra].push(item);
    });
    regras = Object.values(regras);

    let convenios = [];
    if (conveniosJson.length > 0) {
        conveniosJson.map(conv => {
            convenios.push({ConvenioID: conv.ConvenioID, PlanoID: conv.PlanoID});
        });
    } else {
        convenios = [{ConvenioID: null, PlanoID: null}];
    }

    Vue.component("app-select2", {
        props: ["value", "options"],
        template: "<select><slot></slot></select>",
        mounted: function() {
            const vm = this;
            $(this.$el).select2(this.options ? {data: this.options} : undefined).val(this.value).trigger("change")
                .on("change", function() {
                    if (vm.value !== this.value) {
                        vm.$emit("input", this.value);
                    }
            });
        },
        watch: {
            value: function(value) {
                if ($(this.$el).val() !== value) {
                    $(this.$el).val(value).trigger('change');
                }
            },

            options: function(options) {
                $(this.$el).empty().select2({ data: options });
            }
        },
        destroyed: function() {
            $(this.$el).off().select2("destroy");
        }
    });

    Vue.component("app-inputmoney", {
        props: ["value"],
        template: `<input type="text"/>`,
        mounted: function() {
            const vm = this;
            $(this.$el).maskMoney({prefix:'', thousands:'', decimal:',', affixesStay: true}).val(this.value)
            .trigger("change").on("change", function() {
                if (vm.value !== this.value) {
                    vm.$emit("input", this.value);
                }
            });
        },
        watch: {
            value: function(value) {
                if ($(this.$el).val() !== value) {
                    $(this.$el).val(value).trigger("change");
                }
            }
        },
        destroyed: function() {
            $(this.$el).off().maskMoney("destroy");
        }
    });

    Vue.component("app-s2aj", {
        props: ["recurso", "coluna", "camposuperior", "placeholder", "value"],
        template: `<select><slot></slot></select>`,
        mounted: function() {
            const vm = this;
            $(this.$el).val(this.value).trigger("change").on("change", function() {
                if (vm.value !== this.value) {
                    vm.$emit("input", this.value);
                }
            });
            s2aj(this.$el.id, this.recurso, this.coluna, this.camposuperior, this.placeholder);
        },
        watch: {
            value: function(value) {
                if ($(this.$el).val() !== value) {
                    $(this.$el).val(value).trigger("change");
                }
            }
        },
        destroyed: function() {
            $(this.$el).off().select2("destroy");
        }
    });

    Vue.component("app-multiplemodal", {
        props: ["name", "modaltitle", "value", "buttonLabel", "required"],
        template: `<div>
                        <input tabindex="-1" class="input-hidden" :id="name" :value="value" :required="required" />
                        <button type="button" class="btn btn-default btn-block">
                            <i class="far fa-plus"></i> {{buttonLabel}} <span></span>
                        </button>
                    </div>`,
        computed: {
            buttonLabel: function() {
                const arrVal = this.value ? this.value.split(',') : [];
                return (arrVal.length > 0) ? (arrVal.length + ' selecionado(s)') : 'Selecione';
            }
        },
        mounted: function() {
            const vm = this;

            $(this.$el).find('input').val(this.value).trigger("change").on("change", function() {
                if (vm.value !== this.value) {
                    vm.value = this.value; //importante
                    vm.$emit("input", this.value);
                }
            });

            $(this.$el).find('button').on('click', function() {
                openComponentsModalPost(`quickField_multipleModal.asp?I=${vm.name}`, {v: vm.value},
                    `Selecionar ${vm.modaltitle}`, true, function(){
                    closeComponentsModal(true)
                });
            });
        },
        watch: {
            value: function(value) {
                if ($(this.$el).find('input').val() !== value) {
                    $(this.$el).find('input').val(value).trigger("change");
                }
            }
        },
        destroyed: function() {
            $(this.$el).find('input, button').off();
        }
    });

    Vue.component("app-multiselect", {
            props: ["value", "options"],
            template: `<select multiple class="input-hidden">
                            <option v-for="option in options" :value="option.id">{{option.text}}</option>
                       </select>`,
            mounted: function() {
                const vm = this;
                const config = {
                    includeSelectAllOption: true,
                    enableFiltering: true,
                    numberDisplayed: 1,
                };
                const val = this.value ? this.value.split(',') : [];

                $(this.$el).val(val).multiselect(config).trigger("change")
                    .on("change", function() {
                        const val = $(vm.$el).val() ? $(vm.$el).val().join(',') : null;
                        if (vm.value !== val) {
                            vm.$emit("input", val);
                        }
                });
            },
            watch: {
                value: function(value) {
                    const currentVal = $(this.$el).val() ? $(this.$el).val().join(',') : null;
                    if (currentVal !== value) {
                        $(this.$el).val(currentVal.split(',')).trigger('change');
                    }
                },
            },
            destroyed: function() {
                $(this.$el).off().multiselect("destroy");
            }
        });

    var app = new Vue({
    el: '#app-regras',
    data: {
        convenios: convenios,
        regras: regras,
        camposForm: camposForm
    },
    created: function() {
        const vm = this;
        vm.regras.map(function(regra) {
            regra.map(function(condicao) {
                vm._setTipoCampo(condicao, true);
            });
        });
    },
    methods: {

        _setTipoCampo: function(condicao, initial) {

                const isChange = initial !== true;

                // campos do paciente
                switch (condicao.Campo) {
                    case 'Sexo':
                        condicao._TipoCampo    = 'sexo';
                        condicao._TipoOperador = 'select';
                        if (isChange) {
                            condicao.Operador = '=';
                        }
                        break;

                    case 'Altura':
                    case 'Peso':
                        condicao._TipoCampo    = 'money';
                        condicao._TipoOperador = 'number';
                        if (initial) {
                            condicao.Valor = parseFloat(condicao.Valor).toFixed(2).replace(',', '').replace('.', ',');
                        } else {
                            condicao.Operador = '=';
                        }
                        break;

                    case 'Idade':
                        condicao._TipoCampo    = 'number';
                        condicao._TipoOperador = 'number';
                        if (isChange) {
                            condicao.Operador = '=';
                        }
                        break;

                    case 'Paciente':
                        condicao._TipoCampo    = 'paciente';
                        condicao._TipoOperador = 'select';
                        if (isChange) {
                            condicao.Operador = '=';
                        }
                        break;

                    case 'Prognóstico':
                        condicao._TipoCampo    = 'prognostico';
                        condicao._TipoOperador = 'select';
                        if (isChange) {
                            condicao.Operador = '=';
                        }
                        break;

                    case 'CID-10':
                        condicao._TipoCampo    = 'cid-10';
                        condicao._TipoOperador = 'multiselect';
                        if (isChange) {
                            condicao.Operador = 'IN';
                        }
                        break;
                }

                //campos de formulário
                if (condicao.FormID) {
                    if (isChange) {
                        condicao._TipoCampo    = null;
                        condicao._TipoOperador = null;
                        condicao.Operador      = null;
                    }

                    const camposForm = this.camposForm[condicao.FormID];
                    let campoForm;
                    if (camposForm && camposForm.length) {
                        campoForm  = camposForm.find(c => c.id === condicao.FormCampoID);
                    } else {
                        campoForm = undefined;
                    }

                    if (campoForm) {

                        const opcoes = [];
                        campoForm.Opcoes.map(opcao => {
                            opcoes.push({id: opcao.id, text: opcao.Nome})
                        });
                        condicao._Options = opcoes;

                        switch (parseInt(campoForm.TipoCampoID, 10)) {
                            case 1: //texto - frase
                            case 8: //texto - memo
                                condicao._TipoCampo    = 'text';
                                condicao._TipoOperador = 'text';
                                if (isChange) {
                                    condicao.Operador = '=';
                                }
                                break;
                            case 2: //data
                                condicao._TipoCampo    = 'date';
                                condicao._TipoOperador = 'number';
                                if (isChange) {
                                    condicao.Operador = '=';
                                }
                                break;
                            case 4: //checkbox
                                condicao._TipoCampo        = 'multiselect';
                                condicao._TipoOperador     = 'multiselect';
                                if (isChange) {
                                    condicao.Operador = 'IN';
                                }
                                break;
                            case 5: //radio
                            case 6: //seleção
                                condicao._TipoCampo    = 'select';
                                condicao._TipoOperador = 'select';
                                if (isChange) {
                                    condicao.Operador = '=';
                                }
                                break;
                            case 16: //diagnóstico cid-10
                                condicao._TipoCampo    = 'cid-10';
                                condicao._TipoOperador = 'multiselect';
                                if (isChange) {
                                    condicao.Operador = 'IN';
                                }
                                break;
                            case 17: //texto - memo CID BMJ
                            condicao._TipoCampo    = 'text';
                            condicao._TipoOperador = 'text';
                            if (isChange) {
                                condicao.Operador = '=';
                            }
                            break;
                        }
                    }
                }
        },

        inserirRegra: function() {
            this.regras.push([{}]);
        },

        excluirRegra: function(index) {
            this.regras.splice(index, 1);
        },

        copiarRegra: function(regra) {
            const novaRegra = [];
            regra.map(condicao => {
                novaRegra.push({...condicao, ...{id: null}})
            });
            this.regras.push(novaRegra);
        },

        inserirCondicao: function(regra) {
            regra.push({});
        },

        excluirCondicao: function(regra, index) {
            regra.splice(index, 1);
        },

        onChangeCampo: function(condicao) {
            condicao.Valor = null;

            if (condicao.Campo.startsWith('form-')) {
                condicao.FormID      = condicao.Campo.split('-', 2)[1];
                condicao.FormCampoID = null;
            } else {
                condicao.FormID      = null;
                condicao.FormCampoID = null;
            }

            this._setTipoCampo(condicao);

            this.$forceUpdate();
        },

        onChangeFormCampo: function (condicao) {
            condicao.Valor = null;
            this._setTipoCampo(condicao);
            this.$forceUpdate();
        },

        onChangeConvenio: function(index) {
            this.convenios[index].PlanoID = '';
        },

        excluirConvenio: function (index) {
            if (this.convenios.length > 1) {
                this.convenios.splice(index, 1);
            } else {
                this.convenios = [{ConvenioID: null, PlanoID: null}];
            }
        },

        addConvenio: function() {
            this.convenios.push({ConvenioID: null, PlanoID: null});
        },

        save: function(event) {
            event.preventDefault();

            const conveniosFiltered = this.convenios.filter(c => c.ConvenioID);

            const regrasPlain    = JSON.parse(JSON.stringify(this.regras));
            const conveniosPlain = JSON.parse(JSON.stringify(conveniosFiltered));
            const formData       = new URLSearchParams();

            regrasPlain.map((regra, index) => {
                regra.map(condicao => {

                    condicao.Regra = index + 1;

                    // trata as condições que não tem id
                    if (!Object.hasOwnProperty('id')) {
                        condicao.id = null;
                    }

                    // se o tipo do campo for numérico, converte para float
                    if (condicao._TipoCampo === 'number' || condicao._TipoCampo === 'money') {
                        condicao.Valor = parseFloat(condicao.Valor.replace('.', '').replace(',', '.'));
                    }

                    // adiciona as propriedades do objeto no formData
                    Object.keys(condicao).forEach(key => {
                        if (!key.startsWith('_') && !key.startsWith('sys')) { //remove as propriedades privadas
                            let val = condicao[key];
                            if (typeof val === 'undefined' || val === null) { //trava vazios
                                val = '';
                            }
                            formData.append(key, val);
                        }
                    });
                });
            });

            conveniosPlain.map(conv => {
                Object.keys(conv).forEach(key => {
                    let val = conv[key];
                    if (typeof val === 'undefined' || val === null) { //trava vazios
                        val = '';
                    }
                    formData.append(key, val);
                });
            });

            $.ajax('saveProtocoloRegras.asp?ProtocoloID=' + protocoloId, {
                method: 'POST',
                data: formData,
                processData: false
            }).success(() => {
                new PNotify({
                    title: 'Sucesso!',
                    text: 'Regras gravadas com sucesso!',
                    type: 'success',
                    delay:1000
                });
                $("#modal-table").modal("hide");
            }).fail(() => {
                alert('Não foi possível salvar.');
            });
        }
    }
    });
</script>

<form id="app-regras" v-on:submit="save">

    <div class="modal-header ">
        <button type="button" class="close" data-dismiss="modal">&times;</button>
        <h3 class="modal-title"><i class="far fa-lock"></i>  Regra de Sugestão do Protocolo</h3>
    </div>

    <div class="modal-body">
        <div class="row">
            <div class="col-md-12 mt30 ml5">
                <p>
                    <i><b>Atenção:</b> Na seção dados demográficos a sugestão aparecerá apenas se na ficha do paciente a informação
                    coincidir com a aqui marcada. <br />
                    Já em dados clínicos estão listados todos os campos distintos dos formulários criados em seu sistema,
                    e só será validade os campos presentes na ficha do paciente.</i>
                </p>
            </div>
        </div>
        <div class="row">
            <div class="col-md-12">
                <h4>Regra de Sugestão do Convênio</h4>
            </div>
        </div>
        <div class="row" v-for="(convenio, index) in convenios">
            <div class="col-md-4">
                <label>Convênio</label>
                <app-s2aj :id="'input-convenio-'+index" class="form-control" v-model="convenio.ConvenioID" recurso="convenios" coluna="NomeConvenio" v-on:input="onChangeConvenio(index)">
                    <%
                        if not rsConvenios.bof then
                            rsConvenios.movefirst
                        end if
                        while not rsConvenios.eof
                    %>
                        <option value="<%=rsConvenios("ConvenioID")%>"><%=rsConvenios("NomeConvenio")%></option>
                    <%
                            rsConvenios.movenext
                        wend
                    %>
                </app-s2aj>
            </div>
            <div class="col-md-3">
                <label>Plano</label>
                <app-s2aj :id="'input-plano-'+index" class="form-control" v-model="convenio.PlanoID" recurso="conveniosplanos" coluna="NomePlano" :camposuperior="'input-convenio-'+index">
                    <%
                        if not rsConvenios.bof then
                            rsConvenios.movefirst
                        end if
                        while not rsConvenios.eof
                    %>
                        <option value="<%=rsConvenios("PlanoID")%>"><%=rsConvenios("NomePlano")%></option>
                    <%
                            rsConvenios.movenext
                        wend
                    %>
                </app-s2aj>
            </div>
            <div class="col-md-2">
                <button type="button" class="btn btn-xs btn-convenio btn-danger" v-on:click="excluirConvenio(index)" title="Excluir regra de Convênio">
                    <i class="far fa-trash"></i>
                </button>
                <button type="button" class="btn btn-xs btn-convenio btn-success" v-on:click="addConvenio" title="Adicionar regra de Convênio">
                    <i class="far fa-plus"></i>
                </button>
            </div>
        </div>
        <div class="row">
            <p class="text-right">
                <button type="button" class="btn btn-sm btn-primary" v-on:click="inserirRegra">
                    <i class="far fa-plus"></i> Adicionar nova regra
                </button>
            </p>
        </div>
        <div class="row">
            <div class="col-md-12">

                <table id="table-regras" class="table table-striped mt20" v-for="(regra, index) in regras">
                    <thead>
                        <tr class="success">
                            <th colspan="3">REGRA {{index+1}}</th>
                            <th class="text-center">
                                <button type="button" class="btn btn-sm btn-alert" v-on:click="copiarRegra(regra)" title="Copiar Regra">
                                    <i class="far fa-copy"></i>
                                </button>
                            </th>
                            <th class="text-center">
                                <button type="button" class="btn btn-sm btn-success" v-on:click="inserirCondicao(regra)" title="Inserir Condição">
                                    <i class="far fa-plus"></i>
                                </button>
                            </th>
                            <th class="text-center">
                                <button type="button" class="btn btn-sm btn-dark" v-on:click="excluirRegra(index)" title="Excluir Regra">
                                    <i class="far fa-close"></i>
                                </button>
                            </th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr v-for="(condicao, index2) in regra">
                            <td>
                                <app-select2 v-model="condicao.Campo" v-on:input="onChangeCampo(condicao)" required>
                                    <optgroup label="Dados do paciente">
                                        <option value="Sexo">Sexo</option>
                                        <option value="Altura">Altura</option>
                                        <option value="Peso">Peso</option>
                                        <option value="Idade">Idade</option>
                                        <option value="CID-10">CID-10</option>
                                        <option value="Prognóstico">Prognóstico (Estadiamento)</option>
                                        <option value="Paciente">Paciente</option>
                                    </optgroup>
                                    <% if not rsForms.bof or not rsForms.eof then %>
                                    <optgroup label="Campo do formulário">
                                    <%
                                        end if
                                        if not rsForms.bof then
                                            rsForms.movefirst
                                        end if
                                        while not rsForms.eof
                                    %>
                                        <option value="form-<%=rsForms("id")%>"><%=rsForms("Nome")%></option>
                                    <%
                                            rsForms.movenext
                                        wend
                                    %>
                                    </optgroup>
                                </app-select2>

                                <div class="bloco-campos-form" v-if="condicao.FormID && camposForm[condicao.FormID]">
                                    <i class="far fa-chevron-right"></i>
                                    <div>
                                        <app-select2 v-model="condicao.FormCampoID" :key="index2 + condicao.FormID + 'campos'"
                                            v-on:input="onChangeFormCampo(condicao)" required>
                                            <option v-for="campo in camposForm[condicao.FormID]"
                                                :value="campo.id">{{campo.RotuloCampo ? campo.RotuloCampo : campo.NomeCampo}}
                                            </option>
                                        </app-select2>
                                    </div>
                                </div>
                            </td>
                            <td>
                                <select class="form-control" v-model="condicao.Operador" v-if="condicao._TipoOperador === 'number'" required>
                                    <option value="=">Igual a</option>
                                    <option value="!=">Diferente de</option>
                                    <option value=">">Maior que </option>
                                    <option value=">=">Maior ou igual a</option>
                                    <option value="<">Menor que</option>
                                    <option value="<=">Menor ou igual a</option>
                                </select>

                                <select class="form-control" v-model="condicao.Operador" v-if="condicao._TipoOperador === 'select'" required>
                                    <option value="=">Igual a</option>
                                    <option value="!=">Diferente de</option>
                                </select>

                                <select class="form-control" v-model="condicao.Operador" v-if="condicao._TipoOperador === 'multiselect'" required>
                                    <option value="IN">Pertence a lista</option>
                                    <option value="NOT IN">Não pertence a lista</option>
                                </select>

                                <select class="form-control" v-model="condicao.Operador" v-if="condicao._TipoOperador === 'text'" required>
                                    <option value="=">Igual a</option>
                                    <option value="!=">Diferente de</option>
                                    <option value="LIKE">Contém</option>
                                    <option value="NOT LIKE">Não Contém</option>
                                </select>
                            </td>
                            <td>

                                <app-select2 :id="'condicao-sexo-'+index+'-'+index2" v-if="condicao._TipoCampo === 'sexo'"
                                    v-model="condicao.Valor" required>
                                    <%
                                    set resSexo = db.execute("select id, NomeSexo from sexo where sysActive=1 order by NomeSexo")
                                    while not resSexo.eof
                                    %>
                                    <option value="<%=resSexo("id")%>"><%=resSexo("NomeSexo")%></option>
                                    <%
                                    resSexo.movenext
                                    wend
                                    %>
                                </app-select2>

                                <app-inputmoney :id="'condicao-money-'+index+'-'+index2" v-if="condicao._TipoCampo === 'money'"
                                    v-model="condicao.Valor" class="form-control text-right" data-lpignore="true" required>
                                </app-inputmoney>

                                <input :id="'condicao-number-'+index+'-'+index2" type="number" class="form-control text-right"
                                    v-if="condicao._TipoCampo === 'number'" v-model="condicao.Valor" min="1" required/>

                                <input :id="'condicao-text-'+index+'-'+index2" type="text" class="form-control"
                                    v-if="condicao._TipoCampo === 'text'" v-model="condicao.Valor" required/>

                                <input :id="'condicao-date-'+index+'-'+index2" type="date" class="form-control"
                                    v-if="condicao._TipoCampo === 'date'" v-model="condicao.Valor" required/>

                                <select :id="'condicao-prognostico-'+index+'-'+index2" v-if="condicao._TipoCampo === 'prognostico'"
                                    v-model="condicao.Valor" class="form-control" required>
                                    <option value="0">0</option>
                                    <option value="I">I</option>
                                    <option value="II">II</option>
                                    <option value="III">III</option>
                                    <option value="IV">IV</option>
                                </select>

                                <app-s2aj :id="'condicao-pacientes-'+index+'-'+index2" v-if="condicao._TipoCampo === 'paciente'"
                                    class="form-control" recurso="pacientes" coluna="NomePaciente" v-model="condicao.Valor" required>
                                    <option :value="condicao.Valor" v-if="condicao._NomePaciente">{{condicao._NomePaciente}}</option>
                                </app-s2aj>

                                <app-multiplemodal :id="'condicao-cid10-'+index+'-'+index2" v-if="condicao._TipoCampo === 'cid-10'"
                                    :name="'Cid10_'+index+'-'+index2" modaltitle="CID-10" v-model="condicao.Valor" required>
                                </app-multiplemodal>

                                <app-select2 :id="'condicao-select-'+index+'-'+index2" v-if="condicao._TipoCampo === 'select'"
                                    :options="condicao._Options" v-model="condicao.Valor" required>
                                </app-select2>

                                <app-multiselect :id="'condicao-multiselect-'+index+'-'+index2" v-if="condicao._TipoCampo === 'multiselect'"
                                    :options="condicao._Options" v-model="condicao.Valor" required>
                                </app-multiselect>

                            </td>
                            <td>&nbsp;</td>
                            <td class="text-center"><code v-if="index2 < regra.length - 1">e</code></td>
                            <td class="text-center">
                                <button type="button" class="btn btn-sm btn-danger" v-if="regra.length > 1"
                                    v-on:click="excluirCondicao(regra, index2)" title="Excluir Condição">
                                    <i class="far fa-minus"></i>
                                </button>
                            </td>
                        </tr>
                    </tbody>
                    <tfoot v-if="index < regras.length - 1">
                        <tr>
                            <td colspan="6" class="text-center">OU</td>
                        </tr>
                    </tfoot>
                </table>

                <p v-if="regras.length == 0" class="text-center">Nenhuma regra cadastrada para este protocolo.</p>

            </div>

        </div>
    </div>

    <div class="modal-footer no-margin-top">
        <button type="submit" class="btn btn-sm btn-primary pull-right"><i class="far fa-save"></i> Salvar</button>
    </div>
</form>
