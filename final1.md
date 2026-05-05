Bon on va rendre l'application totalement fonctionnelle. On va améliorer plein de points.  

1 - Quand on allume l'application, il y a un splash screen qui est noir puis on tombe sur le login immédiatement. On devrait voir le splash screen avec le logo de l'application avec un chargement en bas pendant 2 ou 3 secondes puis on tombe sur le login. 

2 - Pour la page de login, normalement ici il y a seulement l'email et le mot de passe. Voilà que c'est supabase qui gère alors le nom d'email de verification est limité, donc on va seulement utilisé les numéros de téléphones comme login. C'est à dire à la création du compte, il y aura u formulaire qui contient le username (qui doit être unique pour chaque personne, donc une requête sql doit être faite pour vérifier si le username existe déjà) de la personne obligatoire, le numéro de telephone obligatoire, le code de vérification du numéro qui sera envoyé par sms, le mot de passe, et la confirmation du mot de passe obligatoire. Tu peux te servir du fichier final.md pour voir les tables ou requetes que j'ai deja effectué comme ça si je dois effectuer d'autres tu me dis je les fais

3 - Aussi toujours sur la page login, on va devoir se conformer au design recommandé, alors dans assets/images, dans le design la page de login est d'abord composé de Ambient.png (tu verra ca dans assets/images), puis sur ca tu met le logo de notre app (ce qui est sur le dashboard en haut c'est ça tu met), puis en bas on n'aura le nom (Miwakpon, puis un petit texte comme: Creer votre compte pour pouvoir enjoyer des moments uniques sur la page creation, sur la page connection tu peux mettre connecter vous pour enjoyer des moments uniques. ). Apres bien sur tu te conforme au formulaire du point 2 (donc username, numéro de telephone, code de verification, mot de passe, confirmation du mot de passe)

4 - Sur la page feed, la session évènements doit toujours afficher les 2 derniers évènements que j'ai posté. En plus de ça à coté de Mes évenement il doit avoir un bouton fleche façon qui permet de voir plus, mais ce voir plus redirige vers une historique de tous les évènements que j'ai posté. 

5 - Sur le tableau de bord ce n'est pas seulement les évenements que j'ai posté qui doit s'afficher, il doit y avoir un melange ou aléatoire de 3 évènements postées par moi ou n'importe qui (ceux des gens qui veulent s'afficher), mais ce qui est sur c'est qu'ils doivent être en cours

6 - Sur la page events, il doit y avoir bien sur tous les évènements de tous les utilisateurs, mais avec des filtres. Donc je dois pouvoir chercher par nom, par lieu, par date , et aussi par ceux que moi j'ai posté uniquement et pour tous le monde.

7 - Quand je rentre dans un évènement, que je n'ai pas poster c'est à dire qui n'est pas le mien je ne peux pas joindre, donc le bouton jion event doi s'afficher suelement si il'eveneemnt cree n'est pas cree par moi, aussi les petits icone d'image qui sont là, je evux que ca soit pour les gens qui s'y sont inscrit, donc s'il n'y a personne il aura une icone blanc c'est tout

8 - Si je ne suis pas le créateur de l'evenement, et j'appuie sur join event, il m'inscrit, et le bouton change en "Quitter evenement" et si j'appuie sur "Quitter evenement" il me retire de l'evenement, et le bouton redevient "rejoindre evenement", mais si je suis le créateur, je ne peux ni m'inscrire, ni quitter, donc je veux que ces deux boutons (rejoindre evenement, et quitter evenement) n'apparaisse que si je ne suis pas le créateur, sinon pas du tout. Sur la photo de couverture et tout ca c'est bien sur dans la page detail, je dois voir comme trois points en haut à droite (dans le noir), qui me permettront de modifier l'évènement.

9 - La page qui vient quand on appuie sur voir les participants, doit afficher la liste des participants avec leurs photos de profil (s'il y en a), 

10 - Pour la page profil, on doit pouvoir ajouter une photo de profil, alors ca doit s'actualiser partout pour les icones de profil, aussi sur la page profil apres le photo, je vois artia béninois, maitre artisant . Cotonou, Bénin, passionné par l'artianat traditionnel, je veux juste qu'il ait le username de la personne là.

11 - Donc sur la page prfil toujours, dans la session mon profil, bien sur il y aura le username qu'on petu modifier, le numero de telephone qu'on peut modifier, et le mot de passe qu'on peut modifier aussi. Apres pour la sessio nparamètres on doit enlever mode sombre, et juste laisser notifications. Apres y a la session Aide, qui doit contenir le centre de support, termes et conditions, et politique de confidentialité.

Contraintes : 
- Tous les noms des pages sont en français, sauf le nom de l'app, qui est Miwakpon.
- Les données viennent de supabase, donc tu peux utiliser supabase.dart pour interroger la base de données.
- Tu peux utiliser tous les package que tu veux, mais respecte les consignes données.
- Soit rigoureux, et respecte les consignes données.
- Si tu as besoin d'exécuter des requetes dis le moi, envoie moi ca et je le ferai dans supabase, tu peux deja voir ce qui a ete deja fait dans final.md
- N'oublie pas de faire des commit ou sauvegardes pour chaque modifications
- C'est seulement a la fi nquand tout sera bien fait qu'on pourra merge ave le main

