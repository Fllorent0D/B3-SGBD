<?php use Swith\Form; ?>
<h2>Rechercher un acteur</h2>
<?= Form::start("index", "POST", [
    "manageErrors" => false,
    "defaultInput" => [
        "class" => 'form-control',
        "noError" => true,
    ],
    "defaultLabel" => [
        "class" => 'form-group',
        "noError" => true,
        "errorFormat" => "%MSG%",
    ],
])
    ->start_fieldset(["class" => "form-group col-md-6"])
    ->text("idacteur", "")
    ->close_fieldset()
    ->end("Afficher", ["class" => "btn btn-info"]);
?>


</form>