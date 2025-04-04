#!/bin/bash

# Habilita la opción de salir si ocurre algún error en el script
set -e
# Establece el manejador de errores que se ejecuta cuando ocurre un error
trap 'error_handler' ERR

echo "Iniciando el script de pruebas..."

# Función para manejar los errores
error_handler() {
    echo "Ocurrió un error al probar los permisos. Verifica las credenciales y los permisos asignados."
    exit 1
}

# Función para validar que los inputs no estén vacíos
validate_input() {
    if [[ -z "$1" ]]; then
        echo "Entrada no válida. Inténtelo de nuevo."
        exit 1
    fi
}

# Solicita el nombre del usuario IAM a probar y valida la entrada
read -p "Ingrese el nombre del usuario IAM a probar: " USERNAME
validate_input "$USERNAME"

echo "Probando accesos con el usuario '$USERNAME'..."

# Verifica si el perfil configurado en AWS CLI es válido
aws sts get-caller-identity --profile "$USERNAME" > /dev/null 2>&1

# Si la autenticación es exitosa, sigue con las pruebas de acceso
if [[ $? -eq 0 ]]; then
    echo "Autenticación exitosa con AWS CLI para el usuario '$USERNAME'."
else
    echo " Error en la autenticación. Verifica las credenciales."
    echo ""
    exit 1
fi

# Prueba de acceso a Amazon S3
echo "Probando acceso a Amazon S3..."
if aws s3 ls --profile "$USERNAME" > /dev/null 2>&1; then
    echo "El usuario '$USERNAME' tiene acceso a S3."
else
    echo "El usuario '$USERNAME' NO tiene acceso a S3."
fi

# Prueba de acceso a Amazon EC2
echo "Probando acceso a EC2..."
if aws ec2 describe-instances --profile "$USERNAME" > /dev/null 2>&1; then
    echo "El usuario '$USERNAME' tiene acceso a EC2."
else
    echo "El usuario '$USERNAME' NO tiene acceso a EC2."
fi

echo "Prueba de permisos completada!." 
echo ""
echo "Puedes ejecutar otros comandos, como:"
# Proporciona comandos adicionales para probar permisos en AWS
echo "1. Crear un nuevo bucket: aws s3 mb s3://<nombre-bucket> --profile <nombre-perfil>"
echo "2. Subir un archivo (objeto) al bucket: aws s3 cp <nombre-archivo> s3://<nombre-bucket>/ --profile <nombre-perfil>"
echo "3. Listar contenido del bucket: aws s3 ls s3://<nombre-bucket>/ --profile <nombre-perfil>"
