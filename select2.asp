<script type="text/javascript" src="js/prettify.min.js"></script>
<script type="text/javascript" src="js/anchor.min.js"></script>





<script type="text/javascript" src="js/placeholders.jquery.min.js"></script>
<script type="text/javascript" src="js/i18n/es.js"></script>

<div class="container s2-docs-container">
    <div class="row">
        <div class="col-md-9" role="main">

            

            <section>


                <p>
                    <select id="PacienteID" class="select2-ajax form-control">
                        <option value="3620194" selected="selected">Silvio Maia da Silva</option>
                    </select>
                </p>
            </section>

        </div>
    </div>
</div>



<script type="text/javascript">


    $.fn.select2.amd.require([
      "select2/core",
      "select2/utils",
      "select2/compat/matcher"
    ], function (Select2, Utils, oldMatcher) {
        var $ajax = $("#PacienteID");
        $ajax.css("display", "none");

        $.fn.select2.defaults.set("width", "100%");


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
                    // parse the results into the format expected by Select2
                    // since we are using custom formatting functions we do not need to
                    // alter the remote JSON data, except to indicate that infinite
                    // scrolling can be used
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


    //teste
</script>
