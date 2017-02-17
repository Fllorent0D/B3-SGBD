<?php
use Swith\Form;

?>
<div class="row">
    <table class="table table-striped">
        <thead>
        <tr>
            <th width="40%">Film</th>
            <th width="10%">Date</th>
            <th width="10%">Quantite</th>
            <th width="20%"></th>
            <th width="20%"></th>
        </tr>
        </thead>
        <tbody>

        <?php
        if(!empty($panier)):
            foreach ($panier as $identifier => $reservation):  ?>
                <tr>
                    <td><?= $reservation["film"]?></td>
                    <td><?= $reservation["date"]?></td>
                    <td><?= $reservation["quantite"] ?></td>
                    <td><?= Form::start("add", "POST", [
                            "manageErrors" => false,
                            "defaultInput" => [
                                "class" => 'form-control',
                                "noError" => true,
                            ],
                            "defaultLabel" => [
                                "class" => '',
                                "noError" => true,
                                "errorFormat" => "%MSG%",
                            ],
                        ])
                            ->start_fieldset(["class" => "form-inline"])
                            ->input("number", "quantite", 1)
                            ->close_fieldset()
                            ->input("hidden", "seance", $identifier)
                            ->end("Ajouter des places", ["class" => "btn btn-sm btn-block btn-primary"]);
                        ?></td>
                    <td>
                        <?= Form::start("remove", "POST", [
                            "manageErrors" => false,
                            "defaultInput" => [
                                "class" => 'form-control',
                                "noError" => true,
                            ],
                            "defaultLabel" => [
                                "class" => '',
                                "noError" => true,
                                "errorFormat" => "%MSG%",
                            ],
                        ])
                            ->input("hidden", "seance", $identifier)
                            ->end("Supprimer les tickets", ["class" => "btn btn-sm btn-block btn-danger"]);
                        ?>
                    </td>
                </tr>
            <?php endforeach;
        else: ?>

            <tr>
                <td colspan="4" class="mx-auto"><h5>Aucune réservation</h5></td>
            </tr>
        <?php endif; ?>
        </tbody>
    </table>
</div>
<?php if(!empty($panier)): ?>
<div class="row " style="margin-top: 50px">
    <div class="card card-outline-secondary text-xs-center">
        <div class="card-block">
            <blockquote class="card-blockquote">
                <?= \Core\Helpers\Html::link(["paniers", 'validate'], "Valider le panier", [], ["class" => "btn btn-success float-xs-right", "style" => "margin-left : 10px"]) ?>
                <?= \Core\Helpers\Html::link(["paniers", 'reset'], "Annuler le panier", [], ["class" => "btn btn-danger float-xs-right"]) ?>
            </blockquote>
        </div>
    </div>
</div>
<?php endif; ?>

<div class="row">
    <pre>
        <?= var_dump($panier) ?>
    </pre>
</div>