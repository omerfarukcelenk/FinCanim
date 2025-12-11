abstract class DetailEvent {
  const DetailEvent();
}

class DetailLoadEvent extends DetailEvent {
  final int index;
  const DetailLoadEvent({required this.index});
}

class DetailSaveEvent extends DetailEvent {
  const DetailSaveEvent();
}

class DetailShareEvent extends DetailEvent {
  const DetailShareEvent();
}
