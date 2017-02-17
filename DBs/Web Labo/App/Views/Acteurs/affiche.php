<?php
/**
 * Created by PhpStorm.
 * User: florentcardoen
 * Date: 20/10/2016
 * Time: 11:04
 */?>
<div class="row">
    <div class="col-md-3">
        <?php if(@!is_null($people->profile_path)): ?>
        <img class="img-fluid rounded" src="http://image.tmdb.org/t/p/w185/<?= $people->profile_path ?>" alt="">
        <?php else : ?>
        <div class="alert alert-warning">Pas de photo disponible</div>
        <?php endif; ?>
    </div>
    <div class="col-md-9">
        <h1><?= $people->name ?></h1>
        <?= (!empty($people->biography))? "<p>".$people->biography."</p>":"" ?>
        <?= (!empty($people->deathday))? "<h5>Date de naissance : ".$people->birthday."</h5>":"" ?>
        <?= (!empty($people->deathday))? "<h5>Date de mort : ".$people->deathday."</h5>":"" ?>
        <h2>Filmographie</h2>
        <?php if(empty($people->credits->cast)): ?>
            <p>Aucun film référencé</p>
        <?php else: ?>
        <?php foreach ($people->credits->cast as $film) : ?>
            <div class="col-md-6">
                <div class="card-block">
                    <div class="card-header"><?= @$film->original_title ?></div>
                    <div class="card-block">
                        <p class="card-text">Role : <?= @$film->character ?></p>
                        <p class="card-text">Date du film : <?= @$film->release_date ?></p>
                    </div>
                </div>
            </div>
        <?php endforeach; ?>
    <?php endif; ?>
        
    </div>
</div>

