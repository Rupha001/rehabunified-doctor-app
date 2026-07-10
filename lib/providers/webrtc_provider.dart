import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class WebRTCProvider extends ChangeNotifier {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;

  final RTCVideoRenderer localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();

  bool _micEnabled = true;
  bool _cameraEnabled = true;
  bool _isCallActive = false;
  bool _isInitialized = false;

  bool get micEnabled => _micEnabled;
  bool get cameraEnabled => _cameraEnabled;
  bool get isCallActive => _isCallActive;
  bool get isInitialized => _isInitialized;

  final Map<String, dynamic> _iceServers = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
    ],
  };

  final Map<String, dynamic> _mediaConstraints = {
    'audio': true,
    'video': {
      'facingMode': 'user',
      'width': {'ideal': 1280},
      'height': {'ideal': 720},
    },
  };

  Future<void> initialize() async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> startCall() async {
    try {
      _localStream = await navigator.mediaDevices.getUserMedia(_mediaConstraints);
      localRenderer.srcObject = _localStream;

      _peerConnection = await createPeerConnection(_iceServers);

      _peerConnection!.onIceCandidate = (candidate) {
        // In a real app, send candidate to signaling server
        debugPrint('ICE Candidate: ${candidate.candidate}');
      };

      _peerConnection!.onTrack = (event) {
        if (event.streams.isNotEmpty) {
          remoteRenderer.srcObject = event.streams[0];
          _remoteStream = event.streams[0];
          notifyListeners();
        }
      };

      _peerConnection!.onConnectionState = (state) {
        debugPrint('Connection state: $state');
        notifyListeners();
      };

      for (final track in _localStream!.getTracks()) {
        await _peerConnection!.addTrack(track, _localStream!);
      }

      // Create offer (in real app, exchange via signaling server)
      final offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);

      _isCallActive = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error starting call: $e');
      rethrow;
    }
  }

  Future<void> toggleMic() async {
    _micEnabled = !_micEnabled;
    final audioTracks = _localStream?.getAudioTracks();
    if (audioTracks != null) {
      for (final track in audioTracks) {
        track.enabled = _micEnabled;
      }
    }
    notifyListeners();
  }

  Future<void> toggleCamera() async {
    _cameraEnabled = !_cameraEnabled;
    final videoTracks = _localStream?.getVideoTracks();
    if (videoTracks != null) {
      for (final track in videoTracks) {
        track.enabled = _cameraEnabled;
      }
    }
    notifyListeners();
  }

  Future<void> endCall() async {
    await _localStream?.dispose();
    await _remoteStream?.dispose();
    await _peerConnection?.close();
    _localStream = null;
    _remoteStream = null;
    _peerConnection = null;
    localRenderer.srcObject = null;
    remoteRenderer.srcObject = null;
    _isCallActive = false;
    _micEnabled = true;
    _cameraEnabled = true;
    notifyListeners();
  }

  @override
  Future<void> dispose() async {
    await endCall();
    await localRenderer.dispose();
    await remoteRenderer.dispose();
    _isInitialized = false;
    super.dispose();
  }
}
