class ClassMember {
  final String id;
  final String name;
  final String icon;

  const ClassMember({
    required this.id,
    required this.name,
    required this.icon,
  });
}

class RosterMember {
  final String id;
  final String name;
  final bool profile;
  final bool example;

  const RosterMember({
    required this.id,
    required this.name,
    required this.profile,
    required this.example,
  });
}
