var url = "http://bp.dev/api/recherche";

$("#rechercheBtn").click(function(e){
    $("#rechecherResults > tbody").empty();
    $("#error").addClass("invisible");
    $("#loader").removeClass("invisible");
    e.preventDefault();
    var pop = $("#popularite").val();
    var per = $("#perennite").val();

    if(!per)
        var opPer = "N";
    else
        var opPer = $("input[name=perRadio]:checked").val();

    if(!pop)
        var opPop = "N";
    else
        var opPop = $("input[name=popRadio]:checked").val();

    var titre = $("#titre").val();


    var acteurs = $("#selectActeurs").val();
    var acteursString = "";
    $.each(acteurs, function(index, acteur){
        acteursString += acteur+"#";
    });
    acteursString = acteursString.slice(0, -1);

    var genres = $("#selectGenres").val();
    var genresString = "";
    $.each(genres, function(index, ge){
        genresString += ge+"#";
    });
    genresString = genresString.slice(0, -1);


    var data = "opPer="+opPer+"&per="+per+"&opPop="+opPop+"&pop="+pop+"&title="+titre+"&acteurs="+acteursString+"&genres="+genresString;

    console.log(acteursString);
    console.log(genresString);
    $("#time").html("");

    console.log(pop, per, opPer, opPop);
    JSend({
        url: url,
        data:data,
        type: "POST",
        success: function (data, xhr) {
            $("#loader").addClass("invisible");
            if(data.length == 0)
            {
                $("#error #message").html("Aucun film trouvé");
                $("#error").removeClass("invisible");
                return ;
            }
            $.each(data,function (index, value) {
                $('#tb').append('<tr><td><img height="80" src="http://bp.dev/api/poster/'+value.id+'" alt="'+value.titre+'\' poster" /></td><td>'+value.titre+'</td><td>'+value.popularite+'</td><td>'+value.perennite+'</td><td><a href="film/'+value.id+'" class="btn btn-primary">Afficher le film</a></td></tr>');
            });
            $("#time").html(this.elapsedTime);

        },
        error: function(data, xhr){

            $("#error #message").html(data);
            $("#error").removeClass("invisible");
            $("#loader").addClass("invisible");
            $("#time").html(this.elapsedTime);

        }

    });
});
$("#popularite").on("keyup", function(){
   if($(this).val())
   {
       $("input[name=popRadio]").removeClass("disable");
   }
   else
   {
       $("input[name=popRadio]").addClass("disable");

   }
});