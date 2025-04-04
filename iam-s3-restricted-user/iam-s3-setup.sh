#!/bin/bash

# Habilita la opción de salir si ocurre algún error en el script
set -e
# Establece el manejador de errores que se ejecuta cuando ocurre un error
trap 'error_handler' ERR

echo "Iniciando el script..."

# Función para manejar los errores
error_handler() {
    echo "Ocurrió un error. Revisa los mensajes anteriores."
    exit 1
}

# Función para validar que los inputs no estén vacíos
validate_input() {
    if [[ -z "$1" ]]; then
        echo "Entrada no válida. Inténtelo de nuevo."
        exit 1
    fi
}

# Función para crear el usuario IAM
create_user() {
    echo "Verificando si el usuario $USERNAME existe..."

    # Verifica si el usuario ya existe
    if aws iam get-user --user-name "$USERNAME" &> /dev/null; then
        echo "El usurio '$USERNAME' ya existe."
    else
        # Si no existe, crea el usuario
        echo "El usuario '$USERNAME' no existe. Creando usuario..."    
        aws iam create-user --user-name "$USERNAME"
        echo "Usuario creado exitosamente."
    fi
}

# Función para crear el perfil de acceso a la consola para el usuario
create_access_profile() {
    echo "Verificando acceso a la consola..."

    # Verifica si el usuario tiene un perfil de acceso
    if aws iam get-login-profile --user-name "$USERNAME" &> /dev/null; then
        echo "El usuario '$USERNAME' ya tiene acceso."
    else
        # Si no tiene acceso, pide una contraseña y crea el perfil
        echo "Creando el perfil de acceso para '$USERNAME'..."
        read -sp "Ingresa una contraseña para acceso a la consola (La contraseña debe tener al menos una letra mayúscula, número y un símbolo): " PASSWORD
        echo
        aws iam create-login-profile --user-name "$USERNAME" --password "$PASSWORD" --password-reset-required
        echo "Perfil de acceso creado exitosamente."
    fi
}

# Función para adjuntar políticas al usuario IAM
attach_iam_policies() {
    echo "Verificando si la política '$POLICY_NAME' ya está adjunta al usuario '$USERNAME'..."

    # Verifica si la política ya está adjunta al usuario
    POLICY_ATTACHED=$(aws iam list-attached-user-policies --user-name "$USERNAME" \
        --query "AttachedPolicies[?PolicyName=='$POLICY_NAME']" --output text)

    if [[ -n "$POLICY_ATTACHED" ]]; then
        echo "La política $POLICY_NAME ya está adjunta al usuario '$USERNAME'."
    else
        # Si la política no está adjunta, la asigna
        echo "La política $POLICY_NAME no está adjunta. Procediendo con la asignación..."
        aws iam attach-user-policy --user-name $USERNAME --policy-arn arn:aws:iam::aws:policy/"$POLICY_NAME"
        echo "Política $POLICY_NAME adjuntada exitosamente."
    fi
}

# Función para crear claves de acceso para el usuario
create_access_keys() {
    echo "Creando claves de accesos para la CLI..."

    # Crea las claves de acceso para el usuario
    KEY_INFO=$(aws iam create-access-key --user-name "$USERNAME" --query "AccessKey.[AccessKeyId,SecretAccessKey]" --output text)

    if [[ -z "$KEY_INFO" ]]; then
        echo "Error al crear las claves de acceso."
        exit 1
    fi
    
    # Extrae la clave de acceso y la clave secreta
    ACCESS_KEY_ID=$(echo "$KEY_INFO" | awk '{print $1}')
    SECRET_ACCESS_KEY=$(echo "$KEY_INFO" | awk '{print $2}')

    echo "Access key creada exitosamente!"

    # Guarda las credenciales en un archivo con permisos seguros
    FILENAME="aws_credentials_${USERNAME}_$(date +%Y%m%d%H%M%S).txt"
    {
        echo "AWS Access Key for user: $USERNAME"
        echo "Created on: $(date)"
        echo "Access Key ID: $ACCESS_KEY_ID"
        echo "Secret Access Key: $SECRET_ACCESS_KEY"
        echo ""
    } > "$FILENAME"
    chmod 600 "$FILENAME"  # Establece permisos seguros para el archivo
    echo "Credenciales guardadas en el archivo: $FILENAME"
    echo "Recuerda guardar este archivo en una ubicación segura."
    
    # Configura las claves de acceso en el perfil de AWS CLI
    echo "Configurando las claves de acceso para el usuario '$USERNAME'..."
    aws configure set aws_access_key_id "$ACCESS_KEY_ID" --profile "$USERNAME"
    aws configure set aws_secret_access_key "$SECRET_ACCESS_KEY" --profile "$USERNAME"

    echo "Credenciales configuradas."
}

# Solicita el nombre del usuario IAM y valida la entrada
read -p "Ingrese el nombre del usuario IAM: " USERNAME
validate_input "$USERNAME"

# Solicita el nombre de la política a adjuntar y valida la entrada
read -p "Ingrese el nombre de la política a adjuntar: " POLICY_NAME
validate_input "$POLICY_NAME"

# Ejecuta las funciones definidas anteriormente
create_user
create_access_profile
attach_iam_policies
create_access_keys

echo "Script finalizado!"
