
import 'package:flutter/material.dart';

class ChatMessage{
  var messageContent;
  String messageType;
  List actions = [];
  
  ChatMessage({required this.messageContent, required this.messageType});
}