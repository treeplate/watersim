import 'world.dart';
import 'terminal.dart';

void main() async {
  clearLog();
	World world = World.parse();
  Screen screen = Screen();
  log(world);
  try {
    while (true) {
      // ParallelFrame, BracketFrame, Column, Row, Header, 
      // Label, BigLabel, HorizontalLine, VerticalLine,
      // ProgressBar, Padding, Fill, Gauge, Text, Box
      DateTime time = DateTime.now().toUtc().subtract(const Duration(hours: 7));
      world.tick();
      /*screen.updateWidgets(
        BracketFrame(
          top: Header(
            text: "${world.countWater()}",
            foreground: Color.black,
            background: Color.yellow,
          ),
          side: Column(
            children: <Height<Widget>>[
              Height.fill(Fill(color: Color.yellow)),
            ],
          ),
          bottom: Label.strip(
            texts: <String>[
              '${time.hour.toString().padLeft(2, "0")}:${time.minute.toString().padLeft(2, "0")}:${time.second.toString().padLeft(2, "0")}'
            ],
            textAlign: TextAlign.right,
            padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
            foreground: Color.black,
            background: Color.yellow,
          ),
          body: Column(
            children: <Height<Widget>>[
              Height.fill(
                Text(
                  text: '$world',
                  textAlign: TextAlign.center,
                  foreground: Color.white,
                  background: Color.black,
                ),
              ),
            ],
          ),
        ),
      );*/
      print(world.countWater());
    }
  } catch (e, stack) {
    screen.dispose();
    print('$e\n$stack');
  }
}