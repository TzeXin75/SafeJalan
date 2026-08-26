class LeaderboardEntry {
  final String name;
  final String email;
  final int reportCount;
  final int verificationCount;

  const LeaderboardEntry({
    required this.name,
    required this.email,
    required this.reportCount,
    required this.verificationCount,
  });

  int get points => reportCount * 80 + verificationCount * 5;
}
