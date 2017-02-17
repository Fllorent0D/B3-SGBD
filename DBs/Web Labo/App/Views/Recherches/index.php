<?php

$test = array();
foreach ($films as $film){
    $el = new stdClass();
    $el->id = $film->id;
    $el->title = $film->title;
    array_push($test, $el);
}
?>
<section class="jumbotron text-xs-center">
    <div class="container">
        <h1 class="jumbotron-heading">Rennequinepolis</h1>
        <p class="lead text-muted">Films à l'affiche</p>
    </div>
</section>

<div class="text-muted">
    <div class="container">

        <div class="row">
            <?php for ($i = 0; $i < 3; $i++) : ?>
                <div class="col-md-4">
                <?php for ($j = $i; $j < count($films); $j+=3) : ?>
                    <div class="card">
                        <div class="card-block">

                            <img src="http://bp.dev/api/poster/<?= $test[$j]->id ?>" alt="<?= $test[$j]->title ?>'s poster" class="mx-auto d-block img-fluid img-thumbnail">

                            <h5 class="card-title text-center"><?= $test[$j]->title; ?></h5>
                            <?= \Core\Helpers\Html::link(["recherches", "film"], "Plus d'informations...", [$test[$j]->id], ["class" => "btn btn-primary"]) ?>
                        </div>
                    </div>
                <?php endfor; ?>

                </div>
            <?php endfor; ?>


        </div>
    </div>
</div>

