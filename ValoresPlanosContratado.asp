<!--#include file="connect.asp"-->
<!--#include file="Classes/Json.asp"-->
<%
ConvenioID = req("ConvenioID")

'recupera as regras já criadas
sqlModificadores = "SELECT * FROM conveniosmodificadores WHERE ConvenioID = "&ConvenioID
set rsModificadores = db.execute(sqlModificadores)
ModificadoresJson = recordToJSON(rsModificadores)

'recupera os calculos
sqlCalculos = "SELECT text, concat('|', text, '|') AS id FROM "&_
    "(SELECT 'UCO' text UNION ALL SELECT 'CH' UNION ALL SELECT 'R$' UNION ALL SELECT 'Filme' UNION ALL SELECT 'Porte' UNION ALL SELECT 'Materiais' UNION ALL SELECT 'Medicamentos' UNION ALL "&_
    "SELECT 'OPME' UNION ALL SELECT 'Taxas' UNION ALL SELECT 'Gases')  AS T"
set rsCalculos = db.execute(sqlCalculos)
CalculosJson = recordToJSON(rsCalculos)

'recupera contratados
sqlContratado = " SELECT CONCAT('|' ,contratosconvenio.id,'','|') AS id,CONCAT(CodigoNaOperadora,' - ',NomeContratado) as text FROM (                "&chr(13)&_
                " select 0 as id,NomeFantasia as NomeContratado from empresa                                      "&chr(13)&_
                " UNION ALL                                                                                      "&chr(13)&_
                " select id*-1,NomeFantasia from sys_financialcompanyunits where not isnull(UnitName) and sysActive=1"&chr(13)&_
                " UNION ALL                                                                                      "&chr(13)&_
                " select id, NomeProfissional from profissionais where sysActive=1) t                            "&chr(13)&_
                " JOIN contratosconvenio ON contratosconvenio.Contratado = t.id                                  "&chr(13)&_
                " WHERE ConvenioID = "&ConvenioID&"                                                              "
set rsContratados = db.execute(sqlContratado)
ContratadosJson = recordToJSON(rsContratados)

'recupera Produtos
sqlProdutos = "SELECT concat('|', id, '|') id, if(TipoProduto=3,concat('Material - ',NomeProduto),concat('Medicamento - ',NomeProduto)) text, TipoProduto FROM produtos WHERE TipoProduto IN (3, 4) ORDER BY text"
set rsProdutos = db.execute(sqlProdutos)
ProdutosJson = recordToJSON(rsProdutos)

'recupera Grupo de procedimentos
sqlGrupos = "SELECT concat('|', id, '|') id, NomeGrupo as text FROM procedimentosgrupos  WHERE sysActive = 1"
set rsGrupos = db.execute(sqlGrupos)
GruposJson = recordToJSON(rsGrupos)

'recupera os Procedimentos
sqlProcedimentos = "SELECT concat('|', id, '|') id,NomeProcedimento as text FROM procedimentos WHERE Ativo = 'on' AND sysActive = 1"
set rsProcedimentos = db.execute(sqlProcedimentos)
ProcedimentosJson = recordToJSON(rsProcedimentos)

'recupera os Planos do convenio
sqlPlanos = "SELECT concat('|', id, '|') id, NomePlano as text FROM conveniosplanos WHERE ConvenioID = "&ConvenioID
set rsPlanos = db.execute(sqlPlanos)
PlanosJson = recordToJSON(rsPlanos)

'recupera Vias
sqlVias = "select concat('|', id, '|') id, descricao as text from tissvia order by descricao"
set rsVias = db.execute(sqlVias)
ViasJson = recordToJSON(rsVias)
%>
<form id="frmOC">
    <div id="main-nofitificados">
        
        <div v-for="(regra, indexRegra) in regras" class="row"  style="margin: 15px; padding: 15px; border: #dfdfdf dashed 1px" v-if="exibe">
            <div class="col-md-12" >
                <div class="col-md-3">
                    <label>Cálculos</label>
                    <app-multiselect  :options="CalculosJson" v-model="regra.calculos" v-on:input="verificaMatMed(regra)" :key="indexRegra + 'calculo'">
                    </app-multiselect>
                </div>
                <div class="col-md-3" v-if="regra._exibeMatMed">
                <label>Tabela</label>
                <select class="form-control" v-model="regra.tabela" :key="indexRegra + 'tabela'">
                    <option value="">Selecione</option>
                    <option value="|Brasindice|">Brasindice</option>
                    <option value="|Simpro|">Simpro</option>
                </select>
                </div>

                <div class="col-md-3" v-if="regra._exibeMatMed">
                    <label>Preço</label>
                    <select class="form-control" v-model="regra.preco" :key="indexRegra + 'preco'" >
                        <option value="|PFB|">PFB</option>
                        <option value="|PMC|">PMC</option>
                    </select>
                </div>

                <div class="col-md-3" v-if="regra._exibeMatMed === 'MatEMed'">
                    <label>Materiais e Medicamentos</label>
                    <app-multiselect  :options="MateriaisEMedicamentos" v-model="regra.produtos" :key="indexRegra + 'produto-matmed'">
                    </app-multiselect>
                </div>

                <div class="col-md-3" v-if="regra._exibeMatMed === 'Mat'">
                    <label>Materiais</label>
                    <app-multiselect  :options="Materiais" v-model="regra.produtos" :key="indexRegra + 'produto-mat'">
                    </app-multiselect>
                </div>

                <div class="col-md-3" v-if="regra._exibeMatMed === 'Med'">
                    <label>Medicamentos</label>
                    <app-multiselect  :options="Medicamentos" v-model="regra.produtos"  :key="indexRegra + 'produto-med'">
                    </app-multiselect>
                </div>
                <div class="col-md-3">
                    <label>Grupos</label>
                    <app-multiselect  :options="GruposJson" v-model="regra.grupos"  :key="indexRegra + 'grupo'">
                    </app-multiselect>
                </div>
                <div class="col-md-3">
                    <label>Procedimentos</label>
                    <app-multiselect  :options="ProcedimentosJson" v-model="regra.procedimentos" :key="indexRegra + 'procedimento'" :id="indexRegra + 'procedimento'">
                    </app-multiselect>
                </div>

                <div class="col-md-3">
                    <label>Planos</label>
                    <app-multiselect  :options="PlanosJson" v-model="regra.planos" :key="indexRegra + 'planos'" :id="indexRegra + 'planos'">
                    </app-multiselect>
                </div>

                <div class="col-md-3">
                    <label>Contratados</label>
                    <app-multiselect  :options="ContratadosJson" v-model="regra.contratados" :key="indexRegra + 'contratados'">
                    </app-multiselect>
                </div>

                <div class="col-md-3">
                    <label>Vias</label>
                    <app-multiselect  :options="ViasJson" v-model="regra.vias" :key="indexRegra + 'vias'">
                    </app-multiselect>
                </div>

                <div class="col-md-3" >
                    <label>Tipo</label>
                    <select class="form-control" v-model="regra.tipo" :key="indexRegra + 'tipo'">
                        <option value="-1">Deflator (-)</option>
                        <option value="1">Inflator (+)</option>
                    </select>
                </div>

                <div class="col-md-2">
                    <label>Valor(%)</label>
                    <app-inputmoney v-model="regra.valor" class="form-control text-right" data-lpignore="true" :key="indexRegra + 'valor'" :id="indexRegra + 'valor'">
                    </app-inputmoney>
                </div>
                <div class="col-md-1">
                        <label>&nbsp;</label>
                        <br/>
                        <button type="button" class="btn btn-block btn-success" v-if="indexRegra == 0" v-on:click="addRegras"> <i class="fa fa-plus"></i></button>

                        <button type="button" class="btn btn-block btn-danger" v-if="indexRegra >= 1" v-on:click="excluirRegra(indexRegra)"> <i class="far fa-times"></i></button>
                </div>
            </div>

        </div>

    </div>

</form>

<script src="https://cdnjs.cloudflare.com/ajax/libs/vue/2.5.16/vue.min.js?_=1638792466182"></script>
<script type="text/javascript">
    const ConvenioID        = <%=ConvenioID%>;
    const CalculosJson      = <%=CalculosJson%>;
    const ContratadosJson   = <%=ContratadosJson%>;
    const ProdutosJson      = <%=ProdutosJson%>;
    const GruposJson        = <%=GruposJson%>;
    const ProcedimentosJson = <%=ProcedimentosJson%>;
    const PlanosJson        = <%=PlanosJson%>;
    const ViasJson          = <%=ViasJson%>;
    const ModificadoresJson = <%=ModificadoresJson%>;
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

    Vue.component("app-inputmoney", {
        props: ["value"],
        template: `<input type="text"/>`,
        mounted: function() {
            const vm = this;
            $(this.$el).maskMoney({prefix:'', thousands:'', decimal:',', affixesStay: true, precision: 4}).val(this.value)
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

    var app = new Vue({
        el: '#frmOC',
        data:{
            exibe                   : true,
            exibeMatMed             : false,
            regras                  : ModificadoresJson,
            ConvenioID              : ConvenioID,
            CalculosJson            : CalculosJson,
            ContratadosJson         : ContratadosJson,
            MateriaisEMedicamentos  : ProdutosJson,
            Materiais               : ProdutosJson.filter(p => p.TipoProduto == 3),
            Medicamentos            : ProdutosJson.filter(p => p.TipoProduto == 4),
            GruposJson              : GruposJson,
            ProcedimentosJson       : ProcedimentosJson,
            PlanosJson              : PlanosJson,
            ViasJson                : ViasJson
        },
        created: function() {
            if (this.regras.length == 0) {
                this.regras.push({});
            }
            this.regras.map(this.verificaMatMed);

            $('#save').replaceWith($('#save').clone());
            $("#save").on('click',() => this.save());

        },
        methods: {
            save: function() {
                fetch(domain+'api/convenios-modificadores/save',{
                    method:"POST",
                    headers: {
                            "x-access-token":localStorage.getItem("tk"),
                            'Accept': 'application/json',
                            'Content-Type': 'application/json'
                    },
                    body:JSON.stringify({parametros:this.regras,convenio:<%=ConvenioID%>})
                }).then(data => data.json()).then( jsonData => {
                    const result = jsonData;
                    
                    if(result.status === "error"){
                        new PNotify({
                            title: 'Atenção!',
                            text: result.msg,
                            type: 'warning',
                            delay: 2500
                        }); 
                    }else if(result.status === "success") {
                        new PNotify({
                            title: 'Sucesso!',
                            text: 'Dados cadastrados com sucesso.',
                            type: 'success',
                            delay: 2500
                        });
                    }
                });
            },
            addRegras: function(){
                this.regras.push({});
            },
            excluirRegra: function(index) {
                this.exibe = false;
                this.regras.splice(index, 1);
                this.$nextTick(() => {
                    this.exibe = true;
                });
            },
            verificaMatMed: function(regra) {
                if (regra.calculos && regra.calculos.includes('Medicamentos') && regra.calculos.includes('Materiais'))  {
                    regra._exibeMatMed = 'MatEMed';
                } else if (regra.calculos && regra.calculos.includes('Medicamentos')) {
                    regra._exibeMatMed = 'Med';
                    if (regra.produtos) {
                        regra.produtos = regra.produtos.split(',').filter(p => this.Medicamentos.find(m => m.id == p)).join(',');
                    }
                } else if (regra.calculos && regra.calculos.includes('Materiais')) {
                    regra._exibeMatMed = 'Mat';
                    if (regra.produtos) {
                        regra.produtos = regra.produtos.split(',').filter(p => this.Materiais.find(m => m.id == p)).join(',');
                    }
                } else {
                    regra._exibeMatMed = null;
                    regra.produtos = null;
                }
            },
        }

    })
</script>
