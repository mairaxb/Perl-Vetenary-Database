#!/usr/bin/perl
use strict;
use warnings;
use Text::CSV;
use DBI;
use HTML::Template;


my @tmp_list1;
my @tmp_list2;

#--
#parsceur du fichier csv
my @IdAnimal;
my @NomAnimal;
my @TypeAnimal;
my @Couleur;
my @Sexe;
my @Sterilise;
my @AnneNaissance;
my @Vaccin1;
my @Vaccin2;
my @Vaccin3;
my @Telephone;
my @Nom;
my @Prenom;
my @Rue;
my @CodePostal;
my @Commune;
my @NbHabitants;
my @CodeDepartement;

my $file = "Animaux.csv";
open my $fh, "<", $file or die "$file: $!";

my $csv = Text::CSV->new ({ binary => 1, auto_diag => 1 });
$csv->getline ($fh); # skip header

while (my $row = $csv->getline ($fh))     
{
        push (@IdAnimal,$row->[0]);
        push (@NomAnimal, $row->[1]);
        push (@TypeAnimal, $row->[2]);
        push (@Couleur, $row->[3]);
        push (@Sexe, $row->[4]);
        push (@Sterilise, $row->[5]);
        push (@AnneNaissance, $row->[6]);
        push (@Vaccin1, $row->[7]);
        push (@Vaccin2, $row->[8]);
        push (@Vaccin3, $row->[9]);
        push (@Telephone, $row->[10]);
        push (@Nom, $row->[11]);
        push (@Prenom, $row->[12]);
        push (@Rue, $row->[13]);
        push (@CodePostal, $row->[14]);
        push (@Commune, $row->[15]);
        push (@NbHabitants, $row->[16]);
        push (@CodeDepartement, $row->[17]);
}
close $fh;

#--
#connection a la base de donnee
my $dbh = DBI->connect("DBI:Pg:dbname=mbarca;host=dbserver","mbarca", "", {'RaiseError' => 1});


#--
# creation des tables 
$dbh ->do ("Create Table animal(IdAnimal int, NomAnimal char (10), TypeAnimal char(10), Couleur char(10), Sexe char(1), Sterilise char(3), AnneeNaissance int, Vaccin1 char(4), Vaccin2 char(4), Vaccin3 char(4),Telephone int)");

$dbh ->do ("Create Table proprio(Telephone int, Nom  char(10), Prenom char(10), Rue char(10), CodePostal int)");

$dbh ->do ("Create Table lieux(Commune char(10), CodePostal int, NbHabitants int, CodeDepartement int)");


#--
#insertion des donnees dans les differentes tables et suppresion des doublons
for (my $i=0; $i<=$#IdAnimal; $i++)
{
    $dbh ->do ("INSERT INTO animal VALUES('$IdAnimal[$i]','$NomAnimal[$i]', '$TypeAnimal[$i]', '$Couleur[$i]', '$Sexe[$i]', '$Sterilise[$i]','$AnneNaissance[$i]', '$Vaccin1[$i]', '$Vaccin2[$i]', '$Vaccin3[$i]',$Telephone[$i])");

    if(scalar(grep(/$Telephone[$i]/,@tmp_list1)) eq 0) 
    {
        push(@tmp_list1, $Telephone[$i]);
        $dbh ->do ("INSERT INTO proprio VALUES ($Telephone[$i],'$Nom[$i]','$Prenom[$i]', '$Rue[$i]', $CodePostal[$i])");
        
    }

    if(scalar(grep(/$CodePostal[$i]/,@tmp_list2)) eq 0) 
    {
    push(@tmp_list2, $CodePostal[$i]);
    $dbh ->do ("INSERT INTO lieux VALUES('$Commune[$i]', $CodePostal[$i],$NbHabitants[$i],$CodeDepartement[$i])")
    }

}

#--
#creation des differentes cles
$dbh ->do ("ALTER TABLE animal ADD CONSTRAINT P1 PRIMARY KEY (IdAnimal)");

$dbh ->do ("ALTER TABLE proprio ADD CONSTRAINT P2 PRIMARY KEY (Telephone)");

$dbh ->do ("ALTER TABLE animal ADD CONSTRAINT F1 FOREIGN KEY (Telephone) REFERENCES proprio(Telephone)");

$dbh ->do ("ALTER TABLE lieux ADD CONSTRAINT P3 PRIMARY KEY (CodePostal)");

$dbh ->do ("ALTER TABLE proprio ADD CONSTRAINT F2 FOREIGN KEY (CodePostal) REFERENCES lieux(CodePostal)");

#--
#fonctions

#fonction pour l ajout d un nouvel animal pour un proprietaire existant deja dans la base de donnee ou non
sub add_animal
{
    my $new_rue;
    my $new_commune;
    my $new_codedepartementale;
    my $new_nbhabitant;
    
    print "veuillez rentrer un identifiant pour votre animal.\n";
    my $new_id = <>;
    chomp $new_id; 
    
    print "veuillez rentrer un nom pour votre animal.\n";
    my $new_name = <>;
    chomp $new_name; 
    $new_name=ucfirst($new_name);
    
    print "veuillez rentrer un type pour votre animal.\n";
    my $new_type = <>;
    chomp $new_type; 
    $new_type=ucfirst($new_type);
    
    print "veuillez rentrer une couleur pour votre animal.\n";
    my $new_color = <>;
    chomp $new_color; 
    $new_color=ucfirst($new_color);
    
    print "veuillez rentrer un sexe pour votre animal.\n";
    my $new_sex = <>;
    chomp $new_sex; 
    $new_sex=ucfirst($new_sex);
    
    print "veuillez rentrer oui si votre animal est sterilise ou non si il ne l est pas.\n";
    my $new_sterilise = <>;
    chomp $new_sterilise; 
    $new_sterilise=ucfirst($new_sterilise);
    
    print "veuillez rentrer l annee de naissance pour votre animal.\n";
    my $new_year = <>;
    chomp $new_year; 
    
    print "veuillez rentrer l annee du premier vaccin de votre animal.\n";
    my $new_vaccin1 = <>;
    chomp $new_vaccin1; 
    
    print "veuillez rentrer l annee du deuxieme vaccin de votre animal.\n";
    my $new_vaccin2 = <>;
    chomp $new_vaccin2;
    
    print "veuillez rentrer l annee du troisieme vaccin de votre animal.\n";
    my $new_vaccin3 = <>;
    chomp $new_vaccin3;
    
    print "veuillez rentrer le numero du proprietaire de cet animal.\n";
    my $new_num = <>;
    chomp $new_num;
    
    
    if(scalar(grep(/$new_num/,@tmp_list1)) eq 0)
    {
       print "veuillez rentrer son nom.\n";
       my $new_nom = <>;
       chomp $new_nom;  
       
       print "veuillez rentrer son prenom.\n";
       my $new_prenom = <>;
       chomp $new_prenom;  
       
       print "veuillez rentrer son code postal.\n";
       my $new_cp = <>;
       chomp $new_cp;  
       
       if (scalar(grep(/$new_cp/,@tmp_list2)) eq 1)
        {
            print "entrez le nom de la rue\n";
            $new_rue=<STDIN>;
            chomp $new_rue;
            
            $dbh ->do ("INSERT INTO proprio VALUES ($new_num, '$new_nom ', '$new_prenom ', '$new_rue ', $new_cp)");
        }
        
        elsif (scalar(grep(/$new_cp/,@tmp_list2)) eq 0)
        {
            print "entrez la nouvelle  rue\n";
            $new_rue=<STDIN>;
            chomp $new_rue;
            print "entrez le nom de la commune\n";
            $new_commune=<STDIN>;
            chomp $new_commune;
            print "entrez le  code departementale\n";
            $new_codedepartementale=<STDIN>;
            chomp $new_codedepartementale;
            print "entrez le  nombre d habitants\n";
            $new_nbhabitant=<STDIN>;
            chomp $new_nbhabitant;
        
            $dbh ->do ("INSERT INTO lieux VALUES('$new_commune ', $new_cp, $new_nbhabitant, $new_codedepartementale)"); 
            $dbh ->do ("INSERT INTO proprio VALUES ($new_num, '$new_nom ', '$new_prenom ', '$new_rue ', $new_cp)");
            
        }
        
        $dbh ->do ("INSERT INTO animal VALUES($new_id, '$new_name ', '$new_type ', '$new_color ', '$new_sex ', '$new_sterilise ', $new_year, '$new_vaccin1 ', '$new_vaccin2 ', '$new_vaccin3 ', $new_num)");
       
    }
    
    if(scalar(grep(/$new_num/,@tmp_list1)) eq 1)
    {
        $dbh ->do ("INSERT INTO animal VALUES($new_id, '$new_name ', '$new_type ', '$new_color ', '$new_sex ', '$new_sterilise ', $new_year, '$new_vaccin1 ', '$new_vaccin2 ', '$new_vaccin3 ', $new_num)");
    }
    

}

#--
#fonction pour l affichage de tous les chats 
sub display_cats
{
        print "Affichage de tous les chats.\n";
        my $sth = $dbh->prepare ("SELECT idanimal AS id, typeanimal AS type, nomanimal AS names FROM animal WHERE typeanimal='Chat'");
        $sth->execute();
        while(my $ref = $sth->fetchrow_hashref())
        {
            print "$ref->{'id'} $ref->{'type'} $ref->{'names'}\n";
        }
        $sth->finish;
}

#--
#fonction pour l ajout d un nouveau vaccin a un animal de la base de donnee
sub nouveau_vaccin
{
    print "Liste des animaux en fonction de leurs identifiants et differents vaccins :.\n";
    my $sth = $dbh->prepare ("SELECT idanimal AS id, vaccin1 AS vac1, vaccin2 AS vac2, vaccin3 AS vac3  FROM animal");
    $sth->execute();
    while(my $ref = $sth->fetchrow_hashref())
        {
            print "$ref->{'id'} $ref->{'vac1'} $ref->{'vac2'} $ref->{'vac3'}\n";
        }
    
    print "Veuillez rentrer l identifiant de l animal dont vous voulez modifier le vaccin.\n";
    my $id_anim_vaccin = <>;
    chomp $id_anim_vaccin;
    
    print "Quel vaccin voulez vous modifier ? Tapez 1 pour le vaccin1, 2 pour le vaccin2 et 3 pour le vaccin3.\n";
    my $input = <>;
    chomp $input;
    
    print "Donner l  annee du vaccin que vous voulez ajouter.\n";
    my $new_vac = <>;
    chomp $new_vac;
    
    if ($input==1)
    {
        $dbh->do("UPDATE animal SET vaccin1='$new_vac' WHERE idanimal=$id_anim_vaccin");
    }
    elsif ($input==2)
    {
        $dbh->do("UPDATE animal SET vaccin2='$new_vac' WHERE idanimal=$id_anim_vaccin");
    }
    elsif ($input==3)
    {
        $dbh->do("UPDATE animal SET vaccin3='$new_vac' WHERE idanimal=$id_anim_vaccin");
    }
    else
    {
        print "Erreur veuillez recommencez.\n";
        nouveau_vaccin();
    }
    
}

#--
#fonction permettant d afficher les proprietaire ayant plus de 3 animaux
sub more_than_three
{
        print "Les proprietaires ayant plus de trois animaux sont les suivants: \n";
        my $sth2 = $dbh->prepare ("SELECT nom as nomproprietaire, prenom as prenomproprietaire FROM animal, proprio WHERE animal.telephone=proprio.telephone GROUP BY proprio.nom, proprio.prenom HAVING COUNT(animal.telephone)>3");
        $sth2->execute();
        while(my $ref = $sth2->fetchrow_hashref())
        {
            print "$ref->{'nomproprietaire'} $ref->{'prenomproprietaire'} \n";
        }       
}


#-- 
#permet d afficher le nombre de proprietaire distinct pour chaque commune
sub total_proprio
{
    print "Le nombre de proprietaire distinct par commune est de : \n";
        my $sth3 = $dbh->prepare ("SELECT commune as communes, count(proprio.codepostal) as nbproprio FROM lieux, proprio WHERE lieux.codepostal=proprio.codepostal GROUP BY commune");
        $sth3->execute();
        while(my $ref = $sth3->fetchrow_hashref())
        {
            print "$ref->{'communes'} $ref->{'nbproprio'} \n";
        }      
}

#--
#permet d afficher le nombre total d animaux pour chaque commune 
sub total_animaux
{
    print "Le nombre total d'animaux pour chaque commune est de : \n";
        my $sth4 = $dbh->prepare ("SELECT commune as communes, count(animal.idanimal) as nbanimaux FROM lieux, proprio, animal WHERE lieux.codepostal=proprio.codepostal AND animal.telephone=proprio.telephone GROUP BY commune");
        $sth4->execute();
        while(my $ref = $sth4->fetchrow_hashref())
        {
            print "$ref->{'communes'} $ref->{'nbanimaux'} \n";
        }      
}

#--
#fonction permettant de modifier l adresse d un proprietaire
sub adresse_modif 
{
    print "De quel proprietaire voulez vous modifier l adresse?\n";
    
    my $sth = $dbh->prepare ("SELECT telephone AS tel, nom as nomp, prenom as pre  FROM proprio");
    $sth->execute();
    while(my $ref = $sth->fetchrow_hashref())
        {
            print "$ref->{'tel'} $ref->{'nomp'} $ref->{'pre'}\n";
        }
    
    my $new_rue;
    my $new_commune;
    my $new_codedepartementale;
    my $new_nbhabitant;
    
    print "Entrez le numero de telephone de ce proprietaire. \n";
    my $id_telephone = <>;
    chomp $id_telephone;
    
    if(scalar(grep(/$id_telephone/,@tmp_list1)) eq 1) 
    {
    
        print "Donnez le code postal?\n";
        my $new_codepostal= <>;
        chomp $new_codepostal;
        if(scalar(grep(/$new_codepostal/,@tmp_list2)) eq 0)
        {
            print "entrez la nouvelle  rue\n";
            $new_rue=<STDIN>;
            chomp $new_rue;
            $new_rue=ucfirst($new_rue);
            print "entrez le nom de la commune\n";
            $new_commune=<STDIN>;
            chomp $new_commune;
            $new_commune= ucfirst ($new_commune);
            print "entrez le  code departementale\n";
            $new_codedepartementale=<STDIN>;
            chomp $new_codedepartementale;
            print "entrez le  nombre d habitants\n";
            $new_nbhabitant=<STDIN>;
            chomp $new_nbhabitant;
        
            $dbh ->do ("INSERT INTO lieux VALUES('$new_commune ', $new_codepostal, $new_nbhabitant, $new_codedepartementale )");
            $dbh ->do ("UPDATE proprio SET codepostal='$new_codepostal ', rue='$new_rue ' WHERE telephone='$id_telephone '");
            
        }
    
        elsif (scalar(grep(/$new_codepostal/,@tmp_list2)) eq 1)
        {
            print "entrez le nom de la rue\n";
            $new_rue=<STDIN>;
            chomp $new_rue;
            
            $dbh ->do ("UPDATE proprio SET rue='$new_rue ' WHERE telephone='$id_telephone '");
        }
    
    }
    else 
    {
        print "Erreur, veuillez rentrer un telephone valide.\n";
    }
    
}

#--
#fonction permettant d afficher les animaux de type X ayant moins de Y age
sub display_type_annee
{
    #my $date = strf("%Y", localtime());
    
    
    print "Choisissez un type d animal.\n";
    my $input_type = <>;
    chomp $input_type;
    $input_type=ucfirst($input_type);
    
    print "Donnez l age max des animaux souhaiter.\n";
    my $input_age = <>;
    chomp $input_age;
    
    print "Choisissez l annee de reference pour calcule l age.\n";
    my $date = 2017; #on prend 2017 comme annee de reference
    #chomp $date;
    
    my $condition = $date - $input_age;
    
    my $sth = $dbh->prepare ("SELECT idanimal as id, nomanimal as nom, typeanimal as type from animal where typeanimal='$input_type ' AND anneenaissance > $condition ");
    $sth->execute();
    
    print "Les animaux de type $input_type ayant moins de $input_age sont :\n";
    
    while(my $ref = $sth->fetchrow_hashref())
        {
            print "$ref->{'id'} $ref->{'nom'} $ref->{'type'}\n";
        } 
    
    
}

#--
#fonction permettant d afficher le nombre moyen d animaux par proprietaire
sub nbr_moyen
{
    my $sth = $dbh->prepare ("SELECT AVG(count) as moyenne from (select count(idanimal) from animal group by telephone) as requete ");
    $sth->execute();

    print "Le nombre moyen d animaux par proprietaire est de :\n";
    
    while(my $ref = $sth->fetchrow_hashref())
        {
            print "$ref->{'moyenne'}\n";
        } 
}

#--
# creation d un tableau sur page html pour afficher le nombre de proprietaire ayant plus de 3 animaux 
sub display_table
{

    
    #1ere requete
    my $sth = $dbh->prepare ("SELECT nom, prenom FROM animal, proprio WHERE animal.telephone=proprio.telephone GROUP BY proprio.nom, proprio.prenom HAVING COUNT(animal.telephone)>3");
    $sth->execute();
    my $rows;
    push @{$rows}, $_ while $_ = $sth->fetchrow_hashref();
    
 
    #insertion dans fichier tmpl
    my $t = HTML::Template->new(filename => 'template.tmpl');
    $t->param(ROWS=>$rows);


    open (my $file, ">file.html");
    print $file $t->output();
    
    print "Veuillez lancer la page file.html a partir du terminal.";
}
   
#--
# creation d un tableau sur page html pour afficher le nombre de proprietaires distincts pour chaque commune    
sub display_table1
{
    
    my $sth2 = $dbh->prepare ("CREATE VIEW nbprop AS(SELECT commune, count(proprio.codepostal) as nbproprio FROM lieux, proprio WHERE lieux.codepostal=proprio.codepostal GROUP BY commune)");
    $sth2->execute();
    
    my $boo = $dbh->prepare("SELECT commune, nbproprio FROM nbprop");
    $boo->execute();
    
    my $rows;
    push @{$rows}, $_ while $_ = $boo->fetchrow_hashref();
    
    my $table = HTML::Template->new(filename => 'template2.tmpl');
    $table->param(ROWS=>$rows);

    open (my $file, ">file2.html");
    print $file $table->output();
    
    print "Veuillez lancer la page file2.html a partir du terminal.";
    $dbh->do ("DROP VIEW nbprop");
    
    
}

#--
# creation d un tableau sur page html pour afficher le nombre de total d animaux pour chaque commune    
sub display_table2
{
    
    my $bar = $dbh->prepare ("CREATE VIEW nbanimauxtotaux AS (SELECT commune, count(animal.idanimal) as nbanim FROM lieux, proprio, animal WHERE lieux.codepostal=proprio.codepostal AND animal.telephone=proprio.telephone GROUP BY commune)");
    $bar->execute();
    
    my $foo = $dbh->prepare("SELECT commune, nbanim FROM nbanimauxtotaux");
    $foo->execute();
    
    my $rows;
    push @{$rows}, $_ while $_ = $foo->fetchrow_hashref();
    
    my $table = HTML::Template->new(filename => 'template3.tmpl');
    $table->param(ROWS=>$rows);

    open (my $file, ">file3.html");
    print $file $table->output();
    
    print "Veuillez lancer la page file3.html a partir du terminal.";
    $dbh->do ("DROP VIEW nbanimauxtotaux");
}

#--
#menu
sub menu
{
	print"\n";
	print"		Que voulez vous faire ?\n";
	print"\n";
	print"Tapez 1 pour ajouter un nouvel animal. \n";
	print"Tapez 2 pour modifier l adresse d un proprietaire. \n";
	print"Tapez 3 pour enregistrer un nouveau vaccin. \n";
	print"Tapez 4 pour afficher tous les chats. \n";
	print"Tapez 5 pour afficher les animaux de type X ayant moins de Y années. X et Y sont des paramètres. \n";
	print"Tapez 6 pour afficher le nombre moyen d’animaux par propriétaire. \n";
	print"Tapez 7 pour afficher les propriétaires qui ont plus de trois animaux\n";
	print"Tapez 8 pour afficher le nombre de propriétaires distincts pour chaque commune.\n";
	print"Tapez 9 pour afficher le nombre total d'animaux pour chaque commune.\n";
	print"Tapez 10 pour afficher le resultat de la requete 7 dans un navigateur web.\n";
	print"Tapez 11 pour afficher le resultat de la requete 8 dans un navigateur web.\n";
	print"Tapez 12 pour afficher le resultat de la requete 9 dans un navigateur web.\n";
    print"Tapez 0 pour quitter\n";
}

my $answer=-8;
print"		Bonjour\n";
while ($answer !=0)
{
	menu();
	$answer = <STDIN>;
	chomp($answer);
	if ($answer eq 1)
	{
		add_animal();
	}
	if ($answer eq 2)
	{
		adresse_modif();
	}
	
	if ($answer eq 3)
	{
        nouveau_vaccin();
    }
    if ($answer eq 4)
    {
        display_cats();
    }
    if ($answer eq 5)
    {
        display_type_annee();
    }
    if ($answer eq 6)
    {
        nbr_moyen();
    }
    if ($answer eq 7)
	{
        more_than_three();
    }
    if ($answer eq 8)
	{
        total_proprio();
    }
    if ($answer eq 9)
	{
        total_animaux();
    }
    if ($answer eq 10)
	{
        display_table();
    }
    if ($answer eq 11)
	{
        display_table1();
    }
    if ($answer eq 12)
	{
        display_table2();
    }
}
print"		Goodbye\n";

