part of 'web_rtc_bloc_cubit.dart';

@immutable
abstract class WebRtcBlocState {}

class WebRtcBlocInitial extends WebRtcBlocState {}

class WebRtcBloc_CreateRoom extends WebRtcBlocState {}

class WebRtcBloc_JoinRoom extends WebRtcBlocState {}

class WebRtcBloc_HangUpall extends WebRtcBlocState {}

class WebRtcBloc_GoAsAdminRoom extends WebRtcBlocState {}

class WebRtcBloc_GoAsUserRoom extends WebRtcBlocState {}

class WebRtcBloc_IntializeRoom extends WebRtcBlocState {}

class WebRtcBloc_RoomIsEmpty extends WebRtcBlocState {}

class WebRtcBloc_RoomIsFull extends WebRtcBlocState {}

class WebRtcBloc_ChangeBool extends WebRtcBlocState {}
