with SPARKNaCl_Types; use SPARKNaCl_Types;
with SPARKNaCl;       use SPARKNaCl;
with SPARKNaCl.Debug; use SPARKNaCl.Debug;
procedure Onetimeauth
is
   RS : constant Bytes_32 :=
     (16#ee#, 16#a6#, 16#a7#, 16#25#, 16#1c#, 16#1e#, 16#72#, 16#91#,
      16#6d#, 16#11#, 16#c2#, 16#cb#, 16#21#, 16#4d#, 16#3c#, 16#25#,
      16#25#, 16#39#, 16#12#, 16#1d#, 16#8e#, 16#23#, 16#4e#, 16#65#,
      16#2d#, 16#65#, 16#1f#, 16#a4#, 16#c8#, 16#cf#, 16#f8#, 16#80#);


   C : constant Byte_Seq (0 .. 130) :=
     (16#8e#, 16#99#, 16#3b#, 16#9f#, 16#48#, 16#68#, 16#12#, 16#73#,
      16#c2#, 16#96#, 16#50#, 16#ba#, 16#32#, 16#fc#, 16#76#, 16#ce#,
      16#48#, 16#33#, 16#2e#, 16#a7#, 16#16#, 16#4d#, 16#96#, 16#a4#,
      16#47#, 16#6f#, 16#b8#, 16#c5#, 16#31#, 16#a1#, 16#18#, 16#6a#,
      16#c0#, 16#df#, 16#c1#, 16#7c#, 16#98#, 16#dc#, 16#e8#, 16#7b#,
      16#4d#, 16#a7#, 16#f0#, 16#11#, 16#ec#, 16#48#, 16#c9#, 16#72#,
      16#71#, 16#d2#, 16#c2#, 16#0f#, 16#9b#, 16#92#, 16#8f#, 16#e2#,
      16#27#, 16#0d#, 16#6f#, 16#b8#, 16#63#, 16#d5#, 16#17#, 16#38#,
      16#b4#, 16#8e#, 16#ee#, 16#e3#, 16#14#, 16#a7#, 16#cc#, 16#8a#,
      16#b9#, 16#32#, 16#16#, 16#45#, 16#48#, 16#e5#, 16#26#, 16#ae#,
      16#90#, 16#22#, 16#43#, 16#68#, 16#51#, 16#7a#, 16#cf#, 16#ea#,
      16#bd#, 16#6b#, 16#b3#, 16#73#, 16#2b#, 16#c0#, 16#e9#, 16#da#,
      16#99#, 16#83#, 16#2b#, 16#61#, 16#ca#, 16#01#, 16#b6#, 16#de#,
      16#56#, 16#24#, 16#4a#, 16#9e#, 16#88#, 16#d5#, 16#f9#, 16#b3#,
      16#79#, 16#73#, 16#f6#, 16#22#, 16#a4#, 16#3d#, 16#14#, 16#a6#,
      16#59#, 16#9b#, 16#1f#, 16#65#, 16#4c#, 16#b4#, 16#5a#, 16#74#,
      16#e3#, 16#55#, 16#a5#);

   A : Bytes_16;
begin
   Crypto_Onetimeauth (A, C, RS);
   DH ("A is", A);
end Onetimeauth;
