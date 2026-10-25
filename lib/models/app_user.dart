class AppUser {
  const AppUser({
    required this.uid,
    required this.nombre,
    required this.apellidos,
    required this.email,
    required this.role,
    required this.status,
  });

  final String uid;
  final String nombre;
  final String apellidos;
  final String email;
  final String role;
  final String status;

  String get fullName => '$nombre $apellidos'.trim();

  factory AppUser.fromMap(String uid, Map<String, dynamic> data) => AppUser(
    uid: uid,
    nombre: data['nombre'] as String? ?? '',
    apellidos: data['apellidos'] as String? ?? '',
    email: data['email'] as String? ?? '',
    role: data['role'] as String? ?? 'user',
    status: data['status'] as String? ?? 'active',
  );

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'nombre': nombre,
    'apellidos': apellidos,
    'email': email,
    'role': role,
    'status': status,
  };
}
