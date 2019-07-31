import std.stdio;
import std.conv;
import pegged.grammar;

void main()
{
  mixin(grammar(`
    # Test
    Assembly:
      Program  <- ;Spacing Line+ :eoi
      Line     <- Instruction ;Spacing

    # Spacing and comments
      Spacing     <- :(blank / Comment)*
      Comment     <- ';' ~(!eol .)* :eol


    # Instruction

      Instruction   <- Instruction3P / Instruction2P / Instruction1P / Instruction0P
      Instruction3P <- Opcode3Parm :blank+ Expression :blank* "," :blank* Expression :blank* "," :blank* Expression
      Instruction2P <- Opcode2Parm :blank+ Expression :blank* "," :blank* Expression
      Instruction1P <- Opcode1Parm :blank+ Expression
      Instruction0P <- Opcode0Parm

    # Opcodes

      Opcode3Parm   <- Add / Sub
      Add           <~ "add"i
      Sub           <~ "sub"i

      Opcode2Parm   <- Mov / Add / Sub
      Mov           <~ "mov"i

      Opcode1Parm   <- Int
      Int           <~ "int"i

      Opcode0Parm   <- Nop
      Nop           <~ "nop"i

    # Expressions
      Expression    <- Integer
      Integer       <~ digit+
  `));

  enum input = `
    int    1 ; Ja

    ; Hola
    int 2 ; caca
    nop
    mov 0, 1
    add 1, 2,3
    `;

  enum match = Assembly(input);

  writeln(match);
}
