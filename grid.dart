import 'dart:typed_data';

class Grid {
  factory Grid(
    int bitsPerCell,
    int width,
    int height
  ) {
    assert(bitsPerCell <= 8);
    final int cellsPerWord = (8 / bitsPerCell).floor();
    final Uint8List grid = Uint8List((width * height / cellsPerWord).ceil());
    return Grid._(bitsPerCell, cellsPerWord, (1 << bitsPerCell) - 1, width, height, grid);
  }

  Grid._(this._bitsPerCell, this._cellsPerWord, this._mask, this.width, this.height, this._data);
  
  final int _bitsPerCell;
  final int _cellsPerWord;
  final int _mask;
  final int width;
  final int height;
  final Uint8List _data;

  void poke(int x, int y, int value) {
    if (x < 0 || x >= width || y < 0 || y >= height) {
      throw StateError('Tried to read invalid coordinate $x,$y (dimensions are ${width}x$height)');
    }
    assert(value >= 0);
    assert(value < 1 << _bitsPerCell);
    final int index = y * width + x;
    final int cell = index ~/ _cellsPerWord;
    final int subcell = index % _cellsPerWord;
    final int others = _data[cell] & ~(_mask << (subcell * _bitsPerCell));
    _data[cell] = others | (value << (subcell * _bitsPerCell));
  }

  int peek(int x, int y) {
    if (x < 0 || x >= width || y < 0 || y >= height) {
      throw StateError('Tried to read invalid coordinate $x,$y (dimensions are ${width}x$height)');
    }
    final int index = y * width + x;
    final int cell = index ~/ _cellsPerWord;
    final int subcell = index % _cellsPerWord;
    return (_data[cell] >> (subcell * _bitsPerCell)) & _mask;
  }
}

void main() {
  final Grid grid = Grid(2, 8, 8);
  grid.poke(5, 3, 0x01);
  grid.poke(6, 3, 0x02);
  grid.poke(7, 3, 0x03);
  print(grid.peek(7, 3));
}
    
