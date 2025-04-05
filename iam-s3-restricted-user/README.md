# AWS IAM & S3 Restricted User Setup

Este laboratorio demuestra cómo crear un usuario IAM con permisos restringidos para servicios AWS, asignarle una política específica, generar claves de acceso y probar sus permisos mediante AWS CLI. Incluye dos métodos: scripts bash y CloudFormation.

## Requisitos previos
- Tener configurado AWS CLI.
- Acceso con permisos suficientes para crear usuarios IAM y administrar políticas.
- Si el usuario no tiene los permisos correctos, es posible que necesites modificar su política de IAM.

## Método 1: Scripts Bash

### Archivos incluidos

#### 1. Script de configuración: `iam-s3-setup.sh`
Este script realiza las siguientes acciones:
- Crea un usuario IAM si no existe.
- Habilita el acceso a la consola con una contraseña segura.
- Adjunta una política IAM especificada al usuario.
- Genera claves de acceso y configura el perfil en AWS CLI.

#### 2. Script de prueba de permisos: `test-user-access.sh`
Este script verifica:
- Si el usuario puede autenticarse con AWS CLI.
- Si tiene acceso a Amazon S3 y EC2.

### Uso del script de configuración
Ejecuta el siguiente comando en tu terminal:
```bash
chmod +x iam-s3-setup.sh
./iam-s3-setup.sh
```
Durante la ejecución, se solicitará:
- Nombre del usuario IAM a crear.
- Nombre de la política a adjuntar.
- Contraseña para acceso a la consola de AWS.

### Uso del script de prueba
Para validar los permisos del usuario IAM creado:
```bash
chmod +x test-user-access.sh
./test-user-access.sh
```
Este script verificará si el usuario puede autenticarse y qué servicios puede acceder.

## Método 2: AWS CloudFormation

### Archivos incluidos

#### 1. Plantilla CloudFormation: `iam-user-template.yaml`

Esta plantilla de CloudFormation te permite crear:
- Un usuario IAM con el nombre especificado
- Acceso a la consola de administración con contraseña
- Asignación de una política AWS gestionada
- Generación de claves de acceso para AWS CLI (No configura el perfil en AWS CLI)
- Configuración para requerir cambio de contraseña en el primer inicio de sesión (opcional)

#### 2. Archivo de parámetros: `params.json`

Archivo JSON con los parámetros para la creación del usuario:
```json
[
    {
        "ParameterKey": "Username",
        "ParameterValue": "usuarioejemplo"
    },
    {
        "ParameterKey": "PolicyName",
        "ParameterValue": "AmazonS3FullAccess"
    },
    {
        "ParameterKey": "UserPassword",
        "ParameterValue": "ContrasenaSegura123!"
    },
    {
        "ParameterKey": "AccountAlias",
        "ParameterValue": "aliasCuenta"
    }
]
```

### Ejecución de la plantilla CloudFormation

Para desplegar la plantilla mediante AWS CLI:

```bash
aws cloudformation deploy \
  --stack-name crear-usuario-iam \
  --template-file iam-user-template.yaml \
  --parameter-overrides file://params.json \
  --capabilities CAPABILITY_NAMED_IAM
```

> **Nota:** El flag `--capabilities CAPABILITY_NAMED_IAM` es necesario porque estamos creando recursos IAM con nombres específicos.

### Parámetros de la plantilla CloudFormation

| Parámetro | Descripción |
|-----------|-------------|
| Username | Nombre del usuario IAM a crear |
| PolicyName | Nombre de la política AWS gestionada (ej. AmazonS3FullAccess) |
| UserPassword | Contraseña para acceso a la consola AWS |
| RequirePasswordReset | Requiere cambio de contraseña en el primer inicio de sesión |
| AccountAlias | Alias de tu cuenta AWS para la URL de inicio de sesión |

### Resultados (Outputs) de CloudFormation

Al finalizar la creación del stack, se mostrarán:
- Nombre del usuario IAM creado
- AccessKeyID para AWS CLI
- SecretAccessKey para AWS CLI
- URL para iniciar sesión en la consola AWS

## Comandos de AWS CLI para probar permisos en S3

Después de ejecutar los scripts o la plantilla CloudFormation, puedes probar los permisos con los siguientes comandos:

1. **Crear un bucket en S3:**
```bash
aws s3 mb s3://<nombre-bucket> --profile <nombre-perfil>
```

2. **Subir un archivo al bucket:**
```bash
aws s3 cp <nombre-archivo> s3://<nombre-bucket>/ --profile <nombre-perfil>
```

3. **Listar contenido del bucket:**
```bash
aws s3 ls s3://<nombre-bucket>/ --profile <nombre-perfil>
```

4. **Eliminar un objeto del bucket:**
```bash
aws s3 rm s3://<nombre-bucket>/<nombre-archivo> --profile <nombre-perfil>
```

5. **Eliminar el bucket:** *(Debe estar vacío antes de eliminarlo)*
```bash
aws s3 rb s3://<nombre-bucket> --profile <nombre-perfil>
```

## Limpieza de recursos

### Limpieza manual con AWS CLI

Para evitar costos innecesarios, asegúrate de eliminar los recursos creados cuando ya no sean necesarios:

1. **Eliminar las claves de acceso del usuario:**
```bash
aws iam delete-access-key --access-key-id <AccessKeyId> --user-name <nombre-usuario>
```

2. **Desasociar la política del usuario:**
```bash
aws iam detach-user-policy --user-name <nombre-usuario> --policy-arn arn:aws:iam::aws:policy/<nombre-politica>
```

3. **Eliminar el perfil de inicio de sesión de usuario IAM:**
```bash
aws iam delete-login-profile --user-name <nombre-usuario>
```

4. **Eliminar el usuario IAM:**
```bash
aws iam delete-user --user-name <nombre-usuario>
```

### Limpieza con CloudFormation

Si utilizaste CloudFormation, puedes eliminar todos los recursos creados eliminando el stack:

```bash
aws cloudformation delete-stack --stack-name crear-usuario-iam
```

Con esto, finaliza el laboratorio y se evita la generación de costos adicionales. 🚀