class LeaderboardEntry {
  final String name;
  final String email;
  final int reportCount;
  final int connectivityCount;
  final int verificationCount;

  const LeaderboardEntry({
    required this.name,
    required this.email,
    required this.reportCount,
    required this.connectivityCount,
    required this.verificationCount,
  });

  int get points =>
      reportCount * 80 + connectivityCount * 40 + verificationCount * 5;
}