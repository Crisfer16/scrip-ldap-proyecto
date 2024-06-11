#!/bin/bash
clear

#funciones para la creacion del fichero

function generar_fichero_usuario_normal 
{

echo "
dn: uid=$1,ou=prueba_cristian,dc=cristian,dc=local
objectClass: top
objectClass: posixAccount
objectClass: inetorgPerson
objectClass: person
cn: $1
uid: $1
uidNumber: $2
gidNumber: 10000
homeDirectory: /home/$1
loginShell: /bin/bash
userPassword: $3
sn: script
givenName: $1
" > crear_usuario.ldif
}

function generar_fichero_usuario_perfil_movil 
{

echo "
dn: uid=$1,ou=prueba_cristian,dc=cristian,dc=local
objectClass: top
objectClass: posixAccount
objectClass: inetorgPerson
objectClass: person
cn: $1
uid: $1
uidNumber: $2
gidNumber: 10000
homeDirectory: /moviles/$1
loginShell: /bin/bash
userPassword: $3
sn: script
givenName: $1
" > crear_usuario.ldif

}

function generar_fichero_grupo 
{

echo "
dn: cn=$1,ou=prueba_cristian,dc=cristian,dc=local
objectClass: top
objectClass: posixGroup
gidNumber: $2
cn: $1
" > crear_grupo.ldif


}

if [ $(whoami) == 'root' ]; then


    echo "Asistente de creacion de objetos(usuario, usuario con perfil movil y grupos ) para Openldap"

    echo -e "\n"


    #solicitar opcion

    read -p "dame la opcion que quieres hacer: -u crear usuarios, -m crear usuarios con perfil movil y '-g' crear grupo:" opcion

    
    # menu de opciones

    case ${opcion} in

        -u)

            echo -e "\n"
        
            echo "has seleccionado la opcion -u, vas a crear un usuario normal para Openldap"

            echo -e "\n"

            # solicitar la información para el usuario de Openldap

            read -p "dame el nombre del usuario:" nombre_usu

            read -p "dame el uid (uidNumber) del usuario, rangos ocupados(2,000-3,500 / 10,000-30,000):"  uid_usuario

            read -p "dime la contraseña que quieres que tenga el usuario:" contra_usuario

            #variable para cifrar la contraseña

            contra_cifrada=$( slappasswd -s $contra_usuario )

            # llamada a la funcion y creacion del usuario

            #llamada a la funcion de creacion de usuario normal

            
            generar_fichero_usuario_normal $nombre_usu $uid_usuario $contra_cifrada


            #comando para añador el usuario al Openldap

            echo -e "\n"

            ldapadd -x -D cn=admin,dc=cristian,dc=local -W -f crear_usuario.ldif

            #opcional: buscar por el uid si esta el usuario

            echo -e "\n"

            ldapsearch -xLLL -b "dc=cristian,dc=local" uidNumber=$uid_usuario

            ;;


        -m)

            echo -e "\n"

            echo "has seleccionado la opcion -m, vas a crear un usuario con perfil movil para Openldap" 

            echo -e "\n"

            # solicitar la información para el usuario de Openldap

            read -p "dame el nombre del usuario:" nombre_usu

            read -p "dame el uid (uidNumber) del usuario, rangos ocupados(2,000-3,500 / 10,000-30,000):"  uid_usuario

            read -p "dime la contraseña que quieres que tenga el usuario:" contra_usuario

            #variable para cifrar la contraseña

            contra_cifrada=$( slappasswd -s $contra_usuario)

            # llamada a la funcion y creacion del usuario

            #llamada a la funcion de la creacion de usuarios con perfil movil 

            generar_fichero_usuario_perfil_movil $nombre_usu $uid_usuario $contra_cifrada

            #comando para añador el usuario al Openldap
            echo -e "\n"

            ldapadd -x -D cn=admin,dc=cristian,dc=local -W -f crear_usuario.ldif

            #opcional: buscar para ver si se a creado perfectamente

            echo -e "\n"

            ldapsearch -xLLL -b "dc=cristian,dc=local" uidNumber=$uid_usuario
            

        
            ;;

        
        -g)
            
            echo -e "\n"

            echo "has seleccionado la opcion -g, vas a crear un grupo para Openldap."

            echo -e "\n"

            #solicitamos la informacion para generar el grupo 

            read -p "dame el nombre del grupo:" nombre_grupo

            read -p "dame el numero identificador(gidNumber):" gid_grupo

            # llamamos a la funcion y creamos el grupo

            generar_fichero_grupo $nombre_grupo $gid_grupo

            #comando para añadir el grupo a Openldap

            ldapadd -x -D "cn=admin,dc=cristian,dc=local" -W -f crear_grupo.ldif

            #comprobar con el ldapsearch si se ha crado el grupo o no

            ldapsearch -xLLL -b "dc=cristian,dc=local" gidNumber=$gid_grupo
            
            ;;
    

        *)
            echo "introduce una opcion valida puede que te falte el - o esa opcion no se encuentra en este caso en las opciones."
            ;;
    esac


else

    echo "se debe de ejecutar el script con sudo."

fi