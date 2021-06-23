import 'package:flutter/material.dart';
import 'dart:async';

class AutoTimer {
  var _timer;

  void startTimer(BuildContext context) {
    const TIMEOUT = Duration(minutes: 5);
    const MS = Duration(milliseconds: 1);

    Timer startTimeout([int? milliseconds]) {
      var duration = milliseconds == null ? TIMEOUT : MS * milliseconds;
      return new Timer(duration, () {
        handleTimeout(context);
      });
    }

    _timer = startTimeout();
  }

  void stopTimer() {
    try {
      if (_timer.isActive) {
        _timer.cancel();
        _timer = null;
      }
    } catch (e) {
      print(e);
    }
  }

  void handleTimeout(BuildContext context) {
    Navigator.popUntil(context, (Route<dynamic> route) => route.isFirst);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('You have been logged out!'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('confirm'),
            ),
          ],
        );
      },
    );
  }
}

AutoTimer __timer = AutoTimer();

AutoTimer getTimerRef() {
  return __timer;
}
