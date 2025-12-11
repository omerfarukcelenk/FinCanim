abstract class HistoryEvent {
  const HistoryEvent();
}

class HistoryLoadEvent extends HistoryEvent {
  const HistoryLoadEvent();
}

class HistoryRefreshEvent extends HistoryEvent {
  const HistoryRefreshEvent();
}

class HistoryDeleteEvent extends HistoryEvent {
  final int index;
  const HistoryDeleteEvent({required this.index});
}
