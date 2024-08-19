class AllPackages {
  final int value;
  final String label;

  AllPackages({required this.value, required this.label});

  // Factory method to create a Package from a JSON object
  factory AllPackages.fromJson(Map<String, dynamic> json) {
    return AllPackages(
      value: json['value'],
      label: json['label'],
    );
  }

  // Method to convert a Package to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'label': label,
    };
  }
}
