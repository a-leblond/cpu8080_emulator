import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'state.dart';
import 'package:flutter/services.dart' show rootBundle;

class CPU {

  State state = new State();

  void init8080() {
    state.memory = new Uint8List(0x10000);
    state.cc = new ConditionCodes();
    state.a = state.b = state.c = state.d = state.e = state.h = state.l = state.pc = state.sp = state.intEnable = 0;
  }

  int _parity(int x, int size) {
    int i;
    int p = 0;
    x = (x & ((1 << size)-1));
    for(i=0; i<size; i++) {
      if((x & 0x1) != 0)
        p++;
      x = x >> 1;
    }
    return (0 == (p & 0x1)) ? 1 : 0;
  }

  void _logicFlagsA() {
    state.cc.cy = state.cc.ac = 0;
    state.cc.z = (state.a == 0) ? 1 : 0;
    state.cc.s = (0x80 == (state.a & 0x80)) ? 1 : 0;
    state.cc.p = _parity(state.a, 8);
  }

  void _arithFlagsA(int res){
    state.cc.cy = (res > 0xff) ? 1 : 0;
    state.cc.z = ((res&0xff) == 0) ? 1 : 0;
    state.cc.s = (0x80 == (res & 0x80)) ? 1 : 0;
    state.cc.p = _parity(res&0xff, 8);
  }

  void readFileIntoMemoryAt(String filename, int offset) async {
    print("Reading file "+filename);
    ByteData content = await rootBundle.load('assets/rom/'+filename);
    Uint8List bytes = content.buffer.asUint8List();
    print("Bytes length : "+bytes.length.toString());
    for(int i=0; i<bytes.length; i++) {
      state.memory[offset + i] = bytes[i];
    }
  }

  void _unimplementedInstruction() {
    print("Error: Unimplemented instruction");
    exit(1);
  }

  //TODO: INX op will probably need a fix
  int emulate8080Op() {
    int opcode = state.memory[state.pc];
    int currentPc = state.pc;
    print(opcode.toRadixString(16));

    state.pc += 1;

    switch(opcode) {
      case 0x00: break; //NOP
      case 0x01: //LXI B,word
        state.c = state.memory[currentPc+1];
        state.b = state.memory[currentPc+2];
        state.pc += 2;
        break;
      case 0x02: _unimplementedInstruction(); break;
      case 0x03: _unimplementedInstruction(); break;
      case 0x04: _unimplementedInstruction(); break;
      case 0x05: //DCR B
        int res = state.b - 1;
        state.cc.z = (res == 0) ? 1 : 0;
        state.cc.s = (0x80 == (res & 0x80)) ? 1 : 0;
        state.cc.p = _parity(res, 8);
        state.b = res;
        break;
      case 0x06: //MVI B,byte
        state.b = state.memory[currentPc+1];
        state.pc++;
        break;
      case 0x07: _unimplementedInstruction(); break;
      case 0x08: _unimplementedInstruction(); break;
      case 0x09: //DAD B
        int hl = (state.h << 8) | state.l;
        int bc = (state.b << 8) | state.c;
        int res = hl + bc;
        state.h = (res & 0xff00) >> 8;
        state.l = res & 0xff;
        state.cc.cy = ((res & 0xffff0000) > 0) ? 1 : 0;
        break;
      case 0x0a: _unimplementedInstruction(); break;
      case 0x0b: _unimplementedInstruction(); break;
      case 0x0c: _unimplementedInstruction(); break;
      case 0x0d: //DCR C
        int res = state.c - 1;
        state.cc.z = (res == 0) ? 1 : 0;
        state.cc.s = (0x80 == (res & 0x80)) ? 1 : 0;
        state.cc.p = _parity(res, 8);
        state.c = res;
        break;
      case 0x0e: //MVI C,byte
        state.c = state.memory[currentPc+1];
        state.pc++;
        break;
      case 0x0f: //RRC
        int x = state.a;
        state.a = ((x & 1) << 7) | (x >> 1);
        state.cc.cy = (1 == (x & 1)) ? 1 : 0;
        break;
      case 0x10: _unimplementedInstruction(); break;
      case 0x11: //LXI D,word
        state.e = state.memory[currentPc+1];
        state.d = state.memory[currentPc+2];
        state.pc += 2;
        break;
      case 0x12: _unimplementedInstruction(); break;
      case 0x13: //INX D
        state.e++;
        if(state.e == 0) {
          state.d++;
        }
        break;
      case 0x14: _unimplementedInstruction(); break;
      case 0x15: _unimplementedInstruction(); break;
      case 0x16: _unimplementedInstruction(); break;
      case 0x17: _unimplementedInstruction(); break;
      case 0x18: _unimplementedInstruction(); break;
      case 0x19: //DAD D
        int hl = (state.h << 8) | state.l;
        int de = (state.d << 8) | state.e;
        int res = hl + de;
        state.h = (res & 0xff00) >> 8;
        state.l = res & 0xff;
        state.cc.cy = ((res & 0xffff0000) != 0) ? 1 : 0;
        break;
      case 0x1a: //LDAX D
        int offset = (state.d << 8) | state.e;
        state.a = state.memory[offset];
        break;
      case 0x1b: _unimplementedInstruction(); break;
      case 0x1c: _unimplementedInstruction(); break;
      case 0x1d: _unimplementedInstruction(); break;
      case 0x1e: _unimplementedInstruction(); break;
      case 0x1f: //RAR
        int x = state.a;
        state.a = (state.cc.cy << 7) | (x >> 1);
        state.cc.cy = (1 == (x & 1)) ? 1 : 0;
        break;
      case 0x20: _unimplementedInstruction(); break;
      case 0x21: //LXI H,word
        state.l = state.memory[currentPc+1];
        state.h = state.memory[currentPc+2];
        state.pc += 2;
        break;
      case 0x22: _unimplementedInstruction(); break;
      case 0x23: //INX H
        state.l++;
        if(state.l == 0) {
          state.h++;
        }
        break;
      case 0x24: //INR H
        int res = state.h + 1;
        state.cc.z = (res == 0) ? 1 : 0;
        state.cc.s = (0x80 == (res & 0x80)) ? 1 : 0;
        state.cc.p = _parity(res, 8);
        state.h = res;
        break;
      case 0x25: _unimplementedInstruction(); break;
      case 0x26: //MVI H,byte
        state.h = state.memory[currentPc+1];
        state.pc++;
        break;
      case 0x27: _unimplementedInstruction(); break;
      case 0x28: _unimplementedInstruction(); break;
      case 0x29: //DAD H
        int hl = (state.h << 8) | state.l;
        int res = hl + hl;
        state.h = (res & 0xff00) >> 8;
        state.l = res & 0xff;
        state.cc.cy = ((res & 0xffff0000) != 0) ? 1 : 0;
        break;
      case 0x2a: _unimplementedInstruction(); break;
      case 0x2b: _unimplementedInstruction(); break;
      case 0x2c: _unimplementedInstruction(); break;
      case 0x2d: _unimplementedInstruction(); break;
      case 0x2e: _unimplementedInstruction(); break;
      case 0x2f: //CMA (not)
        state.a = ~state.a;
        break;
      case 0x30: _unimplementedInstruction(); break;
      case 0x31: //LXI SP,word
        state.sp = (state.memory[currentPc+2] << 8) | state.memory[currentPc+1];
        state.pc += 2;
        break;
      case 0x32: //STA word
        int offset = (state.memory[currentPc+2] << 8) | state.memory[currentPc+1];
        state.memory[offset] = state.a;
        state.pc += 2;
        break;
      case 0x33: _unimplementedInstruction(); break;
      case 0x34: _unimplementedInstruction(); break;
      case 0x35: _unimplementedInstruction(); break;
      case 0x36: //MVI M,byte
        int offset = (state.h << 8) | state.l;
        state.memory[offset] = state.memory[currentPc+1];
        state.pc++;
        break;
      case 0x37: _unimplementedInstruction(); break;
      case 0x38: _unimplementedInstruction(); break;
      case 0x39: _unimplementedInstruction(); break;
      case 0x3a: //LDA (word)
        int offset = (state.memory[currentPc+2] << 8) | state.memory[currentPc+1];
        state.a = state.memory[offset];
        state.pc += 2;
        break;
      case 0x3b: _unimplementedInstruction(); break;
      case 0x3c: _unimplementedInstruction(); break;
      case 0x3d: _unimplementedInstruction(); break;
      case 0x3e: //MVI A,byte
        state.a = state.memory[currentPc+1];
        state.pc++;
        break;
      case 0x3f: _unimplementedInstruction(); break;
      case 0x40: _unimplementedInstruction(); break;
      case 0x41: _unimplementedInstruction(); break;
      case 0x42: _unimplementedInstruction(); break;
      case 0x43: _unimplementedInstruction(); break;
      case 0x44: _unimplementedInstruction(); break;
      case 0x45: _unimplementedInstruction(); break;
      case 0x46: _unimplementedInstruction(); break;
      case 0x47: _unimplementedInstruction(); break;
      case 0x48: _unimplementedInstruction(); break;
      case 0x49: _unimplementedInstruction(); break;
      case 0x4a: _unimplementedInstruction(); break;
      case 0x4b: _unimplementedInstruction(); break;
      case 0x4c: _unimplementedInstruction(); break;
      case 0x4d: _unimplementedInstruction(); break;
      case 0x4e: _unimplementedInstruction(); break;
      case 0x4f: _unimplementedInstruction(); break;
      case 0x50: _unimplementedInstruction(); break;
      case 0x51: _unimplementedInstruction(); break;
      case 0x52: _unimplementedInstruction(); break;
      case 0x53: _unimplementedInstruction(); break;
      case 0x54: _unimplementedInstruction(); break;
      case 0x55: _unimplementedInstruction(); break;
      case 0xe6: //ANI byte
        int x = state.a & state.memory[currentPc+1];
        state.cc.z = (x == 0) ? 1 : 0;
        state.cc.s = (0x80 == (x & 0x80)) ? 1 : 0;
        state.cc.p = _parity(x, 8);
        state.cc.cy = 0;
        state.a = x;
        state.pc++;
        break;
      case 0x80: //ADD B
        int answer = state.a + state.b;
        state.cc.z = ((answer & 0xff) == 0) ? 1 : 0;
        state.cc.s = ((answer & 0x80) != 0) ? 1 : 0;
        state.cc.cy = (answer > 0xff) ? 1 : 0;
        state.cc.p = _parity(answer & 0xff,8);
        state.a = answer & 0xff;
        break;
      case 0x81: //ADD C
        int answer = state.a + state.c;
        state.cc.z = ((answer & 0xff) == 0) ? 1 : 0;
        state.cc.s = ((answer & 0x80) != 0) ? 1 : 0;
        state.cc.cy = (answer > 0xff) ? 1 : 0;
        state.cc.p = _parity(answer & 0xff,8);
        state.a = answer & 0xff;
        break;
      case 0xc1: //POP B
        state.c = state.memory[state.sp];
        state.b = state.memory[state.sp+1];
        state.sp += 2;
        break;
      case 0xc2: //JNZ address
        state.pc = (0 == state.cc.z) ? (state.memory[currentPc+2] << 8) | state.memory[currentPc+1] : state.pc + 2;
        break;
      case 0xc3: //JMP address
        state.pc = (state.memory[currentPc+2] << 8) | state.memory[currentPc+1];
        break;
      case 0xc5: //PUSH B
        state.memory[state.sp-1] = state.b;
        state.memory[state.sp-2] = state.c;
        state.sp = state.sp - 2;
        break;
      case 0xc6: //ADI byte
        int answer = state.a + state.memory[currentPc+1];
        state.cc.z = ((answer & 0xff) == 0) ? 1 : 0;
        state.cc.s = ((answer & 0x80) != 0) ? 1 : 0;
        state.cc.cy = (answer > 0xff) ? 1 : 0;
        state.cc.p = _parity(answer & 0xff,8);
        state.a = answer & 0xff;
        break;
      case 0xc9: //RET
        state.pc = state.memory[state.sp] | (state.memory[state.sp+1] << 8);
        state.sp += 2;
        break;
      case 0xcd: //CALL adr
        int ret = state.pc+2;
        state.memory[state.sp-1] = (ret >> 8) & 0xff;
        state.memory[state.sp-2] = (ret & 0xff);
        state.sp = state.sp - 2;
        state.pc = (state.memory[currentPc+2] << 8) | state.memory[currentPc+1];
        break;
      case 0x86: //ADD M
        int offset = (state.h<<8) | (state.l);
        int answer = state.a + state.memory[offset];
        state.cc.z = ((answer & 0xff) == 0) ? 1 : 0;
        state.cc.s = ((answer & 0x80) != 0) ? 1 : 0;
        state.cc.cy = (answer > 0xff) ? 1 : 0;
        state.cc.p = _parity(answer & 0xff,8);
        state.a = answer & 0xff;
        break;
      case 0xf1: //POP PSW
        state.a = state.memory[state.sp+1];
        int psw = state.memory[state.sp];
        state.cc.z = (0x01 == (psw & 0x01)) ? 1 : 0;
        state.cc.s = (0x02 == (psw & 0x02)) ? 1 : 0;
        state.cc.p = (0x04 == (psw & 0x04)) ? 1 : 0;
        state.cc.cy = (0x05 == (psw & 0x08)) ? 1 : 0;
        state.cc.ac = (0x10 == (psw & 0x10)) ? 1 : 0;
        state.sp += 2;
        break;
      case 0xf5: //PUSH PSW
        state.memory[state.sp-1] = state.a;
        int psw = (state.cc.z | state.cc.s << 1 | state.cc.p << 2 | state.cc.cy << 3 | state.cc.ac << 4);
        state.memory[state.sp-2] = psw;
        state.sp = state.sp - 2;
        break;
      case 0xfe: //CPI byte
        int x = state.a - state.memory[currentPc+1];
        state.cc.z = (x == 0) ? 1 : 0;
        state.cc.s = (0x80 == (x & 0x80)) ? 1 : 0;
        state.cc.p = _parity(x, 8);
        state.cc.cy = (state.a < state.memory[currentPc+1]) ? 1 : 0;
        state.pc++;
        break;
    }

    return 0;
  }



}