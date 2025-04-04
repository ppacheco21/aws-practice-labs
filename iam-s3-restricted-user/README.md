# AWS IAM & S3 Restricted User Setup

Este laboratorio demuestra cómo crear un usuario IAM con permisos restringidos para Amazon S3, asignarle una política específica, generar claves de acceso y probar sus permisos mediante AWS CLI.

## Archivos incluidos

### 1. Script de configuración: `iam-s3-setup.sh`
Este script realiza las siguientes acciones:
- Crea un usuario IAM si no existe.
- Habilita el acceso a la consola con una contraseña segura.
- Adjunta una política IAM especificada al usuario.
- Genera claves de acceso y configura el perfil en AWS CLI.

### 2. Script de prueba de permisos: `test-user-access.sh`
Este script verifica:
- Si el usuario puede autenticarse con AWS CLI.
- Si tiene acceso a Amazon S3 y EC2.

## Requisitos previos
- Tener configurado AWS CLI.
- Acceso con permisos suficientes para crear usuarios IAM y administrar políticas.
- Si el usuario no tiene los permisos correctos, es posible que necesites modificar su política de IAM.

## Uso del script de configuración
Ejecuta el siguiente comando en tu terminal:
```bash
chmod +x iam-s3-setup.sh
./iam-s3-setup.sh
```
Durante la ejecución, se solicitará:
- Nombre del usuario IAM a crear.
- Nombre de la política a adjuntar.
- Contraseña para acceso a la consola de AWS.

## Uso del script de prueba
Para validar los permisos del usuario IAM creado:
```bash
chmod +x test-user-access.sh
./test-user-access.sh
```
Este script verificará si el usuario puede autenticarse y qué servicios puede acceder.

## Comandos de AWS CLI para probar permisos en S3
Después de ejecutar los scripts, puedes probar los permisos con los siguientes comandos:

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

Con esto, finaliza el laboratorio y se evita la generación de costos adicionales. 🚀

