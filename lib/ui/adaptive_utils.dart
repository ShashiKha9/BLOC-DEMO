import 'package:flutter/material.dart';

bool isMobile(BoxConstraints box) {
  return box.maxWidth < 600;
}

bool isCompact(BoxConstraints box) {
  return box.maxWidth >= 600 && box.maxWidth < 1000;
}

bool isFull(BoxConstraints box) {
  return box.maxWidth >= 1000;
}
