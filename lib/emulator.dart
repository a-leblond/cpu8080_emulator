library cpu8080_emulator;
import 'package:flutter/material.dart';

import 'cpu.dart';

class Emulator extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => new _EmulatorState();

}

class _EmulatorState extends State<Emulator> {

  CPU _cpu = new CPU();

  //TODO: Generalize to any rom
  void _initCPU() async {
    _cpu.init8080();

    _cpu.readFileIntoMemoryAt("invaders.h", 0);
    _cpu.readFileIntoMemoryAt("invaders.g", 0x800);
    _cpu.readFileIntoMemoryAt("invaders.f", 0x1000);
    _cpu.readFileIntoMemoryAt("invaders.e", 0x1800);

    _runCPU();
  }

  void _runCPU() {
    int done = 0;
    while(done == 0) {
      done = _cpu.emulate8080Op();
    }
  }

  @override
  void initState() {
    _initCPU();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
   return new Text("HELLO I'M THE EMULATOR");
  }

}
