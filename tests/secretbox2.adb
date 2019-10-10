with SPARKNaCl_Types; use SPARKNaCl_Types;
with SPARKNaCl;       use SPARKNaCl;
with SPARKNaCl.Debug; use SPARKNaCl.Debug;
with Ada.Text_IO;     use Ada.Text_IO;
procedure Secretbox2
is
   Firstkey : constant Bytes_32 :=
     (16#1b#, 16#27#, 16#55#, 16#64#, 16#73#, 16#e9#, 16#85#, 16#d4#,
      16#62#, 16#cd#, 16#51#, 16#19#, 16#7a#, 16#9a#, 16#46#, 16#c7#,
      16#60#, 16#09#, 16#54#, 16#9e#, 16#ac#, 16#64#, 16#74#, 16#f2#,
      16#06#, 16#c4#, 16#ee#, 16#08#, 16#44#, 16#f6#, 16#83#, 16#89#);

   Nonce : constant Bytes_24 :=
     (16#69#, 16#69#, 16#6e#, 16#e9#, 16#55#, 16#b6#, 16#2b#, 16#73#,
      16#cd#, 16#62#, 16#bd#, 16#a8#, 16#75#, 16#fc#, 16#73#, 16#d6#,
      16#82#, 16#19#, 16#e0#, 16#03#, 16#6b#, 16#7a#, 16#0b#, 16#37#);

   C : constant Byte_Seq (0 .. 162) :=
     (16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#,
      16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#,
      16#F3#, 16#FF#, 16#C7#, 16#70#, 16#3F#, 16#94#, 16#00#, 16#E5#,
      16#2A#, 16#7D#, 16#FB#, 16#4B#, 16#3D#, 16#33#, 16#05#, 16#D9#,
      16#8E#, 16#99#, 16#3B#, 16#9F#, 16#48#, 16#68#, 16#12#, 16#73#,
      16#C2#, 16#96#, 16#50#, 16#BA#, 16#32#, 16#FC#, 16#76#, 16#CE#,
      16#48#, 16#33#, 16#2E#, 16#A7#, 16#16#, 16#4D#, 16#96#, 16#A4#,
      16#47#, 16#6F#, 16#B8#, 16#C5#, 16#31#, 16#A1#, 16#18#, 16#6A#,
      16#C0#, 16#DF#, 16#C1#, 16#7C#, 16#98#, 16#DC#, 16#E8#, 16#7B#,
      16#4D#, 16#A7#, 16#F0#, 16#11#, 16#EC#, 16#48#, 16#C9#, 16#72#,
      16#71#, 16#D2#, 16#C2#, 16#0F#, 16#9B#, 16#92#, 16#8F#, 16#E2#,
      16#27#, 16#0D#, 16#6F#, 16#B8#, 16#63#, 16#D5#, 16#17#, 16#38#,
      16#B4#, 16#8E#, 16#EE#, 16#E3#, 16#14#, 16#A7#, 16#CC#, 16#8A#,
      16#B9#, 16#32#, 16#16#, 16#45#, 16#48#, 16#E5#, 16#26#, 16#AE#,
      16#90#, 16#22#, 16#43#, 16#68#, 16#51#, 16#7A#, 16#CF#, 16#EA#,
      16#BD#, 16#6B#, 16#B3#, 16#73#, 16#2B#, 16#C0#, 16#E9#, 16#DA#,
      16#99#, 16#83#, 16#2B#, 16#61#, 16#CA#, 16#01#, 16#B6#, 16#DE#,
      16#56#, 16#24#, 16#4A#, 16#9E#, 16#88#, 16#D5#, 16#F9#, 16#B3#,
      16#79#, 16#73#, 16#F6#, 16#22#, 16#A4#, 16#3D#, 16#14#, 16#A6#,
      16#59#, 16#9B#, 16#1F#, 16#65#, 16#4C#, 16#B4#, 16#5A#, 16#74#,
      16#E3#, 16#55#, 16#A5#);


   M : Byte_Seq (0 .. 162);
   S : Verify_Result;
begin
   Crypto_Secretbox_Open (M, S, C, Nonce, Firstkey);

   Put_Line ("Status is" & S'Img);
   DH ("M is", M);
end Secretbox2;
