<!--#include file="connect.asp"-->

<div class="container s2-docs-container">
    <div class="row">
        <div class="col-md-9" role="main">

            

            <section>


                <p>
                    <select id="PacienteID" class="form-control">
                        <option value="3620194" selected="selected">Silvio Maia da Silva</option>
                    </select>
                </p>
            </section>

        </div>
    </div>
</div>
<br /><br /><br /><br /><br /><br /><br /><br />







<%=selectInsert("Locais", "Locais", 3, "Locais", "NomeLocal", "", "", "")%>


<br /><br /><br /><br /><br /><br /><br /><br />




<%=selectInsert2("Profissional", "ProfissionalID", 3, "profissionais", "NomeProfissional", "", "", "")%>



<script type="text/javascript">
    $.fn.select2.amd.require([
      "select2/core",
      "select2/utils",
      "select2/compat/matcher"
    ], function (Select2, Utils, oldMatcher) {
        var $ajax = $("#PacienteID");
//        $.fn.select2.defaults.set("width", "100%");
        function formatRepo(repo) {
            if (repo.loading) return repo.text;

            var markup = "<div class='select2-result-repository clearfix'>" +
              "<div class='select2-result-repository__meta'>" +
                "<div class='select2-result-repository__title'>" + repo.full_name + "</div>";
            "</div></div>";
            return markup;
        }
        function formatRepoSelection(repo) {
            return repo.full_name || repo.text;
        }
        $ajax.select2({
            ajax: {
                url: "resposta.asp",
                dataType: 'json',
                delay: 250,
                data: function (params) {
                    return {
                        q: params.term, // search term
                        page: params.page
                    };
                },
                processResults: function (data, params) {
                    params.page = params.page || 1;
                    return {
                        results: data.items,
                        pagination: {
                            more: (params.page * 30) < data.total_count
                        }
                    };
                },
                cache: true
            },
            escapeMarkup: function (markup) { return markup; },
            minimumInputLength: 0,
            templateResult: formatRepo,
            templateSelection: formatRepoSelection
        });
    });
</script>

<div class="option-group field section">
    <label class="option option-primary"><input type="checkbox" name="Encaixe" id="Encaixe" value="1"<%if Encaixe=1 then%> checked<%end if%>><span class="checkbox"></span>Encaixe</label>
</div>


                    <!-- Radios and Checkboxes -->
                    <div class="section-divider mt40 mb25" id="spy5">
                      <span>Radios and Checkboxes</span>
                    </div>
                    <!-- .section-divider -->

                    <div class="section row">
                      <div class="col-md-6 pl20 prn">
                        <div class="section mv15">
                          <div class="option-group field">
                            <label class="option">
                              <input type="checkbox" name="checked" value="checked" checked>
                              <span class="checkbox"></span>Check</label>
                            <label class="option">
                              <input type="checkbox" name="disabled" value="disabled" disabled>
                              <span class="checkbox"></span>Disable</label>
                            <label class="option">
                              <input type="checkbox" name="mobileos" value="CH">
                              <span class="checkbox"></span>Empty</label>
                          </div>
                          <!-- end .option-group section -->
                        </div>
                        <div class="section mb15">
                          <div class="option-group field">
                            <label class="option">
                              <input type="radio" name="payment" checked>
                              <span class="radio"></span>Check</label>
                            <label class="option">
                              <input type="radio" name="disabled" disabled>
                              <span class="radio"></span>Disable</label>
                            <label class="option">
                              <input type="radio" name="payment">
                              <span class="radio"></span>Empty</label>
                          </div>
                          <!-- end .option-group section -->
                        </div>
                        <!-- end section -->

                        <div class="mb15">
                          <label class="field option block">
                            <input type="checkbox" name="terms">
                            <span class="checkbox mr10"></span>Please agree to our
                            <a href="javascript:;" class="theme-link"> terms </a>
                          </label>
                        </div>
                        <div class="section">
                          <label class="field option block">
                            <input type="radio" name="terms">
                            <span class="radio mr5"></span> Please agree to our
                            <a href="javascript:;" class="theme-link"> terms </a>
                          </label>
                        </div>
                        <!-- end section -->
                      </div>




                        Copiar a pagina dos checkbox pra ca e ir dependando.