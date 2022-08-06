import 'package:flutter/material.dart';
import 'package:flutter_application_1/cubit/web_rtc_bloc_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Firstpage extends StatelessWidget {
  const Firstpage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WebRtcBlocCubit(),
      child: BlocConsumer<WebRtcBlocCubit, WebRtcBlocState>(
        listener: (context, state) {},
        builder: (context, state) {
          final bloc = context.watch<WebRtcBlocCubit>();
          return Scaffold(
            appBar: AppBar(
              title: const Text("Welcome to Flutter Explained - WebRTC"),
            ),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        // bloc.intializeRoom();
                        bloc.goAsAdminRoom(context: context);
                      },
                      child: const Text("Create Room"),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        // bloc.intializeRoom();
                        bloc.goAsUserRoom(context: context);
                      },
                      child: const Text("Join Room"),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
