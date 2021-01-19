with SPARKNaCl.Car;
package body SPARKNaCl
  with SPARK_Mode => On
is
   --===============================
   --  Local subprogram bodies
   --===============================

   function "+" (Left, Right : in Normal_GF) return Normal_GF
   is
      R : Sum_GF := (others => 0);
   begin
      for I in Index_16 loop
         R (I) := Left (I) + Right (I);
         pragma Loop_Invariant
           (for all J in Index_16 range 0 .. I => R (J) in GF_Sum_Limb);
      end loop;

      --  In SPARKNaCl, we _always_ normalize after "+" to simplify proof.
      --  This sacrifices some performance for proof automation.
      --
      --  In future, it might be possible to remove normalization here
      --  if the functions in SPARKNaCl.Car can be proven to handle the
      --  larger range of limbs that result.  TBD.
      return Car.Nearlynormal_To_Normal
        (Car.Sum_To_Nearlynormal (R));
   end "+";

   function "-" (Left, Right : in Normal_GF) return Normal_GF
   is
      R : GF := (others => 0);
   begin
      --  For limb 0, we compute the difference, but add LM to
      --  make sure the result is positive.
      R (0) := (Left (0) - Right (0)) + LM;

      for I in Index_16 range 1 .. 15 loop
         --  Having added LM to the previous limb, we also add LM to
         --  each new limb, but subtract 1 to account for the extra LM from
         --  the earlier limb
         R (I) := (Left (I) - Right (I)) + LMM1;
         pragma Loop_Invariant
           ((R (0) in 1 .. 2 * LMM1 + 1) and
            (for all K in Index_16 range 1 .. I => R (K) in 0 .. 2 * LMM1));
      end loop;

      --  We now need to carry -1 into limb R (16), but that doesn't
      --  exist, so we carry 2**256 * -1 into limb R (0). As before,
      --  we know that (2**256) mod (2**255 - 19) = R2256, so we add
      --  R2256 * -1 to R (0)
      R (0) := R (0) - R2256;

      pragma Assert (Difference_GF_Predicate (R));

      --  In SPARKNaCl, we _always_ normalize after "-" to simplify proof.
      --  This sacrifices some performance for proof automation.
      --
      --  In future, it might be possible to remove normalization here
      --  if the functions in SPARKNaCl.Car can be proven to handle the
      --  larger range of limbs that result.  TBD.
      return Car.Nearlynormal_To_Normal
        (Car.Difference_To_Nearlynormal (R));
   end "-";

   function "*" (Left, Right : in Normal_GF) return Normal_GF
   is
      T  : GF_PA;
      TF : Product_GF;
   begin
      T := (others => 0);

      --  "Textbook" ladder multiplication
      for I in Index_16 loop
         for J in Index_16 loop
            T (I + J) := T (I + J) + (Left (I) * Right (J));

            pragma Loop_Invariant
              (
               --  Lower bound
               (for all K in Index_31 => T (K) >= 0) and

               --  rising from 1 to I
               (for all K in Index_31 range 0 .. (I - 1)   =>
                  T (K) <= (I64 (K + 1) * MGFLP)) and

               --  flat at I + 1, just written
               (for all K in Index_31 range I .. I32'Min (15, I + J) =>
                  T (K) <= (I64 (I + 1) * MGFLP)) and

               --  flat at I, not written yet
               (for all K in Index_31 range I + J + 1 .. 15 =>
                  T (K) <= (I64 (I) * MGFLP)) and

               --  falling from I to 1, just written
               (for all K in Index_31 range 16 .. (I + J) =>
                  T (K) <= (I64 (16 + I) - I64 (K)) * MGFLP) and

               --  falling, from I to 1, but not written yet
               (for all K in Index_31 range
                  I32'Max (16, I + J + 1) .. (I + 15) =>
                  T (K) <= (I64 (15 + I) - I64 (K)) * MGFLP) and

               --  Zeroes - never written
               (for all K in Index_31 range I + 16 .. 30   =>
                  T (K) = 0)
              );


         end loop;

         --  Substituting J = 15 into the nested invariant above,
         --  and eliminating quantifiers with null ranges yields:
         pragma Loop_Invariant
           (
            --  Lower bound
            (for all K in Index_31 => T (K) >= 0) and
            --  Upper bounds
            (for all K in Index_31 range 0 .. (I - 1)   =>
               T (K) <= (I64 (K + 1) * MGFLP)) and
            (for all K in Index_31 range I .. 15        =>
               T (K) <= (I64 (I + 1) * MGFLP)) and
            (for all K in Index_31 range 16 .. (I + 15) =>
               T (K) <= (I64 (16 + I) - I64 (K)) * MGFLP) and
            (for all K in Index_31 range I + 16 .. 30   =>
               T (K) = 0)
           );
      end loop;

      --  Substituting I = 15 into the outer loop invariant above,
      --  and eliminating quantifiers with null ranges yields
      --  the following assertion.
      --
      --  The coefficients of MGFLP in the upper bound for limbs 0 .. 30
      --  form a "pyramid" which peaks at 16 for T (15), like this:
      --
      --- 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 15 14 13 12 11 10 ... 1
      pragma Assert
        (
         --  Lower bound
         (for all K in Index_31 => T (K) >= 0) and
         --  Upper bounds
         (for all K in Index_31 range  0 .. 14 =>
            T (K) <= (I64 (K) + 1) * MGFLP) and
         T (15) <= 16 * MGFLP and
         (for all K in Index_31 range 16 .. 30 =>
            T (K) <= (31 - I64 (K)) * MGFLP)
        );

      TF := (15 => T (15), others => 0);

      --  To "carry" the value in limbs 16 .. 30 and above down into
      --  limbs 0 .. 14, we need to multiply each upper limb by 2**256.
      --
      --  Unfortutely, our limbs don't have enough bits for that to work,
      --  but we're working in mod (2**255 - 19) arithmetic, and we know that
      --  2**256 mod (2**255 - 19) = R2256, so we can multiply by that instead.
      --
      --  Given the upper bounds established above, we _can_ prove that
      --  T (I) + R2256 * T (I + 16) WILL fit in 64 bits.
      for I in Index_15 loop
         TF (I) := T (I) + R2256 * T (I + 16);
         pragma Loop_Invariant
           (
            (for all J in Index_15 range 0 .. I =>
               TF (J) = T (J) + R2256 * T (J + 16))
            and then
            (for all J in Index_15 range I + 1 .. 14 =>
               TF (J) = 0)
            and then
              TF (15) = T (15)
            and then
              --  Force the subtype predicate check here
              Product_GF_Predicate (TF)
           );
      end loop;

      --  Sanitize T, as per WireGuard sources
      pragma Warnings (GNATProve, Off, "statement has no effect");
      Sanitize_GF_PA (T);
      pragma Unreferenced (T);

      --  In SPARKNaCl, we normalize after "*".
      --
      --  Interestingly, in the TweetNaCl sources, only TWO
      --  applications of the "car_25519" function are used here.
      --
      --  In SPARKNaCl we have proved that THREE
      --  applications of car_25519 are required to definitely
      --  return any possible Product_GF to a fully normalized
      --  Normal_GF.
      return Car.Nearlynormal_To_Normal
               (Car.Seminormal_To_Nearlynormal
                 (Car.Product_To_Seminormal (TF)));
   end "*";

   function Square (A : in Normal_GF) return Normal_GF
   is
   begin
      return A * A;
   end Square;

   --===============================
   --  Exported subprogram bodies
   --===============================

   --------------------------------------------------------
   --  Constant time equality test
   --------------------------------------------------------

   function Equal (X, Y : in Byte_Seq) return Boolean
   is
      D : Boolean := True;
   begin
      for I in N32 range X'Range loop
         D := D and (X (I) = Y (I));
         pragma Loop_Invariant
           (D = (for all J in N32 range X'First .. I => X (J) = Y (J)));
      end loop;

      return D;
   end Equal;

   --------------------------------------------------------
   --  RNG
   --------------------------------------------------------

   procedure Random_Bytes (R : out Byte_Seq)
   is
   begin
      for I in R'Range loop
         R (I) := Random.Random_Byte;
      end loop;
   end Random_Bytes;

   --------------------------------------------------------
   --  Data sanitization
   --------------------------------------------------------

   procedure Sanitize (R : out Byte_Seq) is separate;

   procedure Sanitize_U64 (R : out U64) is separate;

   procedure Sanitize_GF (R : out GF) is separate;

   procedure Sanitize_GF_PA (R : out GF_PA) is separate;

   procedure Sanitize_I64_Seq (R : out I64_Seq) is separate;

   procedure Sanitize_Boolean (R : out Boolean) is separate;

end SPARKNaCl;
