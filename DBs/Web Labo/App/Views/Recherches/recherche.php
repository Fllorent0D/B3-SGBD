<?php
$js_to_include = ["recherche"];
?>
<form action="#" >
    <div class="row">
        <div class="col-sm-3">
            <div class="card card-block">
                <div class="form-group">
                    <legend for="exampleSelect2">Acteurs</legend>
                    <select multiple class="form-control" id="selectActeurs" style="height: 150px">
                        <?php foreach ($actors as $actor): ?>
                            <option value="<?= $actor->id ?>"><?= $actor->name ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>

            </div>
        </div>
        <div class="col-sm-3">
            <div class="card card-block">
                <div class="form-group">
                    <legend for="exampleSelect2">Genres</legend>
                    <select multiple class="form-control" id="selectGenres" style="width:100%; height: 150px">
                        <?php foreach ($genres as $genre): ?>
                            <option value="<?= $genre->id ?>"><?= $genre->name ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>

            </div>
        </div>
        <div class="col-sm-3">
            <div class="card card-block">
                <div class="form-group">
                    <legend>Popularité</legend>
                    <div class="form-check">
                        <label class="form-check-label">
                            <input type="radio" class="form-check-input" name="popRadio" id="optionsRadios1" value=">" checked>
                            Supérieure
                        </label>
                    </div>
                    <div class="form-check">
                        <label class="form-check-label">
                            <input type="radio" class="form-check-input" name="popRadio" id="optionsRadios2" value="<">
                            Inférieure
                        </label>
                    </div>
                    <div class="form-check">
                        <label class="form-check-label">
                            <input type="radio" class="form-check-input" name="popRadio" id="optionsRadios3" value="=">
                            Egale
                        </label>
                    </div>
                    <input type="number" id="popularite" class="form-control" min="0" step="1">
                </div>

            </div>
        </div>
        <div class="col-sm-3">
            <div class="card card-block">
                <div class="form-group">
                    <legend>Pérénité</legend>
                    <div class="form-check">
                        <label class="form-check-label">
                            <input type="radio" class="form-check-input" name="perRadio" id="optionsRadios1" value=">" checked>
                            Supérieure
                        </label>
                    </div>
                    <div class="form-check">
                        <label class="form-check-label">
                            <input type="radio" class="form-check-input" name="perRadio" id="optionsRadios2" value="<">
                            Inférieure
                        </label>
                    </div>
                    <div class="form-check">
                        <label class="form-check-label">
                            <input type="radio" class="form-check-input" name="perRadio" id="optionsRadios3" value="=">
                            Egale
                        </label>
                    </div>
                    <input type="number" id="perennite" class="form-control" min="0" >
                </div>

            </div>
        </div>

    </div>

    <div class="row">
        <div class="col-md-12">
            <div class="form-group">
                <legend>
                    Titre
                </legend>
                <input type="text" name="titre" id="titre" class="form-control">
            </div>
            <div class="form-group">
                <button class="btn btn-primary" id="rechercheBtn">
                    Rechercher
                </button>
                <i class="fa fa-circle-o-notch fa-spin invisible" id="loader"></i><span id="time"></span>
            </div>
        </div>
    </div>
</form>
<div class="row invisible" id="error">
    <div class="col-md-12">
        <div class="card card-block card-inverse card-danger">
            <blockquote class="card-blockquote">
                <span id="message">Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer posuere erat.</span>
            </blockquote>
        </div>
    </div>
</div>

<div class="row">
    <div class="col-md-12">
        <table class="table table-striped" id="rechecherResults">
            <thead>
            <tr>
                <th>#</th>
                <th>Titre</th>
                <th>Places vendues</th>
                <th>Pérénité</th>
                <th>

                </th>
            </tr>
            </thead>
            <tbody id="tb">

            </tbody>
        </table>
    </div>
</div>

