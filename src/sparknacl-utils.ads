private package SPARKNaCl.Utils
  with SPARK_Mode => On
is
   --===================================================
   --  Exported subprogram declarations
   --
   --  Note that these subprograms appear in a distinct
   --  private child package so they are NOT
   --  primitive operations of either types Byte_Seq or
   --  GF, but they ARE potentially usable by other
   --  public children of SPARKNaCl.
   --===================================================

   --  Constant time conditional swap of P and Q. Note that
   --  if a Normal_GF is passed in, this property is retained
   --  on swapping (or not...)  This is required Pack_25519.
   --  In the original TweetNaCl sources, this was called
   --  "sel25519"
   procedure CSwap (P    : in out GF;
                    Q    : in out GF;
                    Swap : in     Boolean)
     with Global => null,
          Contract_Cases =>
            (Swap => (P = Q'Old and Q = P'Old and
                     (Normal_GF_Predicate (P'Old) = Normal_GF_Predicate(Q)) and
                     (Normal_GF_Predicate(Q'Old) = Normal_GF_Predicate(P))),
             not Swap => (P = P'Old and Q = Q'Old) and
                         (Normal_GF_Predicate(P'Old) = Normal_GF_Predicate(P)) and
                         (Normal_GF_Predicate(Q'Old) = Normal_GF_Predicate(Q)));

   --  Reduces N modulo (2**255 - 19) then packs the
   --  value into 32 bytes little-endian.
   function Pack_25519 (N : in Normal_GF) return Bytes_32
     with Global => null;

   function Inv_25519 (I : in Normal_GF) return Normal_GF
     with Global => null;

   function Unpack_25519 (N : in Bytes_32) return Normal_GF
     with Global => null;

   function Random_Bytes_32 return Bytes_32
     with Global => Random.Entropy,
          Volatile_Function;

end SPARKNaCl.Utils;
