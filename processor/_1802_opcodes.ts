class CPU1802_Opcodes extends CPU1802_Base {

public getOpcodeList():Function[] {
    opcode_00(),opcode_01(),opcode_02(),opcode_03(),opcode_04(),opcode_05(),opcode_06(),opcode_07(),opcode_08(),opcode_09(),opcode_0a(),opcode_0b(),opcode_0c(),opcode_0d(),opcode_0e(),opcode_0f(),opcode_10(),opcode_11(),opcode_12(),opcode_13(),opcode_14(),opcode_15(),opcode_16(),opcode_17(),opcode_18(),opcode_19(),opcode_1a(),opcode_1b(),opcode_1c(),opcode_1d(),opcode_1e(),opcode_1f(),opcode_20(),opcode_21(),opcode_22(),opcode_23(),opcode_24(),opcode_25(),opcode_26(),opcode_27(),opcode_28(),opcode_29(),opcode_2a(),opcode_2b(),opcode_2c(),opcode_2d(),opcode_2e(),opcode_2f(),opcode_30(),opcode_31(),opcode_32(),opcode_33(),opcode_34(),opcode_35(),opcode_36(),opcode_37(),opcode_38(),opcode_39(),opcode_3a(),opcode_3b(),opcode_3c(),opcode_3d(),opcode_3e(),opcode_3f(),opcode_40(),opcode_41(),opcode_42(),opcode_43(),opcode_44(),opcode_45(),opcode_46(),opcode_47(),opcode_48(),opcode_49(),opcode_4a(),opcode_4b(),opcode_4c(),opcode_4d(),opcode_4e(),opcode_4f(),opcode_50(),opcode_51(),opcode_52(),opcode_53(),opcode_54(),opcode_55(),opcode_56(),opcode_57(),opcode_58(),opcode_59(),opcode_5a(),opcode_5b(),opcode_5c(),opcode_5d(),opcode_5e(),opcode_5f(),opcode_60(),opcode_61(),opcode_62(),opcode_63(),opcode_64(),opcode_65(),opcode_66(),opcode_67(),opcode_68(),opcode_69(),opcode_6a(),opcode_6b(),opcode_6c(),opcode_6d(),opcode_6e(),opcode_6f(),opcode_70(),opcode_71(),opcode_72(),opcode_73(),opcode_74(),opcode_75(),opcode_76(),opcode_77(),opcode_78(),opcode_79(),opcode_7a(),opcode_7b(),opcode_7c(),opcode_7d(),opcode_7e(),opcode_7f(),opcode_80(),opcode_81(),opcode_82(),opcode_83(),opcode_84(),opcode_85(),opcode_86(),opcode_87(),opcode_88(),opcode_89(),opcode_8a(),opcode_8b(),opcode_8c(),opcode_8d(),opcode_8e(),opcode_8f(),opcode_90(),opcode_91(),opcode_92(),opcode_93(),opcode_94(),opcode_95(),opcode_96(),opcode_97(),opcode_98(),opcode_99(),opcode_9a(),opcode_9b(),opcode_9c(),opcode_9d(),opcode_9e(),opcode_9f(),opcode_a0(),opcode_a1(),opcode_a2(),opcode_a3(),opcode_a4(),opcode_a5(),opcode_a6(),opcode_a7(),opcode_a8(),opcode_a9(),opcode_aa(),opcode_ab(),opcode_ac(),opcode_ad(),opcode_ae(),opcode_af(),opcode_b0(),opcode_b1(),opcode_b2(),opcode_b3(),opcode_b4(),opcode_b5(),opcode_b6(),opcode_b7(),opcode_b8(),opcode_b9(),opcode_ba(),opcode_bb(),opcode_bc(),opcode_bd(),opcode_be(),opcode_bf(),opcode_c0(),opcode_c1(),opcode_c2(),opcode_c3(),opcode_c4(),opcode_c5(),opcode_c6(),opcode_c7(),opcode_c8(),opcode_c9(),opcode_ca(),opcode_cb(),opcode_cc(),opcode_cd(),opcode_ce(),opcode_cf(),opcode_d0(),opcode_d1(),opcode_d2(),opcode_d3(),opcode_d4(),opcode_d5(),opcode_d6(),opcode_d7(),opcode_d8(),opcode_d9(),opcode_da(),opcode_db(),opcode_dc(),opcode_dd(),opcode_de(),opcode_df(),opcode_e0(),opcode_e1(),opcode_e2(),opcode_e3(),opcode_e4(),opcode_e5(),opcode_e6(),opcode_e7(),opcode_e8(),opcode_e9(),opcode_ea(),opcode_eb(),opcode_ec(),opcode_ed(),opcode_ee(),opcode_ef(),opcode_f0(),opcode_f1(),opcode_f2(),opcode_f3(),opcode_f4(),opcode_f5(),opcode_f6(),opcode_f7(),opcode_f8(),opcode_f9(),opcode_fa(),opcode_fb(),opcode_fc(),opcode_fd(),opcode_fe(),opcode_ff()
}

private opcode_00(): void { /*** idl ***/
    ;
}
private opcode_01(): void { /*** ldn r1 ***/
    this.d = this.read(this.r[0x1]);
}
private opcode_02(): void { /*** ldn r2 ***/
    this.d = this.read(this.r[0x2]);
}
private opcode_03(): void { /*** ldn r3 ***/
    this.d = this.read(this.r[0x3]);
}
private opcode_04(): void { /*** ldn r4 ***/
    this.d = this.read(this.r[0x4]);
}
private opcode_05(): void { /*** ldn r5 ***/
    this.d = this.read(this.r[0x5]);
}
private opcode_06(): void { /*** ldn r6 ***/
    this.d = this.read(this.r[0x6]);
}
private opcode_07(): void { /*** ldn r7 ***/
    this.d = this.read(this.r[0x7]);
}
private opcode_08(): void { /*** ldn r8 ***/
    this.d = this.read(this.r[0x8]);
}
private opcode_09(): void { /*** ldn r9 ***/
    this.d = this.read(this.r[0x9]);
}
private opcode_0a(): void { /*** ldn ra ***/
    this.d = this.read(this.r[0xA]);
}
private opcode_0b(): void { /*** ldn rb ***/
    this.d = this.read(this.r[0xB]);
}
private opcode_0c(): void { /*** ldn rc ***/
    this.d = this.read(this.r[0xC]);
}
private opcode_0d(): void { /*** ldn rd ***/
    this.d = this.read(this.r[0xD]);
}
private opcode_0e(): void { /*** ldn re ***/
    this.d = this.read(this.r[0xE]);
}
private opcode_0f(): void { /*** ldn rf ***/
    this.d = this.read(this.r[0xF]);
}
private opcode_10(): void { /*** inc r0 ***/
    this.r[0x0] = (this.r[0x0]+1) & 0xFFFF;
}
private opcode_11(): void { /*** inc r1 ***/
    this.r[0x1] = (this.r[0x1]+1) & 0xFFFF;
}
private opcode_12(): void { /*** inc r2 ***/
    this.r[0x2] = (this.r[0x2]+1) & 0xFFFF;
}
private opcode_13(): void { /*** inc r3 ***/
    this.r[0x3] = (this.r[0x3]+1) & 0xFFFF;
}
private opcode_14(): void { /*** inc r4 ***/
    this.r[0x4] = (this.r[0x4]+1) & 0xFFFF;
}
private opcode_15(): void { /*** inc r5 ***/
    this.r[0x5] = (this.r[0x5]+1) & 0xFFFF;
}
private opcode_16(): void { /*** inc r6 ***/
    this.r[0x6] = (this.r[0x6]+1) & 0xFFFF;
}
private opcode_17(): void { /*** inc r7 ***/
    this.r[0x7] = (this.r[0x7]+1) & 0xFFFF;
}
private opcode_18(): void { /*** inc r8 ***/
    this.r[0x8] = (this.r[0x8]+1) & 0xFFFF;
}
private opcode_19(): void { /*** inc r9 ***/
    this.r[0x9] = (this.r[0x9]+1) & 0xFFFF;
}
private opcode_1a(): void { /*** inc ra ***/
    this.r[0xA] = (this.r[0xA]+1) & 0xFFFF;
}
private opcode_1b(): void { /*** inc rb ***/
    this.r[0xB] = (this.r[0xB]+1) & 0xFFFF;
}
private opcode_1c(): void { /*** inc rc ***/
    this.r[0xC] = (this.r[0xC]+1) & 0xFFFF;
}
private opcode_1d(): void { /*** inc rd ***/
    this.r[0xD] = (this.r[0xD]+1) & 0xFFFF;
}
private opcode_1e(): void { /*** inc re ***/
    this.r[0xE] = (this.r[0xE]+1) & 0xFFFF;
}
private opcode_1f(): void { /*** inc rf ***/
    this.r[0xF] = (this.r[0xF]+1) & 0xFFFF;
}
private opcode_20(): void { /*** dec r0 ***/
    this.r[0x0] = (this.r[0x0]-1) & 0xFFFF;
}
private opcode_21(): void { /*** dec r1 ***/
    this.r[0x1] = (this.r[0x1]-1) & 0xFFFF;
}
private opcode_22(): void { /*** dec r2 ***/
    this.r[0x2] = (this.r[0x2]-1) & 0xFFFF;
}
private opcode_23(): void { /*** dec r3 ***/
    this.r[0x3] = (this.r[0x3]-1) & 0xFFFF;
}
private opcode_24(): void { /*** dec r4 ***/
    this.r[0x4] = (this.r[0x4]-1) & 0xFFFF;
}
private opcode_25(): void { /*** dec r5 ***/
    this.r[0x5] = (this.r[0x5]-1) & 0xFFFF;
}
private opcode_26(): void { /*** dec r6 ***/
    this.r[0x6] = (this.r[0x6]-1) & 0xFFFF;
}
private opcode_27(): void { /*** dec r7 ***/
    this.r[0x7] = (this.r[0x7]-1) & 0xFFFF;
}
private opcode_28(): void { /*** dec r8 ***/
    this.r[0x8] = (this.r[0x8]-1) & 0xFFFF;
}
private opcode_29(): void { /*** dec r9 ***/
    this.r[0x9] = (this.r[0x9]-1) & 0xFFFF;
}
private opcode_2a(): void { /*** dec ra ***/
    this.r[0xA] = (this.r[0xA]-1) & 0xFFFF;
}
private opcode_2b(): void { /*** dec rb ***/
    this.r[0xB] = (this.r[0xB]-1) & 0xFFFF;
}
private opcode_2c(): void { /*** dec rc ***/
    this.r[0xC] = (this.r[0xC]-1) & 0xFFFF;
}
private opcode_2d(): void { /*** dec rd ***/
    this.r[0xD] = (this.r[0xD]-1) & 0xFFFF;
}
private opcode_2e(): void { /*** dec re ***/
    this.r[0xE] = (this.r[0xE]-1) & 0xFFFF;
}
private opcode_2f(): void { /*** dec rf ***/
    this.r[0xF] = (this.r[0xF]-1) & 0xFFFF;
}
private opcode_30(): void { /*** br .1 ***/
    this.t8 = this.fetch();this.r[this.p] = (this.r[this.p] & 0xFF00) | this.t8;
}
private opcode_31(): void { /*** bq .1 ***/
    this.t8 = this.fetch();if (this.q != 0) { this.r[this.p] = (this.r[this.p] & 0xFF00) | this.t8; };
}
private opcode_32(): void { /*** bz .1 ***/
    this.t8 = this.fetch();if (this.d == 0) { this.r[this.p] = (this.r[this.p] & 0xFF00) | this.t8; };
}
private opcode_33(): void { /*** bdf .1 ***/
    this.t8 = this.fetch();if (this.df != 0) { this.r[this.p] = (this.r[this.p] & 0xFF00) | this.t8; };
}
private opcode_34(): void { /*** b1 .1 ***/
    this.t8 = this.fetch();if (this.eflag1() != 0) { this.r[this.p] = (this.r[this.p] & 0xFF00) | this.t8; };
}
private opcode_35(): void { /*** b2 .1 ***/
    this.t8 = this.fetch();if (this.eflag2() != 0) { this.r[this.p] = (this.r[this.p] & 0xFF00) | this.t8; };
}
private opcode_36(): void { /*** b3 .1 ***/
    this.t8 = this.fetch();if (this.eflag3() != 0) { this.r[this.p] = (this.r[this.p] & 0xFF00) | this.t8; };
}
private opcode_37(): void { /*** b4 .1 ***/
    this.t8 = this.fetch();if (this.eflag4() != 0) { this.r[this.p] = (this.r[this.p] & 0xFF00) | this.t8; };
}
private opcode_38(): void { /*** skp ***/
    this.t8 = this.fetch();
}
private opcode_39(): void { /*** bnq .1 ***/
    this.t8 = this.fetch();if (this.q == 0) { this.r[this.p] = (this.r[this.p] & 0xFF00) | this.t8; };
}
private opcode_3a(): void { /*** bnz .1 ***/
    this.t8 = this.fetch();if (this.d != 0) { this.r[this.p] = (this.r[this.p] & 0xFF00) | this.t8; };
}
private opcode_3b(): void { /*** bnf .1 ***/
    this.t8 = this.fetch();if (this.df == 0) { this.r[this.p] = (this.r[this.p] & 0xFF00) | this.t8; };
}
private opcode_3c(): void { /*** bn1 .1 ***/
    this.t8 = this.fetch();if (this.eflag1() == 0) { this.r[this.p] = (this.r[this.p] & 0xFF00) | this.t8; };
}
private opcode_3d(): void { /*** bn2 .1 ***/
    this.t8 = this.fetch();if (this.eflag2() == 0) { this.r[this.p] = (this.r[this.p] & 0xFF00) | this.t8; };
}
private opcode_3e(): void { /*** bn3 .1 ***/
    this.t8 = this.fetch();if (this.eflag3() == 0) { this.r[this.p] = (this.r[this.p] & 0xFF00) | this.t8; };
}
private opcode_3f(): void { /*** bn4 .1 ***/
    this.t8 = this.fetch();if (this.eflag4() == 0) { this.r[this.p] = (this.r[this.p] & 0xFF00) | this.t8; };
}
private opcode_40(): void { /*** lda r0 ***/
    this.d = this.read(this.r[0x0]);this.r[0x0] = (this.r[0x0]+1) & 0xFFFF;
}
private opcode_41(): void { /*** lda r1 ***/
    this.d = this.read(this.r[0x1]);this.r[0x1] = (this.r[0x1]+1) & 0xFFFF;
}
private opcode_42(): void { /*** lda r2 ***/
    this.d = this.read(this.r[0x2]);this.r[0x2] = (this.r[0x2]+1) & 0xFFFF;
}
private opcode_43(): void { /*** lda r3 ***/
    this.d = this.read(this.r[0x3]);this.r[0x3] = (this.r[0x3]+1) & 0xFFFF;
}
private opcode_44(): void { /*** lda r4 ***/
    this.d = this.read(this.r[0x4]);this.r[0x4] = (this.r[0x4]+1) & 0xFFFF;
}
private opcode_45(): void { /*** lda r5 ***/
    this.d = this.read(this.r[0x5]);this.r[0x5] = (this.r[0x5]+1) & 0xFFFF;
}
private opcode_46(): void { /*** lda r6 ***/
    this.d = this.read(this.r[0x6]);this.r[0x6] = (this.r[0x6]+1) & 0xFFFF;
}
private opcode_47(): void { /*** lda r7 ***/
    this.d = this.read(this.r[0x7]);this.r[0x7] = (this.r[0x7]+1) & 0xFFFF;
}
private opcode_48(): void { /*** lda r8 ***/
    this.d = this.read(this.r[0x8]);this.r[0x8] = (this.r[0x8]+1) & 0xFFFF;
}
private opcode_49(): void { /*** lda r9 ***/
    this.d = this.read(this.r[0x9]);this.r[0x9] = (this.r[0x9]+1) & 0xFFFF;
}
private opcode_4a(): void { /*** lda ra ***/
    this.d = this.read(this.r[0xA]);this.r[0xA] = (this.r[0xA]+1) & 0xFFFF;
}
private opcode_4b(): void { /*** lda rb ***/
    this.d = this.read(this.r[0xB]);this.r[0xB] = (this.r[0xB]+1) & 0xFFFF;
}
private opcode_4c(): void { /*** lda rc ***/
    this.d = this.read(this.r[0xC]);this.r[0xC] = (this.r[0xC]+1) & 0xFFFF;
}
private opcode_4d(): void { /*** lda rd ***/
    this.d = this.read(this.r[0xD]);this.r[0xD] = (this.r[0xD]+1) & 0xFFFF;
}
private opcode_4e(): void { /*** lda re ***/
    this.d = this.read(this.r[0xE]);this.r[0xE] = (this.r[0xE]+1) & 0xFFFF;
}
private opcode_4f(): void { /*** lda rf ***/
    this.d = this.read(this.r[0xF]);this.r[0xF] = (this.r[0xF]+1) & 0xFFFF;
}
private opcode_50(): void { /*** str r0 ***/
    this.write(this.r[0x0],this.d);
}
private opcode_51(): void { /*** str r1 ***/
    this.write(this.r[0x1],this.d);
}
private opcode_52(): void { /*** str r2 ***/
    this.write(this.r[0x2],this.d);
}
private opcode_53(): void { /*** str r3 ***/
    this.write(this.r[0x3],this.d);
}
private opcode_54(): void { /*** str r4 ***/
    this.write(this.r[0x4],this.d);
}
private opcode_55(): void { /*** str r5 ***/
    this.write(this.r[0x5],this.d);
}
private opcode_56(): void { /*** str r6 ***/
    this.write(this.r[0x6],this.d);
}
private opcode_57(): void { /*** str r7 ***/
    this.write(this.r[0x7],this.d);
}
private opcode_58(): void { /*** str r8 ***/
    this.write(this.r[0x8],this.d);
}
private opcode_59(): void { /*** str r9 ***/
    this.write(this.r[0x9],this.d);
}
private opcode_5a(): void { /*** str ra ***/
    this.write(this.r[0xA],this.d);
}
private opcode_5b(): void { /*** str rb ***/
    this.write(this.r[0xB],this.d);
}
private opcode_5c(): void { /*** str rc ***/
    this.write(this.r[0xC],this.d);
}
private opcode_5d(): void { /*** str rd ***/
    this.write(this.r[0xD],this.d);
}
private opcode_5e(): void { /*** str re ***/
    this.write(this.r[0xE],this.d);
}
private opcode_5f(): void { /*** str rf ***/
    this.write(this.r[0xF],this.d);
}
private opcode_60(): void { /*** irx ***/
    this.r[this.x] = (this.r[this.x]+1) & 0xFFFF;
}
private opcode_61(): void { /*** out 1 ***/
    this.output1(this.read(this.r[this.x]));this.r[this.x] = (this.r[this.x]+1) & 0xFFFF;
}
private opcode_62(): void { /*** out 2 ***/
    this.output2(this.read(this.r[this.x]));this.r[this.x] = (this.r[this.x]+1) & 0xFFFF;
}
private opcode_63(): void { /*** out 3 ***/
    this.output3(this.read(this.r[this.x]));this.r[this.x] = (this.r[this.x]+1) & 0xFFFF;
}
private opcode_64(): void { /*** out 4 ***/
    this.output4(this.read(this.r[this.x]));this.r[this.x] = (this.r[this.x]+1) & 0xFFFF;
}
private opcode_65(): void { /*** out 5 ***/
    this.output5(this.read(this.r[this.x]));this.r[this.x] = (this.r[this.x]+1) & 0xFFFF;
}
private opcode_66(): void { /*** out 6 ***/
    this.output6(this.read(this.r[this.x]));this.r[this.x] = (this.r[this.x]+1) & 0xFFFF;
}
private opcode_67(): void { /*** out 7 ***/
    this.output7(this.read(this.r[this.x]));this.r[this.x] = (this.r[this.x]+1) & 0xFFFF;
}
private opcode_68(): void { /*** i68 ***/
    ;
}
private opcode_69(): void { /*** inp 1 ***/
    this.d = this.input1();this.write(this.r[this.x],this.d);
}
private opcode_6a(): void { /*** inp 2 ***/
    this.d = this.input2();this.write(this.r[this.x],this.d);
}
private opcode_6b(): void { /*** inp 3 ***/
    this.d = this.input3();this.write(this.r[this.x],this.d);
}
private opcode_6c(): void { /*** inp 4 ***/
    this.d = this.input4();this.write(this.r[this.x],this.d);
}
private opcode_6d(): void { /*** inp 5 ***/
    this.d = this.input5();this.write(this.r[this.x],this.d);
}
private opcode_6e(): void { /*** inp 6 ***/
    this.d = this.input6();this.write(this.r[this.x],this.d);
}
private opcode_6f(): void { /*** inp 7 ***/
    this.d = this.input7();this.write(this.r[this.x],this.d);
}
private opcode_70(): void { /*** ret ***/
    this.t8 = this.read(this.r[this.x]);this.r[this.x] = (this.r[this.x]+1) & 0xFFFF;this.x = (this.t8 >> 4) & 0xF;this.p = this.t8 & 0xF;this.ie = 1;
}
private opcode_71(): void { /*** dis ***/
    this.t8 = this.read(this.r[this.x]);this.r[this.x] = (this.r[this.x]+1) & 0xFFFF;this.x = (this.t8 >> 4) & 0xF;this.p = this.t8 & 0xF;this.ie = 0;
}
private opcode_72(): void { /*** ldxa ***/
    this.d = this.read(this.r[this.x]);this.r[this.x] = (this.r[this.x]+1) & 0xFFFF;
}
private opcode_73(): void { /*** stxd ***/
    this.write(this.r[this.x],this.d);this.r[this.x] = (this.r[this.x]-1) & 0xFFFF;
}
private opcode_74(): void { /*** adc ***/
    this.t16 = (this.d)+(this.read(this.r[this.x]))+(this.df);this.d = this.t16 & 0xFF;this.df = (this.t16 >> 8) & 1;
}
private opcode_75(): void { /*** sdb ***/
    this.t16 = (this.d^0xFF)+(this.read(this.r[this.x]))+(this.df);this.d = this.t16 & 0xFF;this.df = (this.t16 >> 8) & 1;
}
private opcode_76(): void { /*** rshr ***/
    this.t16 = this.d | (this.df << 8);this.df = this.d & 1;this.d = (this.t16 >> 1) & 0xFF;
}
private opcode_77(): void { /*** smb ***/
    this.t16 = (this.d)+(this.read(this.r[this.x])^0xFF)+(this.df);this.d = this.t16 & 0xFF;this.df = (this.t16 >> 8) & 1;
}
private opcode_78(): void { /*** sav ***/
    this.write(this.r[this.x],this.t);
}
private opcode_79(): void { /*** mark ***/
    this.t = (this.x << 4)|this.p;this.write(this.r[2],this.t);this.x = this.p;this.r[2] = (this.r[2]-1) & 0xFFFF;
}
private opcode_7a(): void { /*** req ***/
    this.q = 0;this.updateq(0);
}
private opcode_7b(): void { /*** seq ***/
    this.q = 1;this.updateq(1);
}
private opcode_7c(): void { /*** adci .1 ***/
    this.t16 = (this.d)+(this.fetch())+(this.df);this.d = this.t16 & 0xFF;this.df = (this.t16 >> 8) & 1;
}
private opcode_7d(): void { /*** sdbi .1 ***/
    this.t16 = (this.d^0xFF)+(this.fetch())+(this.df);this.d = this.t16 & 0xFF;this.df = (this.t16 >> 8) & 1;
}
private opcode_7e(): void { /*** rshl ***/
    this.t16 = (this.d << 1) | this.df;this.d = this.t16 & 0xFF;this.df = (this.t16 >> 8) & 1;
}
private opcode_7f(): void { /*** smbi .1 ***/
    this.t16 = (this.d)+(this.fetch()^0xFF)+(this.df);this.d = this.t16 & 0xFF;this.df = (this.t16 >> 8) & 1;
}
private opcode_80(): void { /*** glo r0 ***/
    this.d = this.r[0x0] & 0xFF;
}
private opcode_81(): void { /*** glo r1 ***/
    this.d = this.r[0x1] & 0xFF;
}
private opcode_82(): void { /*** glo r2 ***/
    this.d = this.r[0x2] & 0xFF;
}
private opcode_83(): void { /*** glo r3 ***/
    this.d = this.r[0x3] & 0xFF;
}
private opcode_84(): void { /*** glo r4 ***/
    this.d = this.r[0x4] & 0xFF;
}
private opcode_85(): void { /*** glo r5 ***/
    this.d = this.r[0x5] & 0xFF;
}
private opcode_86(): void { /*** glo r6 ***/
    this.d = this.r[0x6] & 0xFF;
}
private opcode_87(): void { /*** glo r7 ***/
    this.d = this.r[0x7] & 0xFF;
}
private opcode_88(): void { /*** glo r8 ***/
    this.d = this.r[0x8] & 0xFF;
}
private opcode_89(): void { /*** glo r9 ***/
    this.d = this.r[0x9] & 0xFF;
}
private opcode_8a(): void { /*** glo ra ***/
    this.d = this.r[0xA] & 0xFF;
}
private opcode_8b(): void { /*** glo rb ***/
    this.d = this.r[0xB] & 0xFF;
}
private opcode_8c(): void { /*** glo rc ***/
    this.d = this.r[0xC] & 0xFF;
}
private opcode_8d(): void { /*** glo rd ***/
    this.d = this.r[0xD] & 0xFF;
}
private opcode_8e(): void { /*** glo re ***/
    this.d = this.r[0xE] & 0xFF;
}
private opcode_8f(): void { /*** glo rf ***/
    this.d = this.r[0xF] & 0xFF;
}
private opcode_90(): void { /*** ghi r0 ***/
    this.d = (this.r[0x0] >> 8) & 0xFF;
}
private opcode_91(): void { /*** ghi r1 ***/
    this.d = (this.r[0x1] >> 8) & 0xFF;
}
private opcode_92(): void { /*** ghi r2 ***/
    this.d = (this.r[0x2] >> 8) & 0xFF;
}
private opcode_93(): void { /*** ghi r3 ***/
    this.d = (this.r[0x3] >> 8) & 0xFF;
}
private opcode_94(): void { /*** ghi r4 ***/
    this.d = (this.r[0x4] >> 8) & 0xFF;
}
private opcode_95(): void { /*** ghi r5 ***/
    this.d = (this.r[0x5] >> 8) & 0xFF;
}
private opcode_96(): void { /*** ghi r6 ***/
    this.d = (this.r[0x6] >> 8) & 0xFF;
}
private opcode_97(): void { /*** ghi r7 ***/
    this.d = (this.r[0x7] >> 8) & 0xFF;
}
private opcode_98(): void { /*** ghi r8 ***/
    this.d = (this.r[0x8] >> 8) & 0xFF;
}
private opcode_99(): void { /*** ghi r9 ***/
    this.d = (this.r[0x9] >> 8) & 0xFF;
}
private opcode_9a(): void { /*** ghi ra ***/
    this.d = (this.r[0xA] >> 8) & 0xFF;
}
private opcode_9b(): void { /*** ghi rb ***/
    this.d = (this.r[0xB] >> 8) & 0xFF;
}
private opcode_9c(): void { /*** ghi rc ***/
    this.d = (this.r[0xC] >> 8) & 0xFF;
}
private opcode_9d(): void { /*** ghi rd ***/
    this.d = (this.r[0xD] >> 8) & 0xFF;
}
private opcode_9e(): void { /*** ghi re ***/
    this.d = (this.r[0xE] >> 8) & 0xFF;
}
private opcode_9f(): void { /*** ghi rf ***/
    this.d = (this.r[0xF] >> 8) & 0xFF;
}
private opcode_a0(): void { /*** plo r0 ***/
    this.r[0x0] = (this.r[0x0] & 0xFF00) | this.d;
}
private opcode_a1(): void { /*** plo r1 ***/
    this.r[0x1] = (this.r[0x1] & 0xFF00) | this.d;
}
private opcode_a2(): void { /*** plo r2 ***/
    this.r[0x2] = (this.r[0x2] & 0xFF00) | this.d;
}
private opcode_a3(): void { /*** plo r3 ***/
    this.r[0x3] = (this.r[0x3] & 0xFF00) | this.d;
}
private opcode_a4(): void { /*** plo r4 ***/
    this.r[0x4] = (this.r[0x4] & 0xFF00) | this.d;
}
private opcode_a5(): void { /*** plo r5 ***/
    this.r[0x5] = (this.r[0x5] & 0xFF00) | this.d;
}
private opcode_a6(): void { /*** plo r6 ***/
    this.r[0x6] = (this.r[0x6] & 0xFF00) | this.d;
}
private opcode_a7(): void { /*** plo r7 ***/
    this.r[0x7] = (this.r[0x7] & 0xFF00) | this.d;
}
private opcode_a8(): void { /*** plo r8 ***/
    this.r[0x8] = (this.r[0x8] & 0xFF00) | this.d;
}
private opcode_a9(): void { /*** plo r9 ***/
    this.r[0x9] = (this.r[0x9] & 0xFF00) | this.d;
}
private opcode_aa(): void { /*** plo ra ***/
    this.r[0xA] = (this.r[0xA] & 0xFF00) | this.d;
}
private opcode_ab(): void { /*** plo rb ***/
    this.r[0xB] = (this.r[0xB] & 0xFF00) | this.d;
}
private opcode_ac(): void { /*** plo rc ***/
    this.r[0xC] = (this.r[0xC] & 0xFF00) | this.d;
}
private opcode_ad(): void { /*** plo rd ***/
    this.r[0xD] = (this.r[0xD] & 0xFF00) | this.d;
}
private opcode_ae(): void { /*** plo re ***/
    this.r[0xE] = (this.r[0xE] & 0xFF00) | this.d;
}
private opcode_af(): void { /*** plo rf ***/
    this.r[0xF] = (this.r[0xF] & 0xFF00) | this.d;
}
private opcode_b0(): void { /*** phi r0 ***/
    this.r[0x0] = (this.r[0x0] & 0x00FF) | (this.d << 8);
}
private opcode_b1(): void { /*** phi r1 ***/
    this.r[0x1] = (this.r[0x1] & 0x00FF) | (this.d << 8);
}
private opcode_b2(): void { /*** phi r2 ***/
    this.r[0x2] = (this.r[0x2] & 0x00FF) | (this.d << 8);
}
private opcode_b3(): void { /*** phi r3 ***/
    this.r[0x3] = (this.r[0x3] & 0x00FF) | (this.d << 8);
}
private opcode_b4(): void { /*** phi r4 ***/
    this.r[0x4] = (this.r[0x4] & 0x00FF) | (this.d << 8);
}
private opcode_b5(): void { /*** phi r5 ***/
    this.r[0x5] = (this.r[0x5] & 0x00FF) | (this.d << 8);
}
private opcode_b6(): void { /*** phi r6 ***/
    this.r[0x6] = (this.r[0x6] & 0x00FF) | (this.d << 8);
}
private opcode_b7(): void { /*** phi r7 ***/
    this.r[0x7] = (this.r[0x7] & 0x00FF) | (this.d << 8);
}
private opcode_b8(): void { /*** phi r8 ***/
    this.r[0x8] = (this.r[0x8] & 0x00FF) | (this.d << 8);
}
private opcode_b9(): void { /*** phi r9 ***/
    this.r[0x9] = (this.r[0x9] & 0x00FF) | (this.d << 8);
}
private opcode_ba(): void { /*** phi ra ***/
    this.r[0xA] = (this.r[0xA] & 0x00FF) | (this.d << 8);
}
private opcode_bb(): void { /*** phi rb ***/
    this.r[0xB] = (this.r[0xB] & 0x00FF) | (this.d << 8);
}
private opcode_bc(): void { /*** phi rc ***/
    this.r[0xC] = (this.r[0xC] & 0x00FF) | (this.d << 8);
}
private opcode_bd(): void { /*** phi rd ***/
    this.r[0xD] = (this.r[0xD] & 0x00FF) | (this.d << 8);
}
private opcode_be(): void { /*** phi re ***/
    this.r[0xE] = (this.r[0xE] & 0x00FF) | (this.d << 8);
}
private opcode_bf(): void { /*** phi rf ***/
    this.r[0xF] = (this.r[0xF] & 0x00FF) | (this.d << 8);
}
private opcode_c0(): void { /*** lbr .2 ***/
    this.t16=this.fetch();this.t16=(this.t16 << 8)|this.fetch();this.r[this.p] = this.t16;this.cycles++;
}
private opcode_c1(): void { /*** lbq .2 ***/
    this.t16=this.fetch();this.t16=(this.t16 << 8)|this.fetch();if (this.q != 0) { this.r[this.p] = this.t16; };this.cycles++;
}
private opcode_c2(): void { /*** lbz .2 ***/
    this.t16=this.fetch();this.t16=(this.t16 << 8)|this.fetch();if (this.d == 0) { this.r[this.p] = this.t16; };this.cycles++;
}
private opcode_c3(): void { /*** lbdf .2 ***/
    this.t16=this.fetch();this.t16=(this.t16 << 8)|this.fetch();if (this.df != 0) { this.r[this.p] = this.t16; };this.cycles++;
}
private opcode_c4(): void { /*** nop ***/
    this.cycles++;
}
private opcode_c5(): void { /*** lsnq .2 ***/
    if (this.q == 0) { this.r[this.p] = (this.r[this.p]+2) & 0xFFFF; };this.cycles++;
}
private opcode_c6(): void { /*** lsnz .2 ***/
    if (this.d != 0) { this.r[this.p] = (this.r[this.p]+2) & 0xFFFF; };this.cycles++;
}
private opcode_c7(): void { /*** lsnf .2 ***/
    if (this.df == 0) { this.r[this.p] = (this.r[this.p]+2) & 0xFFFF; };this.cycles++;
}
private opcode_c8(): void { /*** lskp ***/
    this.r[this.p] = (this.r[this.p]+2) & 0xFFFF;this.cycles++;
}
private opcode_c9(): void { /*** lbnq .2 ***/
    this.t16=this.fetch();this.t16=(this.t16 << 8)|this.fetch();if (this.q == 0) { this.r[this.p] = this.t16; };this.cycles++;
}
private opcode_ca(): void { /*** lbnz .2 ***/
    this.t16=this.fetch();this.t16=(this.t16 << 8)|this.fetch();if (this.d != 0) { this.r[this.p] = this.t16; };this.cycles++;
}
private opcode_cb(): void { /*** lbnf .2 ***/
    this.t16=this.fetch();this.t16=(this.t16 << 8)|this.fetch();if (this.df == 0) { this.r[this.p] = this.t16; };this.cycles++;
}
private opcode_cc(): void { /*** lsie .2 ***/
    if (this.ie != 0) { this.r[this.p] = (this.r[this.p]+2) & 0xFFFF; };this.cycles++;
}
private opcode_cd(): void { /*** lsq .2 ***/
    if (this.q != 0) { this.r[this.p] = (this.r[this.p]+2) & 0xFFFF; };this.cycles++;
}
private opcode_ce(): void { /*** lsz .2 ***/
    if (this.d == 0) { this.r[this.p] = (this.r[this.p]+2) & 0xFFFF; };this.cycles++;
}
private opcode_cf(): void { /*** lsdf .2 ***/
    if (this.df != 0) { this.r[this.p] = (this.r[this.p]+2) & 0xFFFF; };this.cycles++;
}
private opcode_d0(): void { /*** sep r0 ***/
    this.p = 0x0;
}
private opcode_d1(): void { /*** sep r1 ***/
    this.p = 0x1;
}
private opcode_d2(): void { /*** sep r2 ***/
    this.p = 0x2;
}
private opcode_d3(): void { /*** sep r3 ***/
    this.p = 0x3;
}
private opcode_d4(): void { /*** sep r4 ***/
    this.p = 0x4;
}
private opcode_d5(): void { /*** sep r5 ***/
    this.p = 0x5;
}
private opcode_d6(): void { /*** sep r6 ***/
    this.p = 0x6;
}
private opcode_d7(): void { /*** sep r7 ***/
    this.p = 0x7;
}
private opcode_d8(): void { /*** sep r8 ***/
    this.p = 0x8;
}
private opcode_d9(): void { /*** sep r9 ***/
    this.p = 0x9;
}
private opcode_da(): void { /*** sep ra ***/
    this.p = 0xA;
}
private opcode_db(): void { /*** sep rb ***/
    this.p = 0xB;
}
private opcode_dc(): void { /*** sep rc ***/
    this.p = 0xC;
}
private opcode_dd(): void { /*** sep rd ***/
    this.p = 0xD;
}
private opcode_de(): void { /*** sep re ***/
    this.p = 0xE;
}
private opcode_df(): void { /*** sep rf ***/
    this.p = 0xF;
}
private opcode_e0(): void { /*** sex r0 ***/
    this.x = 0x0;
}
private opcode_e1(): void { /*** sex r1 ***/
    this.x = 0x1;
}
private opcode_e2(): void { /*** sex r2 ***/
    this.x = 0x2;
}
private opcode_e3(): void { /*** sex r3 ***/
    this.x = 0x3;
}
private opcode_e4(): void { /*** sex r4 ***/
    this.x = 0x4;
}
private opcode_e5(): void { /*** sex r5 ***/
    this.x = 0x5;
}
private opcode_e6(): void { /*** sex r6 ***/
    this.x = 0x6;
}
private opcode_e7(): void { /*** sex r7 ***/
    this.x = 0x7;
}
private opcode_e8(): void { /*** sex r8 ***/
    this.x = 0x8;
}
private opcode_e9(): void { /*** sex r9 ***/
    this.x = 0x9;
}
private opcode_ea(): void { /*** sex ra ***/
    this.x = 0xA;
}
private opcode_eb(): void { /*** sex rb ***/
    this.x = 0xB;
}
private opcode_ec(): void { /*** sex rc ***/
    this.x = 0xC;
}
private opcode_ed(): void { /*** sex rd ***/
    this.x = 0xD;
}
private opcode_ee(): void { /*** sex re ***/
    this.x = 0xE;
}
private opcode_ef(): void { /*** sex rf ***/
    this.x = 0xF;
}
private opcode_f0(): void { /*** ldx ***/
    this.d = this.read(this.r[this.x]);
}
private opcode_f1(): void { /*** or ***/
    this.d = this.d | this.read(this.r[this.x]);
}
private opcode_f2(): void { /*** and ***/
    this.d = this.d & this.read(this.r[this.x]);
}
private opcode_f3(): void { /*** xor ***/
    this.d = this.d ^ this.read(this.r[this.x]);
}
private opcode_f4(): void { /*** add ***/
    this.t16 = (this.d)+(this.read(this.r[this.x]))+(0);this.d = this.t16 & 0xFF;this.df = (this.t16 >> 8) & 1;
}
private opcode_f5(): void { /*** sd ***/
    this.t16 = (this.d^0xFF)+(this.read(this.r[this.x]))+(1);this.d = this.t16 & 0xFF;this.df = (this.t16 >> 8) & 1;
}
private opcode_f6(): void { /*** shr ***/
    this.df = this.d & 1;this.d = (this.d >> 1) & 0x7F;
}
private opcode_f7(): void { /*** sm ***/
    this.t16 = (this.d)+(this.read(this.r[this.x])^0xFF)+(1);this.d = this.t16 & 0xFF;this.df = (this.t16 >> 8) & 1;
}
private opcode_f8(): void { /*** ldi .1 ***/
    this.d = this.fetch();
}
private opcode_f9(): void { /*** ori .1 ***/
    this.d = this.d | this.fetch();
}
private opcode_fa(): void { /*** ani .1 ***/
    this.d = this.d & this.fetch();
}
private opcode_fb(): void { /*** xri .1 ***/
    this.d = this.d ^ this.fetch();
}
private opcode_fc(): void { /*** adi .1 ***/
    this.t16 = (this.d)+(this.fetch())+(0);this.d = this.t16 & 0xFF;this.df = (this.t16 >> 8) & 1;
}
private opcode_fd(): void { /*** sdi .1 ***/
    this.t16 = (this.d^0xFF)+(this.fetch())+(1);this.d = this.t16 & 0xFF;this.df = (this.t16 >> 8) & 1;
}
private opcode_fe(): void { /*** shl ***/
    this.df = (this.d >> 7) & 1;this.d = (this.d << 1) & 0xFF;
}
private opcode_ff(): void { /*** smi .1 ***/
    this.t16 = (this.d)+(this.fetch()^0xFF)+(1);this.d = this.t16 & 0xFF;this.df = (this.t16 >> 8) & 1;
}
}
