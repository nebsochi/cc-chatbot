
class CeeCee {
  final List actions;
  final String text;


  CeeCee({required this.actions, required this.text,});

  factory CeeCee.fromJson(Map<dynamic, dynamic> json) {
    return CeeCee(
      actions: json['message'],
      text: json['message']['payload']['interactive']['body']['text'],
    );
  }
}