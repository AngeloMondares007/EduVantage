
import 'package:flutter/material.dart';
import 'package:tech_media/res/color.dart';

class RoundButton extends StatelessWidget {
  final String title;
  final VoidCallback onPress;
  final Color color, textColor;
  final bool loading;
  const RoundButton({Key? key,
    required this.title,
    required this.onPress,
    this.textColor =  AppColors.whiteColor,
    this.color = Colors.green,
    this.loading = false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: loading ? null : onPress,
        child: Container(
          height: 60,
          width: 200,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(15)
          ),
          child: loading ? Center(child: CircularProgressIndicator(color: Colors.white,)) : Center(child: Text(title, style: Theme.of(context).textTheme.displayMedium!.copyWith(fontSize: 20, color: textColor),))
        ),
      ),
    );
  }
}

