import 'thing.dart';
import 'dart:io';
import 'terminal.dart';
import 'dart:math' as math show Random, max;

class World {
  int countWaters() {
    throw UnimplementedError();
  }
  World(this.grid, this.width);
  final List<Thing> grid;
  static final math.Random random = math.Random(0);
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
        if(parts[0] == "x") {
          xR = range;
        } else {
          yR = range;
        }
      }
      if (maxX < xR.max) {
        maxX = xR.max;
      }
      if (maxY < yR.max) {
        maxY = yR.max;
      }
      if(minX == null || minX > xR.min) {
        minX = xR.min;
      }
      if(minY == null || minY > yR.min) {
        minY = yR.min;
      }
      parsedVeins.add([xR, yR]);
    }
    List<Thing> grid = List.filled(((maxX - minX)+1) * ((maxY - minY)+1), Nothing());
    int width = 0;
    for (List<Range> vein in parsedVeins) {
      Range xR = vein[0];
      Range yR = vein[1];
      for(int x = xR.min - minX; x <= xR.max - minX; x++) {
        for(int y = yR.min - minY; y <= yR.max - minY; y++) {
          width = math.max(x, width);
          grid[(y*(maxX - minX))+x] = Clay();
        }
      }
    }
    log(width);
    return World(grid, width);
  }
  final int width;
  int get height => grid.length ~/ width;
  String toString() {
    StringBuffer buf = StringBuffer();
    int index = 0;
    for (int y = 0; y < height; y += 1) {
      for (int x = 0; x < width; x += 1) {
        buf.write(grid[index].toChar());
        index += 1;
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