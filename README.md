# Plantas Medicinales

Aplicación Flutter con Firebase Authentication y Cloud Firestore para consultar
recetas de plantas medicinales y administrar usuarios, categorías y recetas.

## Estructura

```text
lib/
  firebase_options.dart
  main.dart
  models/             modelos Firestore
  screens/
    auth/             inicio de sesión y registro
    user/             inicio, detalle de receta y perfil
    admin/            dashboard, usuarios, categorías y recetas
  services/           acceso a Firebase, PDF y autenticación
  utils/              mensajes de error
  widgets/            componentes reutilizables
functions/
  src/index.ts        callable segura para eliminar cuentas
  scripts/seed-admin.mjs
firestore.rules
storage.rules
```

## Requisitos y configuración

1. Instala Flutter/Dart, Node.js 20, Firebase CLI y FlutterFire CLI.
   Android está configurado para API 24 como mínimo (Android 7.0), compila con
   API 36 y apunta a API 36. Instala Android SDK Platform 36 y Build Tools
   36.0.0 desde Android Studio > SDK Manager.
2. Crea un proyecto Firebase y habilita Authentication (proveedor correo y
   contraseña) y Cloud Firestore. Las imágenes se almacenan comprimidas como
   bytes en el documento de receta, por lo que la aplicación no necesita
   Firebase Storage.
3. Desde la raíz del proyecto, inicia sesión y vincula Firebase:

   ```powershell
   firebase login
   firebase use --add
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

   FlutterFire genera `lib/firebase_options.dart`, que configura las opciones
   para las plataformas seleccionadas. No compartas credenciales de cuentas de
   servicio ni las guardes en el repositorio.
4. Habilita el inicio de sesión con Google:

   - En Firebase Console > Authentication > Sign-in method, habilita Google y
     define el correo de asistencia del proyecto.
   - En Project settings > Your apps, registra el mismo ID de paquete Android
     que aparece en `android/app/build.gradle.kts` (`com.example.plantas`).
     Añade las huellas SHA-1 y SHA-256 de las claves de depuración y publicación.
     En `android`, ejecuta `.\gradlew signingReport` para consultar las huellas
     locales; registra también las de Play App Signing al publicar.
   - En iOS, registra el Bundle ID real en Firebase y agrega el valor
     `REVERSED_CLIENT_ID` de `GoogleService-Info.plist` en Xcode > Runner >
     Info > URL Types.
   - Vuelve a ejecutar `flutterfire configure` para generar la configuración
     de Firebase de cada plataforma. Para web, añade el dominio de la app en
     Authentication > Settings > Authorized domains. El acceso usa Firebase
     Authentication; no incluyas secretos OAuth en la aplicación.

   El primer acceso con Google crea un perfil Firestore con rol `user` y estado
   activo; nunca concede permisos administrativos. En producción registra el
   ID de paquete real y todas las huellas de firma que utilices.
5. Despliega las reglas de acceso y la función de eliminación:

   ```powershell
   firebase deploy --only firestore:rules
   cd functions
   npm install
   npm run deploy
   cd ..
   ```

6. Prepara el administrador inicial con una contraseña privada (mínimo 12
   caracteres). El comando utiliza credenciales ADC con permisos de Firebase
   Admin; nunca se incluye una contraseña en el código:

   ```powershell
   gcloud auth application-default login
   $env:GCLOUD_PROJECT = "ID_DEL_PROYECTO"
   $env:ADMIN_PASSWORD = "TU_CONTRASENA_SEGURA"
   npm --prefix functions run seed:admin
   Remove-Item Env:ADMIN_PASSWORD
   ```

   Esto crea o promueve `admin@plantas.com` y guarda su rol en `users`. No se
   concede el rol admin por comparar el correo en el cliente. Para entornos
   compartidos, limita el uso de la semilla a personal autorizado y rota las
   credenciales según la política de tu organización. También asigna al
   administrador inicial las cuentas antiguas que aún no tengan propietario;
   ejecútalo una vez al actualizar una instalación existente.
7. Ejecuta:

   ```powershell
   flutter pub get
   flutter run
   ```

## Funcionalidad

- Registro de usuario con perfil Firestore `role: user` y `status: active`;
  acceso enrutado por el perfil validado en Firestore.
- Inicio de sesión con Google mediante Firebase Authentication; el perfil nuevo
  se crea con rol `user` y se valida desde Firestore.
- Navegación de usuario con Explorar, Buscar, Favoritos y Perfil. Explorar
  incluye bienvenida, misión/visión/objetivo y acceso a categorías. Buscar
  espera a que el usuario escriba una consulta y presenta los resultados en
  una cuadrícula de dos columnas; el botón de favorito está integrado en cada
  tarjeta. Favoritos explica su propósito y muestra las recetas guardadas en
  dos columnas. Las categorías se muestran en botones de ancho completo y cada
  una abre sus recetas publicadas. El detalle incluye ingredientes,
  preparación, beneficio esperado y descarga de receta en PDF. El perfil de
  usuarios y administradores muestra los datos de la cuenta y permite
  actualizarlos en una pantalla separada.
- Diseño visual con tonos verdes y naturales, tarjetas adaptables y navegación
  coherente. Los favoritos son privados por usuario y se pueden abrir desde la
  sección Favoritos.
- Panel admin con listado de usuarios activos/inactivos, impresión/exportación
  de PDF, alta de cuentas user/admin, activación, desactivación y eliminación
  permanente mediante Cloud Function. Cada cuenta creada queda asignada al
  administrador que la creó; los administradores solo pueden consultar y
  gestionar las cuentas de su propio grupo. Una cuenta administradora creada
  por otro administrador inicia su propio grupo al crear cuentas adicionales.
  Los registros públicos se asignan al administrador principal configurado.
- Gestión en tiempo real de categorías y recetas; los administradores pueden
  publicar o retirar recetas. Las imágenes se comprimen y guardan como datos de
  Firestore (máximo 700 KB por imagen) para no depender de Firebase Storage.
- Firestore solo permite leer recetas publicadas a usuarios normales y protege
  los favoritos en `users/{uid}/favorites/{recipeId}`. Las reglas limitan la
  administración al rol verificado en Firestore. El registro público solo puede
  crear perfiles `user`; los roles no se confían al cliente.

## Pruebas

```powershell
flutter test
flutter analyze
npm install
npm run test:rules
```

Las pruebas de reglas inician el emulador Firestore en el puerto 8080 y
verifican lectura de recetas publicadas, favoritos privados, restricciones de
roles y permisos para administrar categorías y publicación. Antes de desplegar,
asigna `published: true` a las recetas existentes que deban seguir visibles;
las reglas bloquean por defecto documentos antiguos que no tienen ese campo.

Las imágenes nuevas se convierten a JPEG y se guardan como bytes en el mismo
documento Firestore de la receta. Se limita la imagen comprimida a 700 KB para
respetar el máximo de 1 MiB por documento. Firestore tiene cuotas gratuitas,
pero cada descarga de una receta también descarga sus bytes de imagen; controla
el uso y el tamaño de la colección si la aplicación crece. Las reglas de
Firestore también rechazan imágenes superiores a 700 KB. Las recetas antiguas
con `imageUrl` siguen mostrando esa URL.

La información de recetas es educativa y no sustituye una consulta médica.
