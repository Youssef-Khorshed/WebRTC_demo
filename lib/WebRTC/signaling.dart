import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

typedef void StreamStateCallback(MediaStream stream);

class Signaling {
  Map<String, dynamic> configuration = {
    'iceServers': [
      {
        'urls': [
          'stun:stun1.l.google.com:19302',
          'stun:stun2.l.google.com:19302'
        ]
      }
    ]
  };

  RTCPeerConnection? peerConnection;
  RTCRtpSender? sender;
  MediaStream? localStream;
  MediaStream? remoteStream;
  String? currentRoomText;
  StreamStateCallback? onAddRemoteStream;
  StreamStateCallback? onRemoveRemoteStream;
  Function(MediaStream stream, MediaStreamTrack track)? onAddTrack;
  StreamSubscription<DocumentSnapshot<Object?>>? x;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? y;
  final Map<String, dynamic> mediaConstraints = {
    "audio": false,
    "video": {
      "mandatory": {
        "minWidth": '640', // Provide your own width, height and frame rate here
        "minHeight": '480',
        "minFrameRate": '30',
      },
      "facingMode": "user",
      "optional": [],
    }
  };
  Future<String> createRoom(
      RTCVideoRenderer remoteRenderer, BuildContext context) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentReference roomRef = db.collection('rooms').doc('1');

    print('Create PeerConnection with configuration: $configuration');

    peerConnection = await createPeerConnection(configuration);

    registerPeerConnectionListeners();

    localStream?.getTracks().forEach((track) {
      peerConnection?.addTrack(track, localStream!);
    });
    final sender = await peerConnection?.getSenders();
    sender?.forEach((element) {
      print('sender is -->> ${element.senderId}');
    });
    // Code for collecting ICE candidates below
    var callerCandidatesCollection = roomRef.collection('callerCandidates');

    peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
      print('Got candidate: ${candidate.toMap()}');
      callerCandidatesCollection.add(candidate.toMap());
    };
    // Finish Code for collecting ICE candidate

    // Add code for creating a room
    RTCSessionDescription offer = await peerConnection!.createOffer();
    await peerConnection!.setLocalDescription(offer);
    print('Created offer: $offer');

    Map<String, dynamic> roomWithOffer = {'offer': offer.toMap()};

    await roomRef.set(roomWithOffer);
    var roomId = roomRef.id;
    print('New room created with SDK offer. Room ID: $roomId');
    currentRoomText = 'Current room is $roomId - You are the caller!';
    // Created a Room

    peerConnection?.onTrack = (RTCTrackEvent event) {
      print('Got remote track: ${event.streams[0]}');

      event.streams[0].getTracks().forEach((track) {
        print('Add a track to the remoteStream $track');
        remoteStream?.addTrack(track);
      });
    };

    // Listening for remote session description below

    x = roomRef.snapshots().listen((snapshot) async {
      print('Got updated room: ${snapshot.data()}');
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      if (peerConnection?.getRemoteDescription() != null &&
          data['answer'] != null) {
        var answer = RTCSessionDescription(
          data['answer']['sdp'],
          data['answer']['type'],
        );
        print("Someone tried to connect");
        await peerConnection?.setRemoteDescription(answer);
      }
      // else {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //       SnackBar(content: Text('room $roomId is created successfully')));
      // }
    });
    // Listening for remote session description above

    // Listen for remote Ice candidates below
    y = roomRef.collection('calleeCandidates').snapshots().listen((snapshot) {
      snapshot.docChanges.forEach((change) {
        if (change.type == DocumentChangeType.added) {
          Map<String, dynamic> data = change.doc.data() as Map<String, dynamic>;
          print('Got new remote ICE candidate: ${jsonEncode(data)}');
          peerConnection!.addCandidate(
            RTCIceCandidate(
              data['candidate'],
              data['sdpMid'],
              data['sdpMLineIndex'],
            ),
          );
        } else if (change.type == DocumentChangeType.removed) {}
      });
    });

    return roomId;
  }

  Future<void> joinRoom(
      String roomId, RTCVideoRenderer remoteVideo, String userid) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentReference roomRef = db.collection('rooms').doc('$roomId');
    var roomSnapshot = await roomRef.get();

    if (roomSnapshot.exists) {
      peerConnection = await createPeerConnection(configuration);
      registerPeerConnectionListeners();
      localStream?.getTracks().forEach((track) async {
        print('my track is addded is called ${track.id}');
        sender = await peerConnection?.addTrack(track, localStream!);
      });

      // Code for collecting ICE candidates below
      var calleeCandidatesCollection = roomRef.collection('calleeCandidates');
      peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
        calleeCandidatesCollection.doc(userid).set(candidate.toMap());
      };
      // Code for collecting ICE candidate above

      peerConnection?.onTrack = (RTCTrackEvent event) {
        //    print('Got remote track: ${event.streams[0]}');
        event.streams[0].getTracks().forEach((track) {
          //  print('Add a track to the remoteStream: $track');
          remoteStream?.addTrack(track);
        });
      };

      // Code for creating SDP answer below
      var data = roomSnapshot.data() as Map<String, dynamic>;
      var offer = data['offer'];
      await peerConnection?.setRemoteDescription(
        RTCSessionDescription(offer['sdp'], offer['type']),
      );
      var answer = await peerConnection!.createAnswer();

      await peerConnection!.setLocalDescription(answer);

      Map<String, dynamic> roomWithAnswer = {
        'answer': {'type': answer.type, 'sdp': answer.sdp}
      };

      await roomRef.update(roomWithAnswer);
      // Finished creating SDP answer

      // Listening for remote ICE candidates below
      roomRef.collection('callerCandidates').snapshots().listen((snapshot) {
        snapshot.docChanges.forEach((document) {
          var data = document.doc.data() as Map<String, dynamic>;
          print(data);
          peerConnection!.addCandidate(
            RTCIceCandidate(
              data['candidate'],
              data['sdpMid'],
              data['sdpMLineIndex'],
            ),
          );
        });
      });
    }
  }

  Future<void> openUserMedia(
    RTCVideoRenderer localVideo,
    RTCVideoRenderer remoteVideo,
  ) async {
    MediaStream stream =
        await navigator.mediaDevices.getUserMedia(mediaConstraints);

    localVideo.srcObject = stream;
    localStream = stream;
    remoteVideo.srcObject = await createLocalMediaStream('key');
  }

  Future<void> hangUpall(RTCVideoRenderer localVideo, String roomId) async {
    peerConnection?.removeStream(localStream!);
    peerConnection?.removeStream(remoteStream!);
    var db = FirebaseFirestore.instance;
    var roomRef = db.collection('rooms').doc(roomId);
    x?.cancel();
    y?.cancel();
    var calleeCandidates = await roomRef.collection('calleeCandidates').get();
    calleeCandidates.docs.forEach((document) => document.reference.delete());
    var callerCandidates = await roomRef.collection('callerCandidates').get();
    callerCandidates.docs.forEach((document) => document.reference.delete());
    await roomRef.delete();
    peerConnection!.close();
    localStream!.dispose();
    remoteStream?.dispose();
  }

  void registerPeerConnectionListeners() {
    peerConnection?.onAddStream = (MediaStream stream) {
      onAddRemoteStream?.call(stream);
      remoteStream = stream;
    };
  }
}
