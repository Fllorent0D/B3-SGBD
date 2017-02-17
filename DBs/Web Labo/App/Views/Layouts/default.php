<?php use Core\Helpers\Html; ?>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0-alpha.5/css/bootstrap.min.css" integrity="sha384-AysaV+vQoT3kOAXZkl02PThvDr8HYKPZhNT5h/CXfBThSRXQ6jW5DO2ekP5ViFdi" crossorigin="anonymous">
    <link rel="stylesheet" href="https://opensource.keycdn.com/fontawesome/4.7.0/font-awesome.min.css" integrity="sha384-dNpIIXE8U05kAbPhy3G1cz+yZmTzA6CY8Vg/u2L9xRnHjJiAK76m2BIEaSEV+/aU" crossorigin="anonymous">
    <?= Html::css("album"); ?>
    <title><?= isset($title_for_layout) ? $title_for_layout : ''; ?></title>

</head>

<body style="padding-top: 80px">

<nav class="navbar navbar-fixed-top navbar-dark bg-inverse">
    <a class="navbar-brand" href="#">#RQS</a>
    <ul class="nav navbar-nav">

        <li class="nav-item active">
            <?= Html::link(['recherches', 'index'], 'Home', [], ['class' => 'nav-link']) ?>
        </li>
        <li class="nav-item">
            <?= Html::link(['acteurs', 'index'], 'Affiche', [], ['class' => 'nav-link']) ?>
        </li>
        <li class="nav-item">
            <?= Html::link(['recherches', 'recherche'], 'Rechercher', [], ['class' => 'nav-link']) ?>
        </li>

        <li class="nav-item">
            <?= Html::link(['paniers', 'index'], "Panier ".Html::fa("shopping-cart"), [], ['class' => 'nav-link']) ?>
        </li>
    </ul>
</nav>

<div class="container">
    <?= $this->Session->flash(); ?>
    <?= $content_for_layout; ?>
</div>
<footer class="text-muted">
    <div class="container">
        <p class="float-xs-right">
            <a href="#">Back to top</a>
        </p>
        <p>&copy; RQS</p>
    </div>
</footer>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.1.1/jquery.min.js" integrity="sha384-3ceskX3iaEnIogmQchP8opvBy3Mi7Ce34nWjpBIwVTHfGYWQS9jwHDVRnpKKHJg7" crossorigin="anonymous"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/tether/1.3.7/js/tether.min.js" integrity="sha384-XTs3FgkjiBgo8qjEjBk0tGmf3wPrWtA6coPfQDfFEY8AnYJwjalXCiosYRBIBZX8" crossorigin="anonymous"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0-alpha.5/js/bootstrap.min.js" integrity="sha384-BLiI7JTZm+JWlgKa0M0kGRpJbF2J8q+qreVrKBC47e3K6BW78kGLrCkeRX6I9RoK" crossorigin="anonymous"></script>
<?= Html::js("jsend.min"); ?>
<?php if(isset($js_to_include)){foreach($js_to_include as $js){echo Html::js($js);}} ?>

</body>

</html>

