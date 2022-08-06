import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/Screens/first.dart';
import 'package:flutter_application_1/cubit/web_rtc_bloc_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class SecondPage extends StatefulWidget {
  bool admin;
  SecondPage({Key? key, required this.admin}) : super(key: key);

  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WebRtcBlocCubit()..intializeRoom(),
      child: BlocConsumer<WebRtcBlocCubit, WebRtcBlocState>(
        listener: (context, state) {
          if (state is WebRtcBloc_RoomIsEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Meeting Ended'),
              duration: Duration(milliseconds: 2000),
            ));
          }
        },
        builder: (context, state) {
          final bloc = context.watch<WebRtcBlocCubit>();
          bloc.checkroomSize();
          return Scaffold(
              appBar: AppBar(
                title: const Text("Welcome to Flutter Explained - WebRTC"),
              ),
              body: Column(
                children: [
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ignore: prefer_const_constructors
                      !widget.admin
                          ? Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  bloc.joinroom();
                                  // bloc.intializeRoom();
                                },
                                child: const Text("Join room"),
                              ),
                            )
                          : Container(),
                      widget.admin
                          ? Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: ElevatedButton(
                                onPressed: !bloc.checkroom
                                    ? () async {
                                        // Add roomId
                                        bloc.createroom(context: context);
                                      }
                                    : null,
                                child: const Text("Create Room"),
                              ),
                            )
                          : Container(),
                      widget.admin
                          ? Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  bloc.hagup();
                                },
                                child: const Text("Hangup"),
                              ),
                            )
                          : Container()
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                              child: RTCVideoView(bloc.localRenderer,
                                  mirror: true)),
                          Expanded(child: RTCVideoView(bloc.remoteRenderer))
                        ],
                      ),
                    ),
                  ),
                ],
              ));
        },
      ),
    );
  }
}
