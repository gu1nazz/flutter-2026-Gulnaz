sealed class Countdown {
  const Countdown();
}

class Upcoming extends Countdown {
  const Upcoming({required this.remaining});
  final Duration remaining;
}

class Started extends Countdown {
  const Started({required this.elapsed});
  final Duration elapsed;
}

class Ended extends Countdown {
  const Ended();
}
