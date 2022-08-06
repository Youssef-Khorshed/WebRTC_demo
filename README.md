# What is web RTC?

-> standard for web real-time communication 
-> allows open source real-time communication (video/audio) between apps and browsers

# What is signaling?

-> Signaling is a process used in WebRTC to:
1- detect peers (A, B,..) on different networks
2- exchange session control messages are known as SDP
3- exchange network configurations as ICE candidates; and media capabilities
-> based on JSEP: JavaScript Session Establishment Protocol. JSEP is a collection of interfaces to identify local and remote addresses negotiation.
-> created as A gateway can be a copy/paste (post/get) mechanism or a real-time protocol.

# How is Stun/Turn used for web-rtc?
-> All internet devices require individual(private) IP addresses to connect to the internet and communicate
-> A STUN server will reach out and send various requests to the connected peers and get a public IP address if possible
-> Turn: if the peers do not have available public IP addresses, they can instead send the whole communication stream to the TURN server which will hand that stream to the other peer again.
->  it consumes a lot of bandwidth and requires much more maintenance costs.
