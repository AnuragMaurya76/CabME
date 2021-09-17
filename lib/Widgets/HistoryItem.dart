import 'package:uber_app/Assistants/MethodAssistant.dart';
import 'package:uber_app/models/History.dart';
import 'package:flutter/material.dart';

class HistoryItem extends StatefulWidget {
  final History history;
  HistoryItem({required this.history});

  @override
  _HistoryItemState createState() => _HistoryItemState();
}

class _HistoryItemState extends State<HistoryItem> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                MethodAssistant.formatTripDate(widget.history.createdAt),
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 10),
              Container(
                child: Row(
                  children: [
                    Image.asset(
                      'images/pickicon.png',
                      height: 16,
                      width: 16,
                    ),
                    SizedBox(
                      width: 18,
                    ),
                    Expanded(
                      child: Container(
                        child: Text(
                          widget.history.pickup,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      "Rs. ${widget.history.fares}",
                      style: TextStyle(
                        fontFamily: 'Brand-Bold',
                        fontSize: 16,
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Image.asset(
                    'images/desticon.png',
                    height: 16,
                    width: 16,
                  ),
                  SizedBox(width: 18),
                  Container(
                      child: Text(
                    widget.history.dropOff,
                    style: TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  )),
                ],
              ),
            ],
            //crossAxisAlignment: CrossAxisAlignment.start,
          )
        ],
      ),
    );
  }
}
