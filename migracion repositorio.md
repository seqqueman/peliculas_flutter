# Pasos para complementarios para migracion repositorio SVN

_En este documento se intentarán describir una serie de pasos adicionales para una  migración mas completa de un repositorio SVN a GIT, en este caso el repositorio de DEXEL_

## Comenzando 🚀

_Todos los pasos aquí realizados se ejecutan desde una maquina windows.

Se toma coma base la guía de migración de la CARM **https://github.com/carm-es/guias/blob/master/migracion/Migracion_de_Subversion_a_GitLab.md** .
Solo nos centraremos y extenderemos la parte de clonado y limpieza del respositorio SVN


### Pre-requisitos 📋

_Tener instalado GIT (vamos a usar su git bash)_

_Tener instalado cliente SVN con soporte linea de comandos (Vg: TortoiseSVN)_

_Tener instalado Python (3.7 +)_

_Tener instalado git-filter-repo (es un "addon" escrito en python que el propio GIT te recomienda como sustito a su git filter-branch)_


### Instalación 🔧

_De todo lo anterior el único que puede presentar un escollo en su correcta instalación es git-filter-repo en Windows. Vamos a explicar los pasos_

_Nos aseguramos que tenemos Python en nuestro path (variables de entorno). Suele encontrarse en la ruta

```
C:\Users\Mi_Usuario\AppData\Local\Programs\Python\Python39  (para la version 3.9)
```

_Visitamos el repositorio_

```
https://github.com/newren/git-filter-repo
```

_Una vez ahí podemos descargar/clonar el repositorio completo o el fichero "git-filter-repo" sin extension de ningun tipo que contine todo el código_

Abrimos el fichero que hemos descargado con un editor de texto, como el Notepad++ y cambiamos la primera linea por la ruta a nuestro ejecutable de Python.
```
#!C:\Users\Mi_Usuario\AppData\Local\Programs\Python\Python39\python.exe python
```

Abrimos nuestro git bash y escribimos
```
git --exec-path
```

En la ruta que nos aparezca debemos colocar el fichero git-filter-repo que hemos modificado.

_Para comprobar que funciona, abrimos una nueva git bash y escribimos el comando_

```
git filter-repo
```
La salida debería devolvernos un 

```
No arguments specified
```


## Clonando el repositorio ⚙️

_Para el clonado el primer paso es recavar los usuarios que han tomado parte en los commits al repositorio. Para ello podemos usar el comando que se describe en la guía CARM o usar este_

```
svn log -q -r 1:HEAD https://vcs.carm.es/svn/dexel/ | awk -F '|' '/^r/ {sub("^ ", "", $2); sub(" $", "", $2); print $2" = "$2" <"$2">"}' | sort -u > ruta_que_queramos/autores.txt
```

Al igual que en la guía CARM ese fichero deberá completarse con la información real de nombre (streetname) y email de los usuarios.

_Una vez tengamos el fichero de autores completo pasamos a realizar el clonado, aunque se han eliminado las ramas viejeas del repositorio, la información sigue ahí (en su historial, podemos decir) y descargará todo. Al ser un repositorio con mucha "historia" el proceso será largo._
 
Para que el clonado sea lo mas fiel a lo que actualmente se encuentra en el repositorio debemos especificar las rutas a trunk, branches y tags.

```
git svn clone --authors-file=autores-dexel-transformado.txt https://vcs.carm.es/svn/dexel --trunk=trunk --branches=branches/*/* --tags=tags/*/* --no-minimize-url --no-metadata dexelTemp
```

La parte de 
```
--branches=branches/*/* --tags=tags/*/*
```
es la parte que nos ayuda a que "git svn clone" encuentre las ramas en la estructura de carpetas del repositorio "branches/proyectoDexel_o_modulob_bo/nombrerama".



### Convertir los tags de svn a tags de GIT 🔩

_Recorremos los tags nos los traemos a local y los borramos como branch_

```
git for-each-ref --format="%(refname:short) %(objectname)" refs/remotes/origin/tags \
| while read BRANCH REF
  do
        TAG_NAME=${BRANCH#*/}
        BODY="$(git log -1 --format=format:%B $REF)"

        echo "ref=$REF parent=$(git rev-parse $REF^) tagname=$TAG_NAME body=$BODY" >&2

        git tag -a -m "$BODY" $TAG_NAME $REF^  &&\
        git branch -r -d $BRANCH
  done
```

### Traernos las branch a local ⌨️

_Ahora nos traemos las branches a local_

Aquí podemos hacer 2 cosas, traernos todas las ramas a nuestro local evitando trernos la rama master y la trunk (que ya la tendriamos) pero si el resto, o evitar traernos la rama trunk, master y todas las que no necesitamos y quedarnos solo con la ramas que queremos de "xxx_20201021_seguridad_despues_merge"

_Para el primer supuesto podemos ejecutar el siguiente comando_

```
for branch in $(git branch -a | egrep -v 'tags|trunk|master'); do \
branchname=$(echo $branch | sed 's_remotes/origin/__g'); \
git branch $branchname $branch ; done
```

_Para el segundo supuesto usariamos este comando_

```
for branch in $(git branch -a | egrep -v 'tags|trunk|master|*20201021*'); do \
branchname=$(echo $branch | sed 's_remotes/origin/__g'); \
git branch $branchname $branch ; done
```

## Subida del repositorio

Una vez tenemos convertidas las etiquetas y también tenemos las ramas en local, subimos al repositorio que hemos creado en GitLab

_Primero eliminamos cualquier referencia a remoto que podamos tener_

```
git remote remove origin
```

_Despues añadimos nuetro nuevo repositorio en GitLab y subimos nuestro local_

```
git remote add origin https://gitlab.carm.es/loquesea
git push origin '*:*'
```

## Dividiendo el repositorio 📦

_Como vamos a dividir en dos el repositorio vamos a clonar 2 veces el repositorio que tenemos en GitLab_

Una vez clonado por partida doble, los pasos a seguir es limpiar las referencias en el historial de commits a las ramas y los tags del proyecto que queremos dejar fuera. Es decir, para DexelWeb limpiaremos las referencias a modulo-bo-dexel y lo contrario para modulo-bo-dexel.

Supongamos que hemos entrado al clonado que será la base de DexelWeb, y vamos a limpiar las referencias a modulo-bo-dexel.
1. Nos traemos todas las ramas a local
```
for i in $(git branch -r | grep -vE "HEAD|master" | sed 's/^[ ]\+//');
  do git checkout --track $i
done
```

2. Quitamos la referencia al repositorio remoto y nos movemos a la rama master

```
git remote remove origin
git checkout master 
```

3. Con git-filter-repo limpiamos primero en las ramas las referencias que no tienen que ver con DexelWeb en las ramas que no son de DexelWeb (***/modulo-bo-dexel/***)

```
git filter-repo -f --prune-empty always --subdirectory-filter DexelWeb --refs $branch $(git branch -a --list *\/modulo-bo-dexel*)
```

4. Lo mismo para los tags

```
git filter-repo -f --prune-empty always --subdirectory-filter DexelWeb --refs $branch $(git tag --list *\/modulo-bo-dexel*)
```

5. Por último lo hacemos sobre la rama master y convertimos a la carpeta DexelWeb en la carpeta raiz del repositorio.

```
git filter-repo -f --prune-empty always --subdirectory-filter DexelWeb --refs master
```

_Para el caso de modulo-bo-dexel, los pasos serían similares cambiando un par de cosillas y por supuesto, ejecutando los comandos en la carpeta del clonado que vayamos a destinar a modulo-bo-dexel

```
git filter-repo -f --prune-empty always --subdirectory-filter modulo-bo-dexel --refs $branch $(git branch -a --list *\/dexel*)

git filter-repo -f --prune-empty always --subdirectory-filter modulo-bo-dexel --refs $branch $(git tag --list *\/dexel*)
```
En el caso de modulo-bo-dexel, la carpeta elasticsearch pasará a ser parte del proyecto, así que en master, tendremos que eliminar DexelWeb y limpiar las referencias a dexel
```
git filter-repo -f --prune-empty always --subdirectory-filter DexelWeb --invert-paths --refs master
```

### Subida a los repositorios

_Antes de subir a los repositorios, podemos renombrar las ramas "*20201021_seguridad_despues_merge" a "develop" como indica la buenas practicas de la CARM_

```
git branch -m "xxx_20201021_seguridad_despues_merge" "develop"
```

_Crear los repositorios para los proyectos divididos, añadirlos como remote origin y hacer el push con "git push origin '*:*'"_
