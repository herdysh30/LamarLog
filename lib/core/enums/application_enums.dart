/// Active pipeline stages vs. terminal outcomes as defined in PRD v2.0.0.
enum ApplicationStatus {
  // Active stages (Kanban columns)
  wishlist('Wishlist', isTerminal: false),
  applied('Applied', isTerminal: false),
  screening('Screening', isTerminal: false),
  interview('Interview', isTerminal: false),
  offering('Offering', isTerminal: false),

  // Terminal outcomes (Archive / Completed tab)
  offerAccepted('Offer Accepted', isTerminal: true),
  offerDeclined('Offer Declined', isTerminal: true),
  rejected('Rejected', isTerminal: true),
  withdrawn('Withdrawn', isTerminal: true),
  noResponse('No Response', isTerminal: true);

  const ApplicationStatus(this.label, {required this.isTerminal});

  final String label;
  final bool isTerminal;

  static List<ApplicationStatus> get activeStages =>
      values.where((s) => !s.isTerminal).toList();

  static List<ApplicationStatus> get terminalOutcomes =>
      values.where((s) => s.isTerminal).toList();
}

enum WorkplaceType {
  remote('Remote'),
  hybrid('Hybrid'),
  onsite('Onsite');

  const WorkplaceType(this.label);
  final String label;
}

enum JobType {
  fullTime('Full-time'),
  contract('Contract'),
  partTime('Part-time'),
  freelance('Freelance');

  const JobType(this.label);
  final String label;
}

enum PriorityLevel {
  high('High'),
  medium('Medium'),
  low('Low');

  const PriorityLevel(this.label);
  final String label;
}

enum SalaryPeriod {
  monthly('/mo'),
  yearly('/yr');

  const SalaryPeriod(this.shortLabel);
  final String shortLabel;
}
