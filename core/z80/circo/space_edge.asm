space_edge:
    LD A,127
    IN A,($FE)
    AND 1
    JR NZ,space_release
    LD A,(pressed)
    OR A
    JR Z,space_new
    XOR A
    RET
space_new:
    LD A,1
    LD (pressed),A
    RET
space_release:
    XOR A
    LD (pressed),A
    RET
