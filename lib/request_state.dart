enum RequestState {
  all,
  open,
  approved,
  flagged,
  declined
}

extension RequestStateExtension on RequestState {
  String toReadable() {
    switch(this) {
      case RequestState.all:
        return 'All';
      case RequestState.open:
        return 'Open';
      case RequestState.approved:
        return 'Approved';
      case RequestState.flagged:
        return 'Flagged';
      case RequestState.declined:
        return 'Declined';
    }
  }
}

List<String> allRequestStateReadableValues() {
  return RequestState.values.map(
    (requestState) => requestState.toReadable()
  ).toList();
}