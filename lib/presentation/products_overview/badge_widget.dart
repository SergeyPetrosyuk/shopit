import 'package:flutter/material.dart';

class BadgeWidget extends StatelessWidget {
  final Widget child;
  final String value;
  final Color? color;

  const BadgeWidget({
    Key? key,
    required this.value,
    this.color,
    required this.child,
  }) : super(key: key);

  Widget build(BuildContext context) => Stack(
        alignment: Alignment.center,
        children: [
          child,
          Positioned(
            top: 8,
            right: 8,
            child: value.isNotEmpty
                ? Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: color == null
                          ? Theme.of(context).primaryColorDark
                          : color,
                    ),
                    constraints: BoxConstraints(
                      minHeight: 18,
                      minWidth: 18,
                    ),
                    child: Text(
                      value,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  )
                : Container(),
          ),
        ],
      );
}
