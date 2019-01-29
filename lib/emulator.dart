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

  double lastTimer;
  double nextInterrupt;
  int whichInterrupt;

  int shift0; //LSB of Space Invader's external shift hardware
  int shift1; //MSB
  int shiftOffset; //offset for external shift hardware

  void _initStateMemory() {
    state.memory = new Uint8List(0x10000);
    state.cc = new ConditionCodes();
    state.a = state.b = state.c = state.d = state.e = state.h = state.l = state.pc = state.sp = state.intEnable = 0;
  }

  //TODO: Generalize to any rom
  void _initCPU() async {
    _initStateMemory();
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
        _machineOUT(port,state.a);
        state.pc++;
      } else {
        done = _cpu.emulate8080Op();
      }
    }
  }

  int _machineIN(int port) {
    int a;
    switch(port) {
      case 1:
        return 1;
      case 3:
        int v = (shift1 << 8) | shift0;
        a = ((v >> (8-shiftOffset)) & 0xff);
        break;
    }
    return a;
  }

  void _machineOUT(int port, int value) {
    switch(port) {
      case 2:
        shiftOffset = value & 0x7;
        break;
      case 4:
        shift0 = shift1;
        shift1 = value;
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
