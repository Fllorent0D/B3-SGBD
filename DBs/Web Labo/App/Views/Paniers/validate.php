
<div class="col-md-6">
    <?php var_dump($document); ?>
</div>
<div class="col-md-6">
    <h3>Réponse</h3>

    <?php foreach ($response as $place): ?>
        <?php if($place["code"] != 0) $isvalid = false; ?>`
        <div class="card card-inverse card-<?php switch($place["code"]){ case 0 : echo 'success'; break; case 1 : echo "danger"; break; case 2: echo 'warning'; break; case 3: echo 'primary'; break; } ?>">
            <div class="card-block">
                <blockquote class="card-blockquote">
                    <ul>
                        <li>Code : <?= $place["code"] ?></li>
                        <li>Projection : <?= $place["projection"] ?></li>
                        <li>Date : <?= $place["date"] ?></li>
                    </ul>
                    <p><?= $place->message ?></p>
                </blockquote>
            </div>
        </div>

    <?php endforeach; ?>
    <p>
        <?php
        if($isvalid)
            echo "Votre panier à bien été validé.";
        else
            echo "Merci de corriger les erreurs de votre panier";

        ?>
    </p>
</div>