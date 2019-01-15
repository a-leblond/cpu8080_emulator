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
      case 0x80:
        int answer = state.a + state.b;

        if(answer == 0) {

        }
    }

    state.pc += 1;
  }

  void run() {

  }

  void loadROM() {

  }

}