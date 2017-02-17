<?php
/**
 * Created by PhpStorm.
 * User: florentcardoen
 * Date: 09/12/2016
 * Time: 09:15
 */
use Carbon\Carbon;
use Swith\Form;
?>
<div class="row">
    <div class="col-md-3">
        <img src="http://bp.dev/api/poster/<?= $infos->id ?>" alt="<?= $infos->title ?>'s poster" class="mx-auto d-block img-fluid img-thumbnail">
        <br>
        <button type="button" class="btn btn-primary btn-block" data-toggle="modal" data-target="#myModal">
            Acheter une place
        </button>
    </div>
    <div class="col-md-9">
        <div class="card-block">
            <div class="card-header">
                <h3><?= $infos->title ?></h3>
                <h6><?= $infos->original_title ?></h6>
            </div>
            <div class="card-block">
                <div class="row">
                    <p class="card-text"><span><i class="fa fa-calendar"></i> <?= $infos->release_date ?></span> <i class="fa fa-star"></i> <span><?= $infos->status->name ?></span> <i class="fa fa-certificate"></i> <span><?= $infos->certification->name ?></span></p>
                </div>
                <div class="row">
                    <p class="card-text">
                        <?= (!empty($infos->tagline))? $infos->tagline : '' ?>
                    </p>
                </div>

                <div class="row" style="padding-top: 30px">
                    <div class="col-md-6">
                        <div class="list-group">
                            <h6 class="list-group-item disabled">Acteurs</h6>
                            <?php
                            if(!empty($infos->actors)):
                                foreach ($infos->actors->actor as $actor):
                                    echo \Core\Helpers\Html::link(["acteurs", "affiche"], $actor->name, [$actor->id], ["class" => "list-group-item"]);
                                endforeach;
                            else: ?>
                                <a href="#" class="list-group-item disabled">Aucun acteur référencé</a>
                            <?php endif; ?>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="list-group">
                            <h6 class="list-group-item disabled">Réalisateurs</h6>
                            <?php
                            if(!empty($infos->directors)):
                                foreach ($infos->directors->director as $director):
                                    echo \Core\Helpers\Html::link(["acteurs", "affiche"], $director->id, [$director->id], ["class" => "list-group-item"]);
                                endforeach;
                            else: ?>
                                <a href="#" class="list-group-item disabled">Aucun acteur référencé</a>
                            <?php endif; ?>
                        </div>
                    </div>
                </div>

                <div class="row" style="padding-top: 30px;">
                    <ul class="nav nav-tabs" role="tablist">
                        <?php $i = true;foreach ($schedule as $key => $date): ?>
                            <li class="nav-item">
                                <a class="nav-link <?php if($i){echo 'active';$i=false;} ?>" data-toggle="tab" href="#p<?= Carbon::parse($key)->format('Ymd'); ?>" role="tab"><?= Carbon::parse($key)->format('d F'); ?></a>
                            </li>
                        <?php endforeach; ?>
                    </ul>
                    <div class="tab-content" style="padding: 10px">
                        <?php $i = true; foreach ($schedule as $key => $date): ?>
                            <div class="tab-pane<?php if($i){echo ' active';$i=false;} ?>" id="p<?= Carbon::parse($key)->format('Ymd'); ?>" role="tabpanel">
                                <?php foreach ($date as $heure): ?>
                                 <span class="tag tag-default"><?= $heure->date->format('G:m') ?> (<?= $heure->placeRestantes() ?> places restantes)</span>

                                <?php endforeach; ?>
                            </div>
                        <?php endforeach; ?>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<div class="modal fade" id="myModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
                <h4 class="modal-title" id="myModalLabel">Acheter une place</h4>
            </div>
            <div class="modal-body">
               <?=
               Form::start("/paniers/add", "POST", [
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
                   ->start_fieldset(["class" => "form-group"])
                   ->select("seance", $select_options)
                   ->close_fieldset()
                   ->start_fieldset(["class" => "form-group"])
                   ->input("number", "quantite", 1)
                   ->close_fieldset()
                   ->input("hidden", "film", $infos->title)
                   ->end("Ajouter au panier", ["class" => "btn btn-success float-right"]);

               ?>
            </div>

        </div>
    </div>
</div>
