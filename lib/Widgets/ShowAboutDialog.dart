import 'package:flutter/material.dart';

class ShowAboutDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.black87,
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              offset: Offset(0.0, 0.5), //(x,y)
              blurRadius: 20.0,
            ),
          ],
        ),
        height: 250,
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'CabMe v1.0.0',
                style: TextStyle(color: Colors.white, fontSize: 30),
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                'Developed by Anurag Maurya',
                style: TextStyle(color: Colors.white),
              ),
              Text(
                'Email: anuragmaurya9345@gmail.com',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
