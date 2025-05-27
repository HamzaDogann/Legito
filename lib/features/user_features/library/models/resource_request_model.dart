class ResourceRequestModel {
  final String name;
  final String? author; // API'niz string? kabul ediyorsa
  final int type; // ApiResourceType enum'ının index'i
  final int status; // ApiSourceStatus enum'ının index'i

  ResourceRequestModel({
    required this.name,
    this.author,
    required this.type,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'author':
          author, // null ise JSON'a eklenmeyecek veya null olarak gidecek (API'ye bağlı)
      'type': type,
      'status': status,
    };
  }
}
