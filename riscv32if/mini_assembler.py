#!/usr/bin/env python3

import re

# A small helper: register names are "x0" to "x31"
def parse_reg(reg_str):
    # Expect something like "x13"
    # remove possible commas
    reg_str = reg_str.replace(",", "")
    if reg_str[0] == 'x':
        return int(reg_str[1:])
    else:
        raise ValueError(f"Bad register name: {reg_str}")

def int_to_signed(val, bits):
    """Take an integer (could be negative) and wrap it to a signed 'bits'-bit range."""
    # For example, if bits=12, valid range is -2048..2047
    # We'll do Python-style "val & ((1<<bits)-1)" approach
    mask = (1 << bits) - 1
    return val & mask

def signed_to_int32(val):
    """Interpret a 32-bit value as a signed Python int."""
    # If the top bit is set, interpret as negative.
    if val & 0x80000000:
        return val - 0x100000000
    return val

# Simple dictionaries for opcode/funct3/funct7
OPCODES = {
    'R_INTEGER': '0110011',  # integer R-type
    'I_INTEGER': '0010011',  # integer I-type
    'LOAD':      '0000011',
    'STORE':     '0100011',
    'BRANCH':    '1100011',
    # float ops
    'R_FLOAT':   '1010011',  # custom for fadd, fsub, fdiv
    'B_FLOAT':   '1110011',  # custom for fbeq, fblt, fbge
}

FUNCT3 = {
    # For integer R-type or I-type
    'add/sub':  '000',
    'and':      '111',
    'or':       '110',
    'xor':      '100',
    'sll':      '001',
    'srl/sra':  '101',
    # For loads/stores
    'lw':       '010',
    'sw':       '010',
    # integer branches
    'beq':      '000',
    'bne':      '001',
    'blt':      '100',
    'bge':      '101',
    'bltu':     '110',
    'bgeu':     '111',
    # float branches
    'fbeq':     '000',
    'fblt':     '100',
    'fbge':     '101',
}

FUNCT7 = {
    'add': '0000000',
    'sub': '0100000',
    'and': '0000000',
    'or':  '0000000',
    'xor': '0000000',
    'sll': '0000000',
    'srl': '0000000',
    'sra': '0100000',

    # custom float
    'fadd': '0000000',
    'fsub': '0000100',
    'fdiv': '0001100',
}

def assemble_rtype_int(mnemonic, rd, rs1, rs2):
    """
    R-type integer instruction:
      31:25 = funct7
      24:20 = rs2
      19:15 = rs1
      14:12 = funct3
      11:7  = rd
      6:0   = opcode
    """
    f7 = FUNCT7[mnemonic] if mnemonic in FUNCT7 else '0000000'
    if mnemonic in ('add','sub'):
        f3 = FUNCT3['add/sub']
    elif mnemonic in ('and'):
        f3 = FUNCT3['and']
    elif mnemonic in ('or'):
        f3 = FUNCT3['or']
    elif mnemonic in ('xor'):
        f3 = FUNCT3['xor']
    elif mnemonic in ('sll'):
        f3 = FUNCT3['sll']
    elif mnemonic in ('srl','sra'):
        f3 = FUNCT3['srl/sra']
    else:
        f3 = '000'  # default

    opcode = OPCODES['R_INTEGER']  # "0110011"
    binstr = f7 + f"{rs2:05b}" + f"{rs1:05b}" + f3 + f"{rd:05b}" + opcode
    return int(binstr, 2)

def assemble_itype_int(mnemonic, rd, rs1, imm12):
    """
    I-type integer:
      31:20 = imm[11:0]
      19:15 = rs1
      14:12 = funct3
      11:7  = rd
      6:0   = opcode
    """
    # SHIFT immediate? check sll, srl, sra
    # or normal addi, ori, etc.
    if mnemonic in ('slli','srli','srai'):
        # shift imm is 5 bits in low portion, plus top bits in funct7
        if mnemonic == 'slli':
            f3 = '001'
            f7 = '0000000'
        elif mnemonic == 'srli':
            f3 = '101'
            f7 = '0000000'
        elif mnemonic == 'srai':
            f3 = '101'
            f7 = '0100000'

        shamt5 = imm12 & 0x1F
        binstr = f7 + f"{shamt5:05b}" + f"{rs1:05b}" + f3 + f"{rd:05b}" + OPCODES['I_INTEGER']
        return int(binstr, 2)
    else:
        # e.g. addi, ori, etc.
        # figure out funct3 from mnemonic
        if mnemonic == 'addi':
            f3 = '000'
        elif mnemonic == 'ori':
            f3 = '110'
        else:
            f3 = '000'  # default
        imm12 = int_to_signed(imm12, 12)
        binstr = f"{imm12:012b}" + f"{rs1:05b}" + f3 + f"{rd:05b}" + OPCODES['I_INTEGER']
        return int(binstr, 2)

def assemble_load(mnemonic, rd, rs1, imm12):
    """
    load: lw xD, imm(xS)
      31:20=imm
      19:15=rs1
      14:12=funct3
      11:7 =rd
      6:0  =opcode
    """
    f3 = FUNCT3[mnemonic]  # lw -> 010
    imm12 = int_to_signed(imm12, 12)
    opcode = OPCODES['LOAD']  # 0000011
    binstr = f"{imm12:012b}" + f"{rs1:05b}" + f3 + f"{rd:05b}" + opcode
    return int(binstr, 2)

def assemble_store(mnemonic, rs2, rs1, imm12):
    """
    store: sw xS2, imm(xS1)
    B-type layout: imm[11:5], rs2, rs1, funct3, imm[4:0], opcode
    But in RISC-V, store is actually S-type, not B-type.
    S-type:
      31:25 = imm[11:5]
      24:20 = rs2
      19:15 = rs1
      14:12 = funct3
      11:7  = imm[4:0]
      6:0   = opcode
    """
    f3 = FUNCT3[mnemonic]  # sw -> 010
    imm12 = int_to_signed(imm12, 12)
    imm_hi = (imm12 >> 5) & 0x7F   # bits [11:5]
    imm_lo = imm12 & 0x1F          # bits [4:0]
    opcode = OPCODES['STORE']      # 0100011
    binstr = f"{imm_hi:07b}" + f"{rs2:05b}" + f"{rs1:05b}" + f3 + f"{imm_lo:05b}" + opcode
    return int(binstr, 2)

def assemble_branch(mnemonic, rs1, rs2, imm13):
    """
    B-type:
      imm[12]   imm[10:5]   rs2  rs1  funct3  imm[4:1]  imm[11]  opcode
      We have imm13 because we shift by 1 in real code. The immediate in assembly
      is usually the *byte* offset. We must incorporate that into bits properly.
    """
    f3 = FUNCT3[mnemonic]
    # RISC-V branch immediate is multiple of 2 in hardware
    # so imm13 (the immediate >> 1) is needed. But let's assume
    # we get the "byte offset" from the label difference, then shift >> 1 to store.
    # But let's do that outside: we can do imm >> 1. We'll do it here for clarity.

    # imm13 must be sign-extended. 
    # bits: imm[12] = imm13[12], imm[11]= imm13[0], imm[10:5] = imm13[11:6], imm[4:1] = imm13[5:2].
    # Actually a bit tricky, let's do standard approach:
    imm = int_to_signed(imm13, 13)  # get 13-bit signed
    imm_12   = (imm >> 12) & 0x1
    imm_10_5 = (imm >> 5) & 0x3F
    imm_4_1  = (imm >> 1) & 0xF
    imm_11   = (imm >> 11) & 0x1

    opcode = OPCODES['BRANCH']  # 1100011
    binstr = (f"{imm_12:01b}" +
              f"{imm_10_5:06b}" +
              f"{rs2:05b}" +
              f"{rs1:05b}" +
              f3 +
              f"{imm_4_1:04b}" +
              f"{imm_11:01b}" +
              opcode)
    return int(binstr, 2)

def assemble_rtype_float(mnemonic, rd, rs1, rs2):
    """
    Custom float R-type:
      fadd => funct7=0000000, funct3=000
      fsub => funct7=0000100, funct3=000
      fdiv => funct7=0001100, funct3=000
      opcode=1010011
    """
    f7 = FUNCT7[mnemonic] if mnemonic in FUNCT7 else '0000000'
    f3 = '000'  # your design used fun3=000 for all float arithmetic
    opcode = OPCODES['R_FLOAT']  # '1010011'
    binstr = f7 + f"{rs2:05b}" + f"{rs1:05b}" + f3 + f"{rd:05b}" + opcode
    return int(binstr, 2)

def assemble_branch_float(mnemonic, rs1, rs2, imm13):
    """
    Custom float branch:
      fbeq => fun3=000
      fblt => fun3=100
      fbge => fun3=101
      opcode=1110011
      B-type layout for offset
    """
    f3 = FUNCT3[mnemonic]
    opcode = OPCODES['B_FLOAT']  # '1110011'

    imm = int_to_signed(imm13, 13)  
    imm_12   = (imm >> 12) & 0x1
    imm_10_5 = (imm >> 5) & 0x3F
    imm_4_1  = (imm >> 1) & 0xF
    imm_11   = (imm >> 11) & 0x1

    binstr = (f"{imm_12:01b}" +
              f"{imm_10_5:06b}" +
              f"{rs2:05b}" +
              f"{rs1:05b}" +
              f3 +
              f"{imm_4_1:04b}" +
              f"{imm_11:01b}" +
              opcode)
    return int(binstr, 2)

def parse_line(line):
    """
    Parse an assembly line, return a tuple describing it.
    We'll do a simplified parse:
      1) label only (like 'loop:')
      2) instruction with possible label at the end or beginning
         e.g. 'add x1, x2, x3'
         e.g. 'lw x4, 8(x5)'
         e.g. 'fblt x10, x11, Lsomewhere'
    Return: (label, mnemonic, args[]) or None if blank/comment
    """
    # strip comments
    line = line.split('#')[0].strip()
    if not line:
        return None
    
    # check if there's a label definition
    label = None
    m = re.match(r'^([\w\d_]+):\s*(.*)$', line)
    if m:
        label = m.group(1)
        line_rest = m.group(2).strip()
        if not line_rest:
            return (label, None, [])
        # otherwise line_rest might contain an instruction too
        line = line_rest

    # now parse the instruction mnemonic + args
    parts = line.replace(',', ' ').split()
    mnemonic = parts[0]
    args = parts[1:]
    return (label, mnemonic, args)

def assemble_instruction(mnemonic, args, pc, labels):
    """
    Convert a single mnemonic+args into a 32-bit machine code integer.
    We have 'pc' for current instruction address, and 'labels' dict to compute offsets for branches.
    We'll do only a subset of instructions for demonstration.
    """
    # R-type integer
    if mnemonic in ('add','sub','and','or','xor','sll','srl','sra'):
        # format: add xD, xS1, xS2
        rd = parse_reg(args[0])
        rs1 = parse_reg(args[1])
        rs2 = parse_reg(args[2])
        return assemble_rtype_int(mnemonic, rd, rs1, rs2)

    # I-type integer
    if mnemonic in ('addi','ori'):
        # e.g. addi xD, xS, imm
        rd = parse_reg(args[0])
        rs1 = parse_reg(args[1])
        imm = int(args[2], 0)  # parse immediate in decimal or hex
        return assemble_itype_int(mnemonic, rd, rs1, imm)
    if mnemonic in ('slli','srli','srai'):
        # shift immediate
        rd = parse_reg(args[0])
        rs1 = parse_reg(args[1])
        imm = int(args[2], 0)
        return assemble_itype_int(mnemonic, rd, rs1, imm)

    # load
    if mnemonic in ('lw',):
        # lw xD, imm(xS)
        rd = parse_reg(args[0])
        # something like "8(x5)"
        m = re.match(r'(-?\d+)\((x\d+)\)', args[1])
        if not m:
            raise ValueError(f"Bad load/store syntax: {args}")
        imm_str, rs1_str = m.groups()
        rs1 = parse_reg(rs1_str)
        imm = int(imm_str, 0)
        return assemble_load(mnemonic, rd, rs1, imm)

    # store
    if mnemonic in ('sw',):
        # sw xS2, imm(xS1)
        rs2 = parse_reg(args[0])
        m = re.match(r'(-?\d+)\((x\d+)\)', args[1])
        if not m:
            raise ValueError(f"Bad load/store syntax: {args}")
        imm_str, rs1_str = m.groups()
        rs1 = parse_reg(rs1_str)
        imm = int(imm_str, 0)
        return assemble_store(mnemonic, rs2, rs1, imm)

    # integer branch
    if mnemonic in ('beq','bne','blt','bge','bltu','bgeu'):
        # e.g. beq xS1, xS2, label
        rs1 = parse_reg(args[0])
        rs2 = parse_reg(args[1])
        label = args[2]
        if label not in labels:
            raise ValueError(f"Label not found: {label}")
        target_pc = labels[label]
        offset_bytes = target_pc - pc
        # In RISC-V, we store offset>>1 in the instruction bits, but let's pass offset_bytes>>1
        # Actually the assembler might incorporate that detail inside assemble_branch.
        imm13 = offset_bytes
        return assemble_branch(mnemonic, rs1, rs2, imm13)

    # float R-type (fadd, fsub, fdiv)
    if mnemonic in ('fadd','fsub','fdiv'):
        # e.g. fadd xD, xS1, xS2
        rd = parse_reg(args[0])
        rs1 = parse_reg(args[1])
        rs2 = parse_reg(args[2])
        return assemble_rtype_float(mnemonic, rd, rs1, rs2)

    # float branch (fbeq, fblt, fbge)
    if mnemonic in ('fbeq','fblt','fbge'):
        rs1 = parse_reg(args[0])
        rs2 = parse_reg(args[1])
        label = args[2]
        if label not in labels:
            raise ValueError(f"Label not found: {label}")
        target_pc = labels[label]
        offset_bytes = target_pc - pc
        imm13 = offset_bytes
        return assemble_branch_float(mnemonic, rs1, rs2, imm13)

    # fallback
    raise ValueError(f"Unsupported mnemonic: {mnemonic}")


def assemble_lines(lines):
    """
    Two-pass assembly:
      1) collect labels
      2) assemble instructions
    We'll assume each instruction is 4 bytes => PC increments by 4 each line with an instruction.
    """
    # pass 1: gather labels
    labels = {}
    pc = 0
    instructions_list = []  # hold (pc, label, mnemonic, args)
    for line in lines:
        parsed = parse_line(line)
        if parsed is None:
            continue
        label, mnemonic, args = parsed
        # if there's a label, record its PC
        if label is not None:
            labels[label] = pc
        if mnemonic is not None:
            instructions_list.append( (pc, mnemonic, args) )
            pc += 4

    # pass 2: encode
    machine_codes = []
    for (pc, mnemonic, args) in instructions_list:
        code = assemble_instruction(mnemonic, args, pc, labels)
        machine_codes.append( (pc, code) )

    return machine_codes

def main():
    import sys

    # read lines from stdin or from file given
    if len(sys.argv) > 1:
        with open(sys.argv[1], 'r') as f:
            lines = f.readlines()
    else:
        lines = sys.stdin.readlines()

    machine_codes = assemble_lines(lines)

    # print hex results
    for (pc, code) in machine_codes:
        print(f"{pc:08x}: {code:08x}")

if __name__ == "__main__":
    main()
