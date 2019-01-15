import 'dart:io';
import 'dart:typed_data';
import 'state.dart';

class CPU {

  State state = new State();

  void unimplementedInstruction() {
    print("Error: Unimplemented instruction");
    exit(1);
  }

  int emulate8080Op() {
    int opcode = state.memory[state.pc];

    switch(opcode) {
      case 0x00: break;
      case 0x01:
        state.c = state.memory[state.pc+1];
        state.b = state.memory[state.pc+2];
        state.pc += 2;
        break;
      case 0x02: unimplementedInstruction(); break;
      case 0x03: unimplementedInstruction(); break;
      case 0x04: unimplementedInstruction(); break;
      case 0x05: unimplementedInstruction(); break;
      case 0x06: unimplementedInstruction(); break;
      case 0x07: unimplementedInstruction(); break;
      case 0x08: unimplementedInstruction(); break;
      case 0x09: unimplementedInstruction(); break;
      case 0x0a: unimplementedInstruction(); break;
      case 0x0b: unimplementedInstruction(); break;
      case 0x0c: unimplementedInstruction(); break;
      case 0x0d: unimplementedInstruction(); break;
      case 0x0e: unimplementedInstruction(); break;
      case 0x0f: unimplementedInstruction(); break;
      /* */
      case 0x80: //ADD B
        int answer = state.a + state.b;
        state.cc.z = ((answer & 0xff) == 0) ? 1 : 0;
        state.cc.s = ((answer & 0x80) != 0) ? 1 : 0;
        state.cc.cy = (answer > 0xff) ? 1 : 0;
        state.cc.p = parity(answer & 0xff,8);
        state.a = answer & 0xff;
        break;
      case 0x81: //ADD C
        int answer = state.a + state.c;
        state.cc.z = ((answer & 0xff) == 0) ? 1 : 0;
        state.cc.s = ((answer & 0x80) != 0) ? 1 : 0;
        state.cc.cy = (answer > 0xff) ? 1 : 0;
        state.cc.p = parity(answer & 0xff,8);
        state.a = answer & 0xff;
        break;
      case 0xC6: //ADI byte
        int answer = state.a + state.memory[state.pc+1];
        state.cc.z = ((answer & 0xff) == 0) ? 1 : 0;
        state.cc.s = ((answer & 0x80) != 0) ? 1 : 0;
        state.cc.cy = (answer > 0xff) ? 1 : 0;
        state.cc.p = parity(answer & 0xff,8);
        state.a = answer & 0xff;
        break;
      case 0x86: //ADD M
        int offset = (state.h<<8) | (state.l);
        int answer = state.a + state.memory[offset];
        state.cc.z = ((answer & 0xff) == 0) ? 1 : 0;
        state.cc.s = ((answer & 0x80) != 0) ? 1 : 0;
        state.cc.cy = (answer > 0xff) ? 1 : 0;
        state.cc.p = parity(answer & 0xff,8);
        state.a = answer & 0xff;
        break;
    }

    state.pc += 1;
  }

  void run() {

  }

  void loadROM() {

  }

}