import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Screens/second.dart';
import 'package:flutter_application_1/WebRTC/signaling.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
part 'web_rtc_bloc_state.dart';

class WebRtcBlocCubit extends Cubit<WebRtcBlocState> {
  WebRtcBlocCubit() : super(WebRtcBlocInitial());
  Signaling signaling = Signaling();
  final localRenderer = RTCVideoRenderer();
  final remoteRenderer = RTCVideoRenderer();
  bool checkroom = false;

  void goAsAdminRoom({required BuildContext context}) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (builder) => SecondPage(
              admin: true,
            )));
    emit(WebRtcBloc_CreateRoom());
  }

  void goAsUserRoom({required BuildContext context}) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (builder) => SecondPage(
              admin: false,
            )));

    emit(WebRtcBloc_GoAsUserRoom());
  }

  void intializeRoom() {
    localRenderer.initialize();
    remoteRenderer.initialize();
    signaling.onAddRemoteStream = ((stream) {
      remoteRenderer.srcObject = stream;
    });
    signaling.openUserMedia(localRenderer, remoteRenderer);
    Timer(Duration(seconds: 1), () {
      emit(WebRtcBloc_IntializeRoom());
    });
  }

  void createroom({required BuildContext context}) async {
    await signaling.createRoom(remoteRenderer, context);
    changebool();
    emit(WebRtcBloc_CreateRoom());
  }

  void joinroom() async {
    await signaling.joinRoom('1', remoteRenderer, '2');
    emit(WebRtcBloc_JoinRoom());
  }

  void hagup() async {
    await signaling.hangUpall(localRenderer, '1');
    emit(WebRtcBloc_HangUpall());
  }

  void checkroomSize() {
    if (checkroom) {
      Timer(const Duration(seconds: 1), () {
        FirebaseFirestore.instance
            .collection('rooms')
            .snapshots()
            .listen((event) {
          int len = event.docs.length;
          print('length of room is : $len');
          if (len == 0) {
            emit(WebRtcBloc_RoomIsEmpty());
          }
        });
      });
    }
  }

  void changebool() {
    checkroom = !checkroom;
    emit(WebRtcBloc_ChangeBool());
  }
}
