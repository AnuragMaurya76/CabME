class PlacePrediction{
  String placeAddress='';
  String magicKey = '';
  PlacePrediction({required this.placeAddress,required this.magicKey});
  PlacePrediction.fromjson(Map<String, dynamic> json){
    placeAddress = json["text"];
    magicKey = json["magicKey"];
  }
}