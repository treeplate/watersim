import 'dart:io';
import 'dart:math' as math show max, Random;

import 'grid.dart';
import 'terminal.dart';
import 'thing.dart';

class World {
  World(this.grid, this.springX);

  final Grid grid;
  final int springX;

  static const int bitsPerCell = 2;
  static const int kAir = 0x00;
  static const int kClay = 0x01;
  static const int kWaterA = 0x02;
  static const int kWaterB = 0x03;
  static math.Random random = math.Random(0);
  static const List<String> kChars = <String>['.', '#', '~', '~'];

  factory World.parse() {
    List<String> clayVeins = File('world.clay').readAsStringSync().split('\n');
    int maxX = 0;
    int maxY = 0;
    int minX;
    int minY;
    List<List<Range>> parsedVeins = [];
    for (String clayVein in clayVeins) {
      List<String> coords = clayVein.split(', ');
      Range xR;
      Range yR;
      for (String coord in coords) {
        List<String> parts = coord.split('=');
        List<String> minMax = parts[1].split('..');
        Range range = Range(int.parse(minMax.first), int.parse(minMax.last));
        if (parts[0] == "x") {
          xR = range;
        } else {
          yR = range;
        }
      }
      if (maxX <= xR.max) {
        maxX = xR.max + 1;
      }
      if (maxY < yR.max) {
        maxY = yR.max;
      }
      if (minX == null || minX >= xR.min) {
        minX = xR.min - 1;
      }
      if (minY == null || minY > yR.min) {
        minY = yR.min;
      }
      parsedVeins.add([xR, yR]);
    }
    Grid grid = Grid(bitsPerCell, maxX - minX + 1, maxY - minY + 1);
    for (List<Range> vein in parsedVeins) {
      Range xR = vein[0];
      Range yR = vein[1];
      for (int x = xR.min - minX; x <= xR.max - minX; x += 1) {
        for (int y = yR.min - minY; y <= yR.max - minY; y += 1) {
          grid.poke(x, y, kClay);
        }
      }
    }
    return World(grid, 500-minX);
  }
  
  int tickCount = 0;

  void tick() {
    int oldWater = tickCount % 2 == 0 ? kWaterA : kWaterB;
    int newWater = tickCount % 2 == 0 ? kWaterB : kWaterA;
    for (int y = 0; y < grid.height; y += 1) {
      for (int x = 0; x < grid.width; x += 1) {
        if (grid.peek(x, y) == oldWater) {
          _processWater(x, y, oldWater, newWater);
        }
      }
    }
    log("");
    grid.poke(springX, 0, newWater);
    tickCount += 1;
  }

  int countWater() {
    int c = 0;
    for (int y = 0; y < grid.height; y += 1) {
      for (int x = 0; x < grid.width; x += 1) {
        if (grid.peek(x, y) == kWaterA || grid.peek(x, y) == kWaterB) {
          c++;
        }
      }
    }
    return c;
  }

  void _processWater(int x, int y, int oldWater, int newWater, [String logPrefix = '']) {
    log("${logPrefix}processing $x $y...");
    grid.poke(x, y, newWater);
    if (_moveWater(x, y, x, y+1, oldWater, newWater, '$logPrefix ')) {
      log("${logPrefix}DOWN works for $x $y");
      return;
    }
    if (_moveWater(x, y, x-1, y, oldWater, newWater, '$logPrefix ') && random.nextBool()) {
      log("${logPrefix}LEFT works for $x $y");
      return;
    }
    if (_moveWater(x, y, x+1, y, oldWater, newWater, '$logPrefix ')) {
      log("${logPrefix}RIGHT works for $x $y");
      return;
    }
    if (_moveWater(x, y, x-1, y, oldWater, newWater, '$logPrefix ')) {
      log("${logPrefix}LEFT works for $x $y");
      return;
    }
    log('${logPrefix}gave up');
    grid.poke(x, y, newWater);
  }

  bool _moveWater(int fromX, int fromY, int toX, int toY, int oldWater, int newWater, [String logPrefix = '']) {
    log("${logPrefix}testing $fromX $fromY > $toX $toY");
    if (toX < 0 || toY < 0 || toX >= grid.width || toY >= grid.height) {
      log('${logPrefix}hit boundary');
      grid.poke(fromX, fromY, kAir);
      return true;
    }
    if (grid.peek(toX, toY) == oldWater) {
      log('${logPrefix}recursing...');
      _processWater(toX, toY, oldWater, newWater, '$logPrefix ');
    }
    if (grid.peek(toX, toY) == kAir) {
      log('${logPrefix}moving...');
      grid.poke(fromX, fromY, kAir);
      grid.poke(toX, toY, newWater);
      return true;
    }
    log('${logPrefix}can\'t go from $fromX,$fromY to $toX,$toY');
    return false;
  }

  String toString() {
    StringBuffer buf = StringBuffer();
    for (int y = 0; y < grid.height; y += 1) {
      for (int x = 0; x < grid.width; x += 1) {
        buf.write(kChars[grid.peek(x, y)]);
      }
      buf.write('\n');
    }
    return buf.toString();
  }
}

class Range {
  Range(this.min, this.max);
  final int min;
  final int max;
}