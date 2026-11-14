class AttachmentFile {
  final String name;
  final String mimeType;
  final String uri;
  final int size;

  const AttachmentFile({
    required this.name,
    required this.mimeType,
    required this.uri,
    required this.size,
  });

  factory AttachmentFile.fromJson(Map<String, dynamic> json) {
    return AttachmentFile(
      name: (json['name'] ?? '').toString(),
      mimeType: (json['mimeType'] ?? 'application/octet-stream').toString(),
      uri: (json['uri'] ?? '').toString(),
      size: (json['size'] is num) ? (json['size'] as num).toInt() : 0,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'mimeType': mimeType,
        'uri': uri,
        'size': size,
      };
}
