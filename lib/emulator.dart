library cpu8080_emulator;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'state_memory.dart';
import 'cpu.dart';

class Emulator extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => new _EmulatorState();

}

class _EmulatorState extends State<Emulator> {

  StateMemory state = new StateMemory();
  CPU _cpu;

  void _initState() {
    state.memory = new Uint8List(0x10000);
    state.cc = new ConditionCodes();
    state.a = state.b = state.c = state.d = state.e = state.h = state.l = state.pc = state.sp = state.intEnable = 0;
  }

  //TODO: Generalize to any rom
  void _initCPU() async {
    _initState();
    _cpu = new CPU(state);

    await _cpu.readFileIntoMemoryAt("invaders.h", 0);
    await _cpu.readFileIntoMemoryAt("invaders.g", 0x800);
    await _cpu.readFileIntoMemoryAt("invaders.f", 0x1000);
    await _cpu.readFileIntoMemoryAt("invaders.e", 0x1800);

    _runCPU();
  }

  void _runCPU() {
    print("RunCPU");

    int done = 0;

    while(done == 0) {
      int opcode = state.memory[state.pc];

      if(opcode == 0xdb) { //Machine specific handling for IN
        int port = state.memory[state.pc+1];
        state.a = _machineIN(port);
        state.pc++;
      } else if(opcode == 0xd3) { //OUT
        int port = state.memory[state.pc+1];
        _machineOUT(port);
        state.pc++;
      } else {
        done = _cpu.emulate8080Op();
      }
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
