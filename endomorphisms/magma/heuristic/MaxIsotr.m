/***
 *  Maximal isotropic subgroups and resulting lattices
 *
 *  Copyright (C) 2016-2017
 *            Edgar Costa      (edgarcosta@math.dartmouth.edu)
 *            Davide Lombardo  (davide.lombardo@math.u-psud.fr)
 *            Jeroen Sijsling  (jeroen.sijsling@uni-ulm.de)
 *
 *  See LICENSE.txt for license details.
 */


intrinsic InducedPolarization(E::., R::.) -> .
{Given a matrix E corresponding to a polarization, returns the pushforward of E along R.}
// A map from gX to gY gives R that is 2 gY x 2 gX, since on homology we go from rank 2 gX to rank 2 gY.
// But what does this function actually do??? Pullback along dual. Use it and
// after we get to PPAV dualize for real.

Q := R*E*Transpose(R);
d := GCD([ Integers() ! c : c in Eltseq(Q) ]);
return Matrix(ChangeRing(Q/d, Integers()));

end intrinsic;


intrinsic FrobeniusFormAlternatingAlt(E::.) -> .
{Returns a different standard form E0 and a matrix T with T E Transpose(T) = E0.}

E1, T1 := FrobeniusFormAlternating(ChangeRing(E, Integers()));
g := #Rows(E) div 2; S := Sym(2*g);
sigma := S ! (&cat[ [ i, g + i ] : i in [1..g] ]);
P := PermutationMatrix(Integers(), sigma);
E2 := P*E1*Transpose(P);
T2 := P*T1;
return E2, T2;

end intrinsic;


function SymplecticSubmodulesPrime(p, d)
// This is really stupid: right cosets are better. However, do not see how to
// do that now and can get by without.

assert d mod 2 eq 0;
FF := FiniteField(p);
V := VectorSpace(FF, d);
B0 := [ V.i : i in [1..(d div 2)] ];
G := SymplecticGroup(d, FF);
Ws := [ ];
for g in G do
    W := sub< V | [ b*g : b in B0 ] >;
    if not W in Ws then
        Append(~Ws, W);
    end if;
end for;
return Ws;

end function;


function SymplecticSubmodulesPrimePower(pf, d)
// Based on a suggestion of John Voight

assert d mod 2 eq 0;
test, p, f := IsPrimePower(pf);
if f eq 1 then
    return SymplecticSubmodulesPrime(p, d);
end if;

R := quo< Integers() | pf >;
M := RSpace(R, d);

bases := CartesianPower(M, d);
submods := [ ];
for tup in bases do
    basis := [ e : e in tup ];
    /* Check that elements generate */
    if sub< M | basis > eq M then
        factors := [ ];
        /* In the end we have to consider d/2 pairs */
        for i in [1..(d div 2)] do
            factor := [ ];
            /* The pairs per (i, i + 1) */
            for e in [0..(f div 2)] do
                Append(~factor, [ (p^e)*basis[2*i - 1], p^(f - e)*basis[2*i] ]);
            end for;
            Append(~factors, factor);
        end for;
        /* Now take cartesian product and keep new spaces */
        CP := CartesianProduct(factors);
        for tup in CP do
            newbasis := &cat[ pair : pair in tup ];
            N := sub< M | newbasis >;
            if not N in submods then
                Append(~submods, N);
            end if;
        end for;
    end if;
end for;
return submods;

end function;


intrinsic SymplecticSubmodules(n::RngIntElt, d::RngIntElt) -> .
{All symplectic submodules of index n in rank 2*d, or alternatively the maximal
symplectic submodules of (ZZ / n ZZ)^(2*d) with the canonical form.}

assert d mod 2 eq 0;
Fac := Factorization(n);
pfs := [ tup[1]^tup[2] : tup in Fac ];
L0 := Lattice(IdentityMatrix(Rationals(), d));
Lats := [ L0 ];

for pf in pfs do
    submods := SymplecticSubmodulesPrimePower(pf, d);
    Latsnew := [ ];
    for Lat in Lats do
        for submod in submods do
            //M := ChangeRing(Matrix(Basis(Lat)), Rationals());;
            //Mnew := (1/pf) * Matrix(Rationals(), [ [ Rationals() ! Integers() ! c : c in Eltseq(gen) ] : gen in Generators(submod) ]);
            B := ChangeRing(Matrix(Basis(Lat)), Rationals());
            M := pf * B;
            Mnew := Matrix(Rationals(), [ [ Integers() ! c : c in Eltseq(gen) ] : gen in Generators(submod) ]) * B;
            Append(~Latsnew, Lattice(VerticalJoin(M, Mnew)));
        end for;
    end for;
    Lats := Latsnew;
end for;
return Lats;

end intrinsic;


/* TODO: Generalize */
intrinsic IsogenousPPLatticesG2(E::.) -> .
{Given an alternating form E, finds the sublattices to ZZ^2d of smallest possible index on which E induces a principal polarization. These are returned in matrix form, that is, as a span of a basis in the rows. This basis is symplectic in the usual sense.}
/* In general, we would isolate the blocks with given d and deal with those one at a time */

E0, T0 := FrobeniusFormAlternatingAlt(E);
n := Abs(E0[3,4]);

Ts := [ ];
for Lat in SymplecticSubmodules(n, 2) do
    Ur := ChangeRing(Matrix(Basis(Lat)), Rationals());
    U := DiagonalJoin(Ur, IdentityMatrix(Rationals(), 2));
    Append(~Ts, U*ChangeRing(T0, Rationals()));
end for;

/* Transform back */
sigma := Sym(4) ! [1, 3, 2, 4];
P := PermutationMatrix(Integers(), sigma);
Ts := [ P*T : T in Ts ];

/* Sign */
for i in [1..#Ts] do
    T := Ts[i];
    E0 := T*E*Transpose(T);
    if Sign(E0[1,3]) lt 0 then
        T := DiagonalMatrix(Rationals(), [1,1,-1,1]) * T;
    end if;
    if Sign(E0[2,4]) lt 0 then
        T := DiagonalMatrix(Rationals(), [1,1,1,-1]) * T;
    end if;
    Ts[i] := T;
end for;
return Ts;

end intrinsic;
