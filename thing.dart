abstract class Thing {
  String toChar();
  String toString() => "(${toChar()})";
}

class Nothing extends Thing {
  String toChar() => " ";
}

class Clay extends Thing {
  String toChar() => "#";
}

// Infinite spring at 500-minX, 0.
class Water extends Thing {
  String toChar() => "~";
}