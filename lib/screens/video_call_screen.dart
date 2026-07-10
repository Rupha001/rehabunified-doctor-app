import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../providers/webrtc_provider.dart';

class VideoCallScreen extends StatefulWidget {
  final String patientName;
  final String patientId;

  const VideoCallScreen({
    super.key,
    required this.patientName,
    required this.patientId,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final _webrtc = WebRTCProvider();
  bool _isStarting = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initCall();
  }

  Future<void> _initCall() async {
    try {
      await _webrtc.initialize();
      await _webrtc.startCall();
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Could not start call: $e');
      }
    } finally {
      if (mounted) setState(() => _isStarting = false);
    }
  }

  Future<void> _endCall() async {
    await _webrtc.endCall();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _webrtc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Remote video (full screen background)
            if (_webrtc.isInitialized)
              Positioned.fill(
                child: RTCVideoView(
                  _webrtc.remoteRenderer,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  placeholderBuilder: (context) => const _RemotePlaceholder(),
                ),
              )
            else
              const Positioned.fill(child: _RemotePlaceholder()),

            // Error overlay
            if (_errorMessage != null)
              Positioned.fill(
                child: Container(
                  color: Colors.black87,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Go Back'),
                      ),
                    ],
                  ),
                ),
              ),

            // Starting indicator
            if (_isStarting && _errorMessage == null)
              Positioned.fill(
                child: Container(
                  color: Colors.black87,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: Colors.white),
                      const SizedBox(height: 16),
                      Text(
                        'Connecting to ${widget.patientName}...',
                        style: const TextStyle(color: Colors.white,
                            fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),

            // Top bar — patient name
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black87, Colors.transparent],
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.medical_services_outlined,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.patientName,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                          Text(
                            widget.patientId,
                            style: TextStyle(
                                color: Colors.white.withAlpha(180),
                                fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    if (_webrtc.isCallActive)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withAlpha(200),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.circle,
                                color: Colors.white, size: 8),
                            SizedBox(width: 4),
                            Text('Live',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Local video (picture-in-picture)
            if (_webrtc.isInitialized)
              Positioned(
                top: 80,
                right: 16,
                width: 100,
                height: 140,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: RTCVideoView(
                      _webrtc.localRenderer,
                      mirror: true,
                      objectFit:
                          RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    ),
                  ),
                ),
              ),

            // Bottom controls
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black87, Colors.transparent],
                  ),
                ),
                child: AnimatedBuilder(
                  animation: _webrtc,
                  builder: (context, _) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _CallControlButton(
                        icon: _webrtc.micEnabled
                            ? Icons.mic
                            : Icons.mic_off,
                        label: _webrtc.micEnabled ? 'Mute' : 'Unmute',
                        backgroundColor: _webrtc.micEnabled
                            ? Colors.white24
                            : Colors.red.withAlpha(180),
                        onPressed: _webrtc.isCallActive
                            ? () async {
                                await _webrtc.toggleMic();
                                setState(() {});
                              }
                            : null,
                      ),
                      // End call button
                      _CallControlButton(
                        icon: Icons.call_end,
                        label: 'End',
                        backgroundColor: Colors.red,
                        iconSize: 32,
                        buttonSize: 68,
                        onPressed: _endCall,
                      ),
                      _CallControlButton(
                        icon: _webrtc.cameraEnabled
                            ? Icons.videocam
                            : Icons.videocam_off,
                        label: _webrtc.cameraEnabled ? 'Camera' : 'Cam Off',
                        backgroundColor: _webrtc.cameraEnabled
                            ? Colors.white24
                            : Colors.red.withAlpha(180),
                        onPressed: _webrtc.isCallActive
                            ? () async {
                                await _webrtc.toggleCamera();
                                setState(() {});
                              }
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RemotePlaceholder extends StatelessWidget {
  const _RemotePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1A1A2E),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(
            radius: 48,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, size: 56, color: Colors.white54),
          ),
          const SizedBox(height: 16),
          Text(
            'Waiting for patient...',
            style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Share the room link with the patient\nto join the call',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withAlpha(100), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _CallControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final VoidCallback? onPressed;
  final double iconSize;
  final double buttonSize;

  const _CallControlButton({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.onPressed,
    this.iconSize = 24,
    this.buttonSize = 56,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              color: onPressed == null
                  ? Colors.white12
                  : backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon,
                color: onPressed == null
                    ? Colors.white38
                    : Colors.white,
                size: iconSize),
          ),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: TextStyle(
                color: Colors.white.withAlpha(180),
                fontSize: 11)),
      ],
    );
  }
}
