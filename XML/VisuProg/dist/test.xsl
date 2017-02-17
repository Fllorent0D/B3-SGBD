<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet extension-element-prefixes="dyn" version="1.0" xmlns:dyn="http://exslt.org/dynamic" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:param name="prog" select="'prog.xml'"/>
	
	<xsl:variable name="programmation" select="document($prog)"/>

	<xsl:key match="programmation/demande" name="demande-search" use="@idDemande"/>

	<xsl:output doctype-system="about:legacy-compat" encoding="UTF-8" indent="yes" method="html"/>
	<xsl:template match="/">
		<html>
			<head>
				<title>FeedBack</title>
				<meta charset="utf-8"/>
				<meta content="width=device-width, initial-scale=1, shrink-to-fit=no" name="viewport"/>
				<meta content="ie=edge" http-equiv="x-ua-compatible"/>
				<link href="css/bootstrap.min.css" rel="stylesheet"/>
			</head>
			<body style="padding-top:60px">
				<div class="container">
					<div class="row">
						<h1>Feedbacks</h1>
						<xsl:apply-templates select="feedback/demande"/>
					</div>
				</div>
			</body>
		</html>
	</xsl:template>
	<xsl:template match="demande">
		<xsl:param name="id" select="number(idDemande)"/>
		<div class="card">
			<div class="card-header">
				<h3>Demande #
					<xsl:value-of select="idDemande"/></h3>
			</div>
			<div class="card-block">
				<div class="col-md-6">
					<h5>Erreurs</h5>
					<ul>
						<xsl:apply-templates select="errors/error"/>
					</ul>
				</div>
				<div class="col-md-6">
					<h5>Demande de projection</h5>
					<xsl:apply-templates mode="prog" select="$programmation/programmation/demande[@idDemande=$id]"/>
					<xsl:value-of select="key('demande-search', $id)"/>
				</div>
			</div>
		</div>
	</xsl:template>
	<xsl:template match="error">
		<li>
			<xsl:value-of select="text()"/>
		</li>
	</xsl:template>
	<xsl:template match="demande" mode="prog">
		<table class="table table-sm">
			<tbody>
				<tr>
					<th>Id Movie</th>
					<td><xsl:value-of select="idMovie"/></td>
				</tr>
				<tr>
					<th>Numero copie</th>
					<td><xsl:value-of select="numCopy"/></td>
				</tr>
				<tr>
					<th>Date début</th>
					<td><xsl:value-of select="debut"/></td>
				</tr>
				<tr>
					<th>Date fin</th>
					<td><xsl:value-of select="fin"/></td>
				</tr>
				<tr>
					<th>Salle</th>
					<td><xsl:value-of select="salle"/></td>
				</tr>
				<tr>
					<th>Heure</th>
					<td><xsl:value-of select="heure"/></td>
				</tr>
				<tr/>
			</tbody>
		</table>
	</xsl:template>
</xsl:stylesheet>